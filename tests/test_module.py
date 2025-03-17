import json
from os import path as osp

from pytest_infrahouse import terraform_apply

from tests.conftest import (
    LOG,
)


def test_module(
    elasticsearch,
    service_network,
    aws_region,
    keep_after,
    test_role_arn,
    test_zone_name,
):
    terraform_root_dir = "test_data"

    terraform_dir = osp.join(terraform_root_dir, "kibana")
    subnet_public_ids = service_network["subnet_public_ids"]["value"]
    internet_gateway_id = service_network["internet_gateway_id"]["value"]

    cluster_name = elasticsearch["cluster_name"]["value"]
    elasticsearch_url = elasticsearch["elasticsearch_url"]["value"]
    kibana_system_password = elasticsearch["kibana_system_password"]["value"]
    keypair_name = elasticsearch["keypair_name"]["value"]
    idle_timeout_master = elasticsearch["idle_timeout_master"]["value"]

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
        fp.write(f'elasticsearch_request_timeout = {idle_timeout_master}\n')

        if test_role_arn:
            fp.write(f'role_arn = "{test_role_arn}"\n')

    with terraform_apply(
        terraform_dir,
        destroy_after=not keep_after,
        json_output=True,
    ) as tf_output_kibana:
        LOG.info(json.dumps(tf_output_kibana, indent=4))
        LOG.info(json.dumps(elasticsearch, indent=4))
