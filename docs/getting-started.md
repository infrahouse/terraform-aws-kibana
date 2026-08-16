# Getting Started

## Prerequisites

Before deploying this module you need:

- **Terraform** `~> 1.5`.
- **AWS provider** `>= 6.0, < 7.0`. Support for provider v5 was dropped — the module is tested
  against v6 only.
- **Two AWS provider configurations.** The module requires a default `aws` provider and a second
  `aws.dns` aliased provider that is used for the Route53 records. They can point at the same
  account or, when the hosted zone lives elsewhere, at different accounts. The default provider must
  still be able to *read* the zone — the module looks it up to build the Kibana URL.
- **A running Elasticsearch cluster.** Kibana cannot be deployed on its own. The
  [infrahouse/elasticsearch/aws](https://registry.terraform.io/modules/infrahouse/elasticsearch/aws/latest)
  module provisions one; its `cluster_master_url` and `kibana_system_password` outputs are exactly
  what this module needs. The cluster has to be up (masters and data nodes running) before Kibana
  starts, otherwise the ECS task fails its health check and the service keeps cycling.
- **A VPC with subnets.** You supply:
    - `asg_subnets` — private subnets for the ECS host instances. They need outbound internet access
      (NAT gateway) to pull the Kibana image.
    - `load_balancer_subnets` — subnets for the load balancer. Public subnets publish Kibana on the
      internet; private subnets keep it behind your VPN.
- **A Route53 hosted zone** (`zone_id`). Kibana is published at
  `https://<elasticsearch_cluster_name>-kibana.<zone domain>` and the ACM certificate is validated in
  this zone.
- **An EC2 key pair** (`ssh_key_name`) installed on the ECS host instances.
- **A second region for access-log replication** (`replication_region`) that differs from the region
  you deploy to.
- **Alarm recipients** (`alert_emails`). AWS sends SNS subscription confirmation emails that must be
  accepted before any notification is delivered.

## Required inputs

| Input | Description |
|-------|-------------|
| `elasticsearch_cluster_name` | Name of the Elasticsearch cluster. Also the prefix of every resource and of the DNS record. |
| `elasticsearch_url` | HTTPS endpoint of the Elasticsearch master nodes. |
| `kibana_system_password` | Password of the built-in `kibana_system` user. |
| `zone_id` | Route53 hosted zone ID for the Kibana DNS record and certificate validation. |
| `asg_subnets` | Private subnets for the ECS host instances. |
| `load_balancer_subnets` | Subnets for the load balancer. |
| `ssh_key_name` | EC2 key pair installed on the ECS host instances. |
| `alert_emails` | Email addresses subscribed to the alarm SNS topic. |
| `replication_region` | Region for cross-region replication of the ALB access-log bucket (must differ from the deploy region). |

See [Configuration](configuration.md) for the full set of inputs and their defaults.

## First deployment

1. Deploy (or locate) the Elasticsearch cluster and note two values: the master URL and the
   `kibana_system` password. With the InfraHouse module both are outputs, so you can wire them
   directly and the password never has to be copied by hand.

2. Declare the two providers and the module (see the [Quick start](index.md#quick-start), or copy
   [`examples/basic`](https://github.com/infrahouse/terraform-aws-kibana/tree/main/examples/basic)).

3. Apply:

    ```bash
    terraform init
    terraform apply
    ```

4. Confirm the SNS subscription emails sent to every address in `alert_emails`.

5. Wait for the service to become healthy. The first deployment takes several minutes: ACM has to
   validate the certificate through Route53, the EC2 instance has to join the ECS cluster, and Kibana
   has to migrate its saved-objects indices in Elasticsearch before `/login` answers the ALB health
   check. The ASG and the ECS service both get a 900-second health-check grace period for exactly
   this reason.

6. Open the URL:

    ```bash
    terraform output kibana_url
    ```

   Sign in with an Elasticsearch user — the `elastic` superuser the first time. The `kibana_username`
   and `kibana_password` outputs are **not** login credentials: they are the `kibana_system` service
   account Kibana itself uses to talk to Elasticsearch.

## What you get

| Resource | Purpose |
|----------|---------|
| ECS cluster, capacity provider, Auto Scaling Group | `t3.medium` EC2 hosts that run the Kibana task. |
| ECS service and task definition | One Kibana container on port 5601, 1 vCPU / 2 GB. |
| Application Load Balancer, ACM certificate, Route53 record | HTTPS endpoint at `<cluster>-kibana.<zone domain>`. |
| S3 bucket + replica | ALB access logs, replicated to `replication_region`. |
| Two Secrets Manager secrets | X-Pack encryption key and the `kibana_system` password. |
| IAM policy on the task execution role | `secretsmanager:GetSecretValue` on exactly those two secrets. |
| CloudWatch log group, alarms, SNS topic | Container logs (`/ecs/<environment>/<cluster>-kibana`) and alarm notifications. |

## Next steps

- [Architecture](architecture.md) — how the pieces fit together.
- [Examples](examples.md) — a production-shaped configuration.
- [Troubleshooting](troubleshooting.md) — when the service does not stabilize.
