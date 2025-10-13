import json
from os import path as osp, remove
from shutil import rmtree
from textwrap import dedent

import pytest
from pytest_infrahouse import terraform_apply

from tests.conftest import (
    LOG,
)


@pytest.mark.parametrize(
    "aws_provider_version", ["~> 5.11", "~> 6.0"], ids=["aws-5", "aws-6"]
)
def test_module(
    elasticsearch,
    service_network,
    aws_region,
    keep_after,
    test_role_arn,
    test_zone_name,
    cleanup_ecs_task_definitions,
    aws_provider_version,
):
    terraform_root_dir = "test_data"

    terraform_dir = osp.join(terraform_root_dir, "kibana")

    # Clean up state files to ensure fresh terraform init
    state_files = [
        osp.join(terraform_dir, ".terraform"),
        osp.join(terraform_dir, ".terraform.lock.hcl"),
    ]
    for state_file in state_files:
        try:
            if osp.isdir(state_file):
                rmtree(state_file)
            elif osp.isfile(state_file):
                remove(state_file)
        except FileNotFoundError:
            pass

    subnet_public_ids = service_network["subnet_public_ids"]["value"]
    internet_gateway_id = service_network["internet_gateway_id"]["value"]

    cluster_name = elasticsearch["cluster_name"]["value"]
    elasticsearch_url = elasticsearch["elasticsearch_url"]["value"]
    kibana_system_password = elasticsearch["kibana_system_password"]["value"]
    keypair_name = elasticsearch["keypair_name"]["value"]
    idle_timeout_master = elasticsearch["idle_timeout_master"]["value"]

    # Generate terraform.tf with specified AWS provider version
    with open(osp.join(terraform_dir, "terraform.tf"), "w") as fp:
        fp.write(
            dedent(
                f"""
                terraform {{
                  required_version = "~> 1.5"
                  //noinspection HILUnresolvedReference
                  required_providers {{
                    aws = {{
                      source = "hashicorp/aws"
                      version = "{aws_provider_version}"
                    }}
                  }}
                }}
                """
            )
        )

    with open(osp.join(terraform_dir, "terraform.tfvars"), "w") as fp:
        fp.write(f'region = "{aws_region}"\n')
        fp.write(f'test_zone = "{test_zone_name}"\n')
        fp.write(f"asg_subnets = {json.dumps(subnet_public_ids)}\n")
        fp.write(f'cluster_name = "{cluster_name}"\n')
        fp.write(f'elasticsearch_url = "{elasticsearch_url}"\n')
        fp.write(f'internet_gateway_id = "{internet_gateway_id}"\n')
        fp.write(f'kibana_system_password = "{kibana_system_password}"\n')
        fp.write(f"load_balancer_subnets = {json.dumps(subnet_public_ids)}\n")
        fp.write(f'ssh_key_name = "{keypair_name}"\n')
        fp.write(f"elasticsearch_request_timeout = {idle_timeout_master}\n")

        if test_role_arn:
            fp.write(f'role_arn = "{test_role_arn}"\n')

    with terraform_apply(
        terraform_dir,
        destroy_after=not keep_after,
        json_output=True,
    ) as tf_output_kibana:
        LOG.info(json.dumps(tf_output_kibana, indent=4))
        LOG.info(json.dumps(elasticsearch, indent=4))
        cleanup_ecs_task_definitions(f"{cluster_name}-kibana")
