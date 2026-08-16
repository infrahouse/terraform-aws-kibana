# Production Example
# An Elasticsearch cluster and the Kibana instance that fronts it, sized and
# locked down for production use.

terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      created_by = "infrahouse/terraform-aws-kibana"
    }
  }
}

# The hosted zone may live in another AWS account. Point this alias at the
# account that owns the zone - add assume_role here when that is the case.
provider "aws" {
  alias  = "dns"
  region = var.region

  default_tags {
    tags = {
      created_by = "infrahouse/terraform-aws-kibana"
    }
  }
}

data "aws_route53_zone" "cluster" {
  provider = aws.dns
  name     = var.zone_name
}

# The Elasticsearch cluster Kibana talks to. It needs two applies: the first one
# with bootstrap_mode = true to form the cluster, the second with
# bootstrap_mode = false. Kibana can only be deployed after the second apply.
module "elasticsearch" {
  source  = "registry.infrahouse.com/infrahouse/elasticsearch/aws"
  version = "5.2.0"

  providers = {
    aws     = aws
    aws.dns = aws.dns
  }

  cluster_name       = var.elasticsearch_cluster_name
  environment        = var.environment
  key_pair_name      = var.ssh_key_name
  subnet_ids         = var.private_subnets
  zone_id            = data.aws_route53_zone.cluster.zone_id
  replication_region = var.replication_region
  alarm_emails       = var.alert_emails
  bootstrap_mode     = var.bootstrap_mode

  cluster_master_count = 3
  cluster_data_count   = 3

  # Long-running searches from Kibana need a generous ALB idle timeout on the
  # master nodes - it is what elasticsearch_request_timeout is matched to below.
  idle_timeout_master = 4000

  ssh_cidr_block = var.admin_cidr_block
}

module "kibana" {
  source  = "registry.infrahouse.com/infrahouse/kibana/aws"
  version = "3.0.1"

  providers = {
    aws     = aws
    aws.dns = aws.dns
  }

  # Published as <elasticsearch_cluster_name>-kibana.<zone domain>.
  elasticsearch_cluster_name = var.elasticsearch_cluster_name
  elasticsearch_url          = module.elasticsearch.cluster_master_url
  kibana_system_password     = module.elasticsearch.kibana_system_password

  environment  = var.environment
  zone_id      = data.aws_route53_zone.cluster.zone_id
  ssh_key_name = var.ssh_key_name

  # Both the instances and the load balancer stay in private subnets: Kibana is
  # reached over the VPN, not over the internet.
  asg_subnets           = var.private_subnets
  load_balancer_subnets = var.private_subnets

  # Only the admin network may SSH into the ECS host instances.
  ssh_cidr_block = var.admin_cidr_block

  # Every address receives an SNS subscription confirmation email that must be
  # confirmed before alarm notifications are delivered.
  alert_emails = var.alert_emails

  # The ALB access-log bucket is replicated cross-region, so this must be a
  # different region than var.region. Keep force_destroy off in production - the
  # access logs are an audit record.
  replication_region       = var.replication_region
  access_log_force_destroy = false

  # Match the ALB idle timeout of the Elasticsearch masters, otherwise long
  # searches are cut off by the load balancer before Kibana gives up.
  elasticsearch_request_timeout = module.elasticsearch.idle_timeout_master

  # The baseline instance is on-demand; anything the Auto Scaling Group adds on
  # top of it comes from cheaper spot capacity.
  on_demand_base_capacity = 1
}
