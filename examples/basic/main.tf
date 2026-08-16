# Basic Example
# Kibana in front of an Elasticsearch cluster that already exists.

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

# The module also reads this zone with the default provider to build the Kibana
# URL, so the default provider must be able to read it too.
data "aws_route53_zone" "kibana" {
  provider = aws.dns
  name     = var.zone_name
}

module "kibana" {
  source  = "registry.infrahouse.com/infrahouse/kibana/aws"
  version = "4.0.0"

  providers = {
    aws     = aws
    aws.dns = aws.dns
  }

  # Kibana is published as <elasticsearch_cluster_name>-kibana.<zone domain>,
  # so the cluster name decides the hostname.
  elasticsearch_cluster_name = var.elasticsearch_cluster_name
  elasticsearch_url          = var.elasticsearch_url
  kibana_system_password     = var.kibana_system_password

  environment           = var.environment
  zone_id               = data.aws_route53_zone.kibana.zone_id
  asg_subnets           = var.asg_subnets
  load_balancer_subnets = var.load_balancer_subnets
  ssh_key_name          = var.ssh_key_name

  # Every address receives an SNS subscription confirmation email that must be
  # confirmed before alarm notifications are delivered.
  alert_emails = var.alert_emails

  # The ALB access-log bucket is replicated cross-region, so this must be a
  # different region than var.region.
  replication_region = var.replication_region
}
