# Configuration

This page explains the inputs by topic. The **complete, authoritative list** of variables, types and
defaults is the auto-generated table in the
[README](https://github.com/infrahouse/terraform-aws-kibana#readme) (the terraform-docs block).

## Required inputs

| Variable | Description |
|----------|-------------|
| `elasticsearch_cluster_name` | Name of the Elasticsearch cluster. Also the prefix of every resource this module creates and of the DNS record. |
| `elasticsearch_url` | HTTPS endpoint of the Elasticsearch master nodes, e.g. `https://elastic-master.ci-cd.infrahouse.com`. |
| `kibana_system_password` | Password of the built-in `kibana_system` Elasticsearch user. Sensitive. |
| `zone_id` | Route53 hosted zone ID for the DNS record and the ACM certificate validation. |
| `asg_subnets` | Subnets for the ECS host instances. |
| `load_balancer_subnets` | Subnets for the load balancer. |
| `ssh_key_name` | EC2 key pair installed on the ECS host instances. |
| `alert_emails` | Email addresses subscribed to the alarm SNS topic. |
| `replication_region` | Region for cross-region replication of the ALB access-log bucket. **Must differ** from the deploy region. |

## Elasticsearch connection

- `elasticsearch_cluster_name` — the hostname is derived from it
  (`<elasticsearch_cluster_name>-kibana.<zone domain>`); there is no separate hostname input.
- `elasticsearch_url` — where Kibana sends its requests. With the InfraHouse elasticsearch module
  this is the `cluster_master_url` output.
- `kibana_system_password` — the built-in `kibana_system` user, not a login for humans. With the
  InfraHouse elasticsearch module this is the `kibana_system_password` output, so the value can be
  wired directly and never has to be handled by an operator.
- `elasticsearch_request_timeout` (default `4000`, seconds) — sets **both** Kibana's
  `ELASTICSEARCH_REQUEST_TIMEOUT` (in milliseconds) and the ALB idle timeout. Match it to the idle
  timeout of the load balancer in front of the Elasticsearch masters. See
  [Architecture → Timeouts](architecture.md#timeouts).

## Networking

- `asg_subnets` — private subnets for the ECS host instances. They need outbound internet access
  through a NAT gateway to pull the Kibana image. The first subnet also determines the VPC.
- `load_balancer_subnets` — public subnets publish Kibana on the internet; private subnets keep it
  behind your VPN, which is the recommended deployment.
- `ssh_cidr_block` (default `null`) — CIDR range allowed to SSH into the ECS host instances. Leave it
  unset, or scope it to your admin network; never `0.0.0.0/0`.
- `zone_id` — the hosted zone. The `aws.dns` provider creates the records in it, and the default
  `aws` provider reads it to build the Kibana URL.

## Compute

- `ami_id` (default `null`) — image for the ECS host instances. The latest ECS-optimized Amazon image
  is used when unset.
- `on_demand_base_capacity` (default `null`) — when set, the Auto Scaling Group requests spot
  instances and keeps this many on-demand instances as the baseline. Kibana is stateless, so spot is
  a reasonable trade.
- `cloudinit_extra_commands` (default `[]`) — extra commands to run on the ECS host instances at
  boot.
- `extra_instance_profile_permissions` (default `null`) — a JSON IAM policy document attached to the
  ASG instance profile.

The instance type (`t3.medium`), the container size (1 vCPU, 2 GB) and the Kibana image tag are fixed
by the module and are not exposed as inputs.

## Logging and monitoring

- `alert_emails` — every address receives an SNS subscription confirmation email that must be
  accepted before alarm notifications are delivered.
- `replication_region` — the ALB access-log bucket is an audit record, so it gets cross-region
  replication. Must be a different region than the one you deploy to.
- `access_log_force_destroy` (default `false`) — allows `terraform destroy` to delete a non-empty
  access-log bucket. Useful for test and demo deployments, dangerous in production.

Container logs go to CloudWatch unconditionally.

## Tagging

- `environment` (default `"development"`) — set it explicitly. It ends up on the module's resources
  and on the secrets, and a stray `development` in a production account is exactly the confusion the
  InfraHouse [coding standard](https://github.com/infrahouse/terraform-aws-kibana/blob/main/.claude/CODING_STANDARD.md)
  warns about. Only lowercase letters, numbers and underscores are accepted — `pre_prod`, not
  `pre-prod`.

## Outputs

| Output | Description |
|--------|-------------|
| `kibana_url` | URL where the Kibana UI is available. |
| `kibana_username` | The Elasticsearch user Kibana authenticates with (`kibana_system`). |
| `kibana_password` | That user's password (sensitive) — the value you passed in. |
| `load_balancer_arn` | ARN of the load balancer, e.g. to attach extra listener rules or WAF. |

`kibana_username` / `kibana_password` are the **service account** Kibana uses to talk to
Elasticsearch, not credentials for signing in to the UI. Human users sign in with Elasticsearch
users, starting with `elastic`.
