# terraform-aws-kibana

[![Need Help?](https://img.shields.io/badge/Need%20Help%3F-Contact%20Us-0066CC)](https://infrahouse.com/contact)
[![Docs](https://img.shields.io/badge/docs-github.io-blue)](https://infrahouse.github.io/terraform-aws-kibana/)
[![Registry](https://img.shields.io/badge/Terraform-Registry-purple?logo=terraform)](https://registry.terraform.io/modules/infrahouse/kibana/aws/latest)
[![Release](https://img.shields.io/github/release/infrahouse/terraform-aws-kibana.svg)](https://github.com/infrahouse/terraform-aws-kibana/releases/latest)

[![AWS ECS](https://img.shields.io/badge/AWS-ECS-orange?logo=amazonecs)](https://aws.amazon.com/ecs/)
[![AWS EC2](https://img.shields.io/badge/AWS-EC2-orange?logo=amazonec2)](https://aws.amazon.com/ec2/)
[![AWS ELB](https://img.shields.io/badge/AWS-ELB-orange?logo=amazonwebservices)](https://aws.amazon.com/elasticloadbalancing/)
[![AWS Secrets Manager](https://img.shields.io/badge/AWS-Secrets%20Manager-orange?logo=amazonwebservices)](https://aws.amazon.com/secrets-manager/)

[![Security](https://img.shields.io/github/actions/workflow/status/infrahouse/terraform-aws-kibana/vuln-scanner-pr.yml?label=Security)](https://github.com/infrahouse/terraform-aws-kibana/actions/workflows/vuln-scanner-pr.yml)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

Terraform module that deploys [Kibana](https://www.elastic.co/kibana) on AWS ECS in front of an
existing Elasticsearch cluster.

## Why This Module?

Kibana itself is one container, which is exactly why teams end up running it as a pet: an instance
someone started by hand, with the `kibana_system` password in a shell history and no TLS in front of
it. Everything that makes it a service the whole company can use is around the container, and that
is what this module packages:

- **The secrets stay secret.** The three X-Pack encryption keys and the `kibana_system` password live
  in Secrets Manager and are injected as ECS secrets — they never appear in the task definition, in
  user data, or in a container environment you can read from the console. An IAM policy scoped to
  exactly those two secret ARNs is what lets the task read them.
- **HTTPS is not an afterthought.** The load balancer gets an ACM certificate, issued and validated
  in your Route53 zone, and the DNS record is created for you.
- **Long searches actually finish.** Kibana's Elasticsearch request timeout and the load balancer
  idle timeout come from one input, so the ALB cannot cut off a query that Kibana is still waiting
  for — the failure mode that makes people believe "Kibana is flaky".
- **First boot is understood.** Kibana migrates its saved-objects indices before it can answer
  `/login`. The ASG and the ECS service both allow a 900-second grace period, so the first deployment
  does not turn into an instance-replacement loop.
- **Disposable by design.** Kibana keeps all of its state in Elasticsearch, so the task and the host
  can be replaced at any time — which is what makes running it on spot capacity a sane trade.

## Features

- Kibana running as an ECS service on an EC2-backed Auto Scaling Group, sized for the workload
- Application Load Balancer with an ACM certificate and a Route53 record
- X-Pack encryption keys and the `kibana_system` password in AWS Secrets Manager
- CloudWatch container logs, CloudWatch alarms and an SNS topic for `alert_emails`
- ALB access logs in an S3 bucket replicated cross-region for audit retention
- Optional spot capacity via `on_demand_base_capacity`
- SSH access to the ECS hosts restricted to `ssh_cidr_block`

## Quick Start

```hcl
provider "aws" {
  region = "us-west-2"
}

# Second provider for Route53 (the zone may live in another account).
provider "aws" {
  alias  = "dns"
  region = "us-west-2"
}

module "kibana" {
  source  = "registry.infrahouse.com/infrahouse/kibana/aws"
  version = "3.0.1"

  providers = {
    aws     = aws
    aws.dns = aws.dns
  }

  elasticsearch_cluster_name = "elastic"
  elasticsearch_url          = module.elasticsearch.cluster_master_url
  kibana_system_password     = module.elasticsearch.kibana_system_password

  environment           = "production"
  zone_id               = data.aws_route53_zone.this.zone_id
  asg_subnets           = module.service-network.subnet_private_ids
  load_balancer_subnets = module.service-network.subnet_public_ids
  ssh_key_name          = aws_key_pair.this.key_name
  alert_emails          = ["ops-team@example.com"]
  replication_region    = "us-east-1" # must differ from the deploy region
}
```

Kibana is published at `https://<elasticsearch_cluster_name>-kibana.<zone domain>` — the `kibana_url`
output. Sign in with an Elasticsearch user; the `elastic` superuser the first time.

Note the inputs:

- `elasticsearch_cluster_name` — the prefix of every resource and of the DNS record. There is no
  separate hostname input.
- `asg_subnets` — private subnets for the ECS host instances. Do not expose them to the internet.
- `load_balancer_subnets` — public subnets publish Kibana on the internet; private subnets keep it
  behind your VPN, which is the recommended deployment.
- `replication_region` — the ALB access-log bucket is replicated cross-region, so this must be a
  different region than the one you deploy to.

### Prerequisites

An Elasticsearch cluster is a natural prerequisite of Kibana, and the cluster itself needs a VPC,
subnets and a hosted zone. See the
[elasticsearch module documentation](https://registry.terraform.io/modules/infrahouse/elasticsearch/aws/latest#dependencies)
for those, and [Getting Started](https://infrahouse.github.io/terraform-aws-kibana/getting-started/)
for the full list.

The Elasticsearch cluster needs two `terraform apply`s — one with `bootstrap_mode = true` and one
with `bootstrap_mode = false`. Kibana can only connect after the second one:

```hcl
module "elasticsearch" {
  source  = "registry.infrahouse.com/infrahouse/elasticsearch/aws"
  version = "5.2.0"
  providers = {
    aws     = aws
    aws.dns = aws.dns
  }
  cluster_name         = "elastic"
  cluster_master_count = 3
  cluster_data_count   = 3
  environment          = "production"
  key_pair_name        = aws_key_pair.this.key_name
  subnet_ids           = module.service-network.subnet_private_ids
  zone_id              = data.aws_route53_zone.this.zone_id
  replication_region   = "us-east-1"
  bootstrap_mode       = var.bootstrap_mode
}
```

## Documentation

Full documentation lives at
**[infrahouse.github.io/terraform-aws-kibana](https://infrahouse.github.io/terraform-aws-kibana/)**:

- [Getting Started](https://infrahouse.github.io/terraform-aws-kibana/getting-started/) —
  prerequisites and the first deployment
- [Architecture](https://infrahouse.github.io/terraform-aws-kibana/architecture/) — what the module
  builds and how the pieces fit
- [Configuration](https://infrahouse.github.io/terraform-aws-kibana/configuration/) — the inputs, by
  topic
- [Examples](https://infrahouse.github.io/terraform-aws-kibana/examples/) — common configurations
- [Troubleshooting](https://infrahouse.github.io/terraform-aws-kibana/troubleshooting/) — what to
  check when Kibana does not come up
- [Upgrading](https://infrahouse.github.io/terraform-aws-kibana/upgrading/) — migrating between major
  versions, including 1.x → 3.x
- [Changelog](https://infrahouse.github.io/terraform-aws-kibana/changelog/) — release history

## Examples

Runnable configurations are in [`examples/`](examples/):

- [`examples/basic`](examples/basic) — the minimum configuration, in front of an Elasticsearch
  cluster that already exists
- [`examples/production`](examples/production) — Elasticsearch and Kibana together, private subnets
  only, SSH restricted, alarms wired up, access logs kept

## Contributing

Bug reports and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for the development
setup, the coding standards and the commit message format, and [SECURITY.md](SECURITY.md) for
reporting security issues.

## License

Apache License 2.0 — see [LICENSE](LICENSE).

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0, < 7.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kibana"></a> [kibana](#module\_kibana) | registry.infrahouse.com/infrahouse/ecs/aws | 8.1.0 |
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
| <a name="input_replication_region"></a> [replication\_region](#input\_replication\_region) | AWS region for cross-region replication of the ALB access-log bucket.<br/>Must differ from the region this module is deployed in. Required for Vanta<br/>DR compliance (the access-log bucket is an audit record that must get CRR). | `string` | n/a | yes |
| <a name="input_ssh_cidr_block"></a> [ssh\_cidr\_block](#input\_ssh\_cidr\_block) | CIDR range that is allowed to SSH into the backend instances | `string` | `null` | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | ssh key name installed in ECS host instances. | `string` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Zone where DNS records will be created for the service and certificate validation. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kibana_password"></a> [kibana\_password](#output\_kibana\_password) | Password for Kibana authentication |
| <a name="output_kibana_url"></a> [kibana\_url](#output\_kibana\_url) | URL where Kibana UI is available |
| <a name="output_kibana_username"></a> [kibana\_username](#output\_kibana\_username) | Username for Kibana authentication |
| <a name="output_load_balancer_arn"></a> [load\_balancer\_arn](#output\_load\_balancer\_arn) | ARN of the load balancer for Kibana service |
<!-- END_TF_DOCS -->
