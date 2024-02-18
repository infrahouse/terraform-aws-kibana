import json
from os import path as osp
from textwrap import dedent

import pytest
from infrahouse_toolkit.terraform import terraform_apply

from tests.conftest import (
    LOG,
    TRACE_TERRAFORM,
    DESTROY_AFTER,
    TEST_ZONE,
    TEST_ROLE_ARN,
    REGION,
)


# @pytest.mark.timeout(1800)
def test_module(ec2_client, route53_client, autoscaling_client):
    terraform_root_dir = "test_data"

    # Start with DNS
    # The module will create a temporary DNS zone for the test duration
    terraform_module_dir = osp.join(terraform_root_dir, "dns")
    with open(osp.join(terraform_module_dir, "terraform.tfvars"), "w") as fp:
        fp.write(
            dedent(
                f"""
                parent_zone_name = "{TEST_ZONE}"
                role_arn = "{TEST_ROLE_ARN}"
                region = "{REGION}"
                """
            )
        )
    with terraform_apply(
        terraform_module_dir,
        destroy_after=DESTROY_AFTER,
        json_output=True,
        enable_trace=TRACE_TERRAFORM,
    ) as tf_output_dns:
        LOG.info(json.dumps(tf_output_dns, indent=4))
        subzone_id = tf_output_dns["subzone_id"]["value"]

        # Next - bootstrapping an ES cluster
        bootstrap_cluster = False
        terraform_module_dir = osp.join(terraform_root_dir, "elastic")
        with open(osp.join(terraform_module_dir, "terraform.tfvars"), "w") as fp:
            fp.write(
                dedent(
                    f"""
                    bootstrap_mode = {str(bootstrap_cluster).lower()}
                    role_arn = "{TEST_ROLE_ARN}"
                    region = "{REGION}"
                    zone_id = "{subzone_id}"
                    """
                )
            )
        with terraform_apply(
            terraform_module_dir,
            destroy_after=DESTROY_AFTER,
            json_output=True,
            enable_trace=TRACE_TERRAFORM,
        ) as tf_output_elastic:
            LOG.info(json.dumps(tf_output_elastic, indent=4))

            # Deploy ES data nodes
            with open(osp.join(terraform_module_dir, "terraform.tfvars"), "w") as fp:
                fp.write(
                    dedent(
                        f"""
                        bootstrap_mode = false
                        role_arn = "{TEST_ROLE_ARN}"
                        region = "{REGION}"
                        zone_id = "{subzone_id}"
                        """
                    )
                )
            with terraform_apply(
                terraform_module_dir,
                destroy_after=DESTROY_AFTER,
                json_output=True,
                enable_trace=TRACE_TERRAFORM,
            ):
                LOG.info(json.dumps(tf_output_elastic, indent=4))

                # Finally, deploy kibana
                terraform_module_dir = osp.join(terraform_root_dir, "kibana")
                with open(
                    osp.join(terraform_module_dir, "terraform.tfvars"), "w"
                ) as fp:
                    subnet_private_ids = json.dumps(
                        tf_output_elastic["subnet_private_ids"]["value"]
                    )
                    subnet_public_ids = json.dumps(
                        tf_output_elastic["subnet_public_ids"]["value"]
                    )
                    fp.write(
                        dedent(
                            f"""
                            role_arn = "{TEST_ROLE_ARN}"
                            region = "{REGION}"
                            zone_id = "{subzone_id}"
                            asg_subnets = {subnet_private_ids}
                            cluster_name = "{tf_output_elastic['cluster_name']['value']}"
                            elasticsearch_url = "{tf_output_elastic['elasticsearch_url']['value']}"
                            internet_gateway_id = "{tf_output_elastic['internet_gateway_id']['value']}"
                            kibana_system_password = "{tf_output_elastic['kibana_system_password']['value']}"
                            load_balancer_subnets = {subnet_public_ids}
                            ssh_key_name = "{tf_output_elastic['ssh_key_name']['value']}"
                            """
                        )
                    )
                with terraform_apply(
                    terraform_module_dir,
                    destroy_after=DESTROY_AFTER,
                    json_output=True,
                    enable_trace=TRACE_TERRAFORM,
                ) as tf_output_kibana:
                    LOG.info(json.dumps(tf_output_kibana, indent=4))
                    LOG.info(json.dumps(tf_output_elastic, indent=4))
