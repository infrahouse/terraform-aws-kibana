# InfraHouse kibana

Terraform module that deploys [Kibana](https://www.elastic.co/kibana) on AWS ECS in front of an
existing Elasticsearch cluster: an ECS service behind an HTTPS load balancer, with the encryption
keys and the `kibana_system` password kept in AWS Secrets Manager.

It is a thin composition on top of the InfraHouse building blocks
([ecs](https://registry.terraform.io/modules/infrahouse/ecs/aws/latest),
[secret](https://registry.terraform.io/modules/infrahouse/secret/aws/latest)) — the module itself
owns a single IAM policy and the random encryption key, everything else comes from those modules.

## Features

- **Kibana on ECS** — the official `docker.elastic.co/kibana/kibana` image runs as an ECS service on
  an EC2-backed Auto Scaling Group, sized (`t3.medium`, 1 vCPU / 2 GB for the container) for a Kibana
  workload. `kibana_version` pins the tag so it can be kept on the version your cluster runs.
- **HTTPS out of the box** — an Application Load Balancer with an ACM certificate that is issued and
  DNS-validated in your Route53 zone, published as
  `https://<elasticsearch_cluster_name>-kibana.<zone domain>`.
- **No secrets in the task definition** — the three X-Pack encryption keys and the `kibana_system`
  password live in Secrets Manager and are injected as ECS `secrets`, readable only by the task
  execution role.
- **Long-running searches survive** — the load balancer idle timeout and Kibana's Elasticsearch
  request timeout are driven by a single input, so the ALB never cuts a search off before Kibana
  does.
- **Monitored** — container logs go to CloudWatch, CloudWatch alarms publish to an SNS topic your
  `alert_emails` are subscribed to, and the ALB access logs land in an S3 bucket that is replicated
  cross-region for audit retention.
- **Spot-capable** — set `on_demand_base_capacity` and the Auto Scaling Group backs Kibana with spot
  instances above that baseline.

## Quick start

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
  version = "3.0.1" # always pin an exact release

  providers = {
    aws     = aws
    aws.dns = aws.dns
  }

  elasticsearch_cluster_name = "elastic"
  elasticsearch_url          = module.elasticsearch.cluster_master_url
  kibana_system_password     = module.elasticsearch.kibana_system_password

  environment           = "production"
  zone_id               = data.aws_route53_zone.this.zone_id
  asg_subnets           = var.private_subnet_ids
  load_balancer_subnets = var.private_subnet_ids
  ssh_key_name          = var.key_pair_name
  alert_emails          = ["ops@example.com"]
  replication_region    = "us-east-1" # must differ from the deploy region
}
```

Kibana is reachable at the `kibana_url` output once the ECS service becomes healthy. Sign in with an
Elasticsearch user — the `elastic` superuser the first time.

## Documentation

- [Getting Started](getting-started.md) — prerequisites and the first deployment
- [Architecture](architecture.md) — what the module builds and how the pieces fit
- [Configuration](configuration.md) — the inputs, by topic
- [Examples](examples.md) — basic and production configurations
- [Troubleshooting](troubleshooting.md) — what to check when Kibana does not come up
- [Upgrading](upgrading.md) — migrating between major versions
- [Changelog](changelog.md) — release history
