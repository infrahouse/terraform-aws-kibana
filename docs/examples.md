# Examples

Complete, runnable configurations live in the
[`examples/`](https://github.com/infrahouse/terraform-aws-kibana/tree/main/examples) directory:

| Example | What it shows |
|---------|---------------|
| [`basic`](https://github.com/infrahouse/terraform-aws-kibana/tree/main/examples/basic) | The minimum configuration: Kibana in front of an Elasticsearch cluster that already exists. |
| [`production`](https://github.com/infrahouse/terraform-aws-kibana/tree/main/examples/production) | Elasticsearch and Kibana together, private subnets only, SSH restricted, alarms wired up, access logs kept. |

The snippets below cover the situations that come up most often.

## Kibana for an existing cluster

The smallest configuration that works. Everything not listed here uses the module defaults.

```hcl
module "kibana" {
  source  = "registry.infrahouse.com/infrahouse/kibana/aws"
  version = "4.0.0"

  providers = {
    aws     = aws
    aws.dns = aws.dns
  }

  elasticsearch_cluster_name = "elastic"
  elasticsearch_url          = "https://elastic-master.ci-cd.infrahouse.com"
  kibana_system_password     = var.kibana_system_password

  environment           = "development"
  zone_id               = data.aws_route53_zone.this.zone_id
  asg_subnets           = var.private_subnet_ids
  load_balancer_subnets = var.public_subnet_ids
  ssh_key_name          = var.key_pair_name
  alert_emails          = ["ops-team@example.com"]
  replication_region    = "us-east-1"
}
```

## Wiring it to the elasticsearch module

The cluster module hands over both values Kibana needs, so the `kibana_system` password never has to
be copied by an operator:

```hcl
module "elasticsearch" {
  source  = "registry.infrahouse.com/infrahouse/elasticsearch/aws"
  version = "5.2.0"

  providers = {
    aws     = aws
    aws.dns = aws.dns
  }

  cluster_name        = "elastic"
  environment         = "production"
  key_pair_name       = var.key_pair_name
  subnet_ids          = var.private_subnet_ids
  zone_id             = data.aws_route53_zone.this.zone_id
  replication_region  = "us-east-1"
  alarm_emails        = ["ops-team@example.com"]
  idle_timeout_master = 4000

  # Apply once with true to form the cluster, then flip to false and apply again.
  bootstrap_mode = var.bootstrap_mode
}

module "kibana" {
  source  = "registry.infrahouse.com/infrahouse/kibana/aws"
  version = "4.0.0"

  providers = {
    aws     = aws
    aws.dns = aws.dns
  }

  elasticsearch_cluster_name = "elastic"
  elasticsearch_url          = module.elasticsearch.cluster_master_url
  kibana_system_password     = module.elasticsearch.kibana_system_password

  # Keep Kibana's timeout equal to the masters' load balancer idle timeout.
  elasticsearch_request_timeout = module.elasticsearch.idle_timeout_master

  environment           = "production"
  zone_id               = data.aws_route53_zone.this.zone_id
  asg_subnets           = var.private_subnet_ids
  load_balancer_subnets = var.private_subnet_ids
  ssh_key_name          = var.key_pair_name
  alert_emails          = ["ops-team@example.com"]
  replication_region    = "us-east-1"
}
```

Kibana only becomes healthy after the second Elasticsearch apply (`bootstrap_mode = false`), when the
cluster has actually formed.

## Internal Kibana, reachable over the VPN

Put the load balancer in the private subnets and restrict SSH to the admin network:

```hcl
  asg_subnets           = var.private_subnet_ids
  load_balancer_subnets = var.private_subnet_ids
  ssh_cidr_block        = "10.1.0.0/16"
```

The DNS record and the ACM certificate are created exactly the same way; the record simply resolves
to private addresses.

## Cheaper non-production deployment

Spot capacity above a single on-demand instance, and an access-log bucket that does not block
`terraform destroy`:

```hcl
  on_demand_base_capacity  = 1
  access_log_force_destroy = true
  environment              = "development"
```

Keep `access_log_force_destroy = false` in production — the access logs are an audit record.

## Extra load balancer rules

`load_balancer_arn` is exported so you can attach your own listener rules, a WAF web ACL, or extra
monitoring to the load balancer the module created:

```hcl
resource "aws_wafv2_web_acl_association" "kibana" {
  resource_arn = module.kibana.load_balancer_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}
```
