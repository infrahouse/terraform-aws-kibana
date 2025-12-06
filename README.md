# terraform-aws-kibana

The module creates Kibana for the Elasticsearch cluster.

# Usage
## Prerequisites

Elasticsearch cluster is a natural pre-requisite of Kibana. However, the Elasticsearch cluster itself
requires certain AWS resources. 
Check the [elasticsearch module documentation](https://registry.terraform.io/modules/infrahouse/elasticsearch/aws/latest#dependencies) for those.

## Elasticsearch cluster

The Elasticsearch cluster requires two `terraform apply`-s. One with `bootstrap_mode = true` and another with 
`bootstrap_mode = false`. Use following Terraform snippet to provision the cluster.
```hcl
module "elasticsearch" {
  source  = "infrahouse/elasticsearch/aws"
  version = "~> 3.11"
  providers = {
    aws     = aws
    aws.dns = aws
  }
  cluster_name         = "some-cluster-name"
  cluster_master_count = 3
  cluster_data_count   = 1
  environment          = "development"
  internet_gateway_id  = module.service-network.internet_gateway_id
  key_pair_name        = aws_key_pair.test.key_name
  subnet_ids           = module.service-network.subnet_private_ids
  zone_id              = var.zone_id
  bootstrap_mode       = var.bootstrap_mode
}
```

## Kibana

One the Elasticsearch cluster is ready (and by "ready" I mean master and data nodes are up & running),
you can provision Kibana.
```hcl
module "kibana" {
  source  = "infrahouse/kibana/aws"
  version = "~> 2.0"
  providers = {
    aws     = aws
    aws.dns = aws
  }
  alert_emails               = ["ops-team@example.com"]
  asg_subnets                = module.service-network.subnet_private_ids
  elasticsearch_cluster_name = "some-cluster-name"
  elasticsearch_url          = var.elasticsearch_url
  kibana_system_password     = module.elasticsearch.kibana_system_password
  load_balancer_subnets      = module.service-network.subnet_public_ids
  ssh_key_name               = aws_key_pair.test.key_name
  zone_id                    = var.zone_id
}
```
Note the inputs:
* `alert_emails` - list of email addresses for CloudWatch alarm notifications (required for monitoring ECS service health)
* `asg_subnets` - these are subnet ids where autoscaling group with EC2 instance for Kibana ECS will be created. They need to be private subnets - you don't want to expose them to Internet.
* `load_balancer_subnets` - these are subnet ids where the load balancer will be created. Can be public, but I recommend to deploy the load balancer in the private subnets and configure VPN access for users that need Kibana.

The kibana module will output URL where Kibana UI is available. User elastic username and its password to access Kibana first time.

## Migration from v1.x to v2.x

**This is a breaking change.** Version 2.0.0 upgrades the underlying ECS module from v5 to v7.

### Breaking Changes

1. **New Required Variable: `alert_emails`**
   - You must now provide at least one email address for CloudWatch alarm notifications
   - Add `alert_emails = ["your-email@example.com"]` to your module call

2. **Removed Variable: `internet_gateway_id`**
   - The internet gateway is now auto-detected by the module
   - Remove `internet_gateway_id` from your module configuration

3. **Default Behavior Changes**
   - CloudWatch logs are now enabled by default (was disabled in v1.x)
   - CPU autoscaling threshold lowered from 80% to 60%
   - Default AMI changed from Amazon Linux 2 to Amazon Linux 2023 (if not explicitly set)

### Migration Steps

1. Add the required `alert_emails` parameter:
   ```hcl
   alert_emails = ["ops-team@example.com"]
   ```

2. Remove the `internet_gateway_id` parameter (if present):
   ```diff
   - internet_gateway_id = module.service-network.internet_gateway_id
   ```

3. Update the module version:
   ```hcl
   version = "~> 2.0"
   ```

4. Run `terraform init -upgrade` to download the new module version

5. Review the terraform plan for expected changes before applying

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.11, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.11, < 7.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kibana"></a> [kibana](#module\_kibana) | registry.infrahouse.com/infrahouse/ecs/aws | 7.0.0 |
| <a name="module_kibana-encryptionKey"></a> [kibana-encryptionKey](#module\_kibana-encryptionKey) | registry.infrahouse.com/infrahouse/secret/aws | 1.1.1 |
| <a name="module_kibana-password"></a> [kibana-password](#module\_kibana-password) | registry.infrahouse.com/infrahouse/secret/aws | 1.1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.task_role_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [random_string.kibana-encryptionKey](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.task_role_exec_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.kibana_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_subnet.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_log_force_destroy"></a> [access\_log\_force\_destroy](#input\_access\_log\_force\_destroy) | Destroy S3 bucket with access logs even if non-empty | `bool` | `false` | no |
| <a name="input_alert_emails"></a> [alert\_emails](#input\_alert\_emails) | List of email addresses for CloudWatch alarm notifications | `list(string)` | n/a | yes |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | Image for host EC2 instances. If not specified, the latest Amazon image will be used. | `string` | `null` | no |
| <a name="input_asg_subnets"></a> [asg\_subnets](#input\_asg\_subnets) | Auto Scaling Group Subnets. | `list(string)` | n/a | yes |
| <a name="input_cloudinit_extra_commands"></a> [cloudinit\_extra\_commands](#input\_cloudinit\_extra\_commands) | Extra commands for run on ASG. | `list(string)` | `[]` | no |
| <a name="input_elasticsearch_cluster_name"></a> [elasticsearch\_cluster\_name](#input\_elasticsearch\_cluster\_name) | Elasticsearch cluster name. | `string` | n/a | yes |
| <a name="input_elasticsearch_request_timeout"></a> [elasticsearch\_request\_timeout](#input\_elasticsearch\_request\_timeout) | Elasticsearch request timeout in seconds. | `number` | `4000` | no |
| <a name="input_elasticsearch_url"></a> [elasticsearch\_url](#input\_elasticsearch\_url) | URL of Elasticsearch masters. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of environment. | `string` | `"development"` | no |
| <a name="input_extra_instance_profile_permissions"></a> [extra\_instance\_profile\_permissions](#input\_extra\_instance\_profile\_permissions) | A JSON with a permissions policy document. The policy will be attached to the ASG instance profile. | `string` | `null` | no |
| <a name="input_kibana_system_password"></a> [kibana\_system\_password](#input\_kibana\_system\_password) | Password for kibana\_system user. This user is an Elasticsearch built-in user. | `string` | n/a | yes |
| <a name="input_load_balancer_subnets"></a> [load\_balancer\_subnets](#input\_load\_balancer\_subnets) | Load Balancer Subnets. | `list(string)` | n/a | yes |
| <a name="input_on_demand_base_capacity"></a> [on\_demand\_base\_capacity](#input\_on\_demand\_base\_capacity) | If specified, the ASG will request spot instances and this will be the minimal number of on-demand instances. | `number` | `null` | no |
| <a name="input_ssh_cidr_block"></a> [ssh\_cidr\_block](#input\_ssh\_cidr\_block) | CIDR range that is allowed to SSH into the backend instances | `string` | `null` | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | ssh key name installed in ECS host instances. | `string` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Zone where DNS records will be created for the service and certificate validation. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kibana_password"></a> [kibana\_password](#output\_kibana\_password) | n/a |
| <a name="output_kibana_url"></a> [kibana\_url](#output\_kibana\_url) | n/a |
| <a name="output_kibana_username"></a> [kibana\_username](#output\_kibana\_username) | n/a |
| <a name="output_load_balancer_arn"></a> [load\_balancer\_arn](#output\_load\_balancer\_arn) | n/a |
<!-- END_TF_DOCS -->
