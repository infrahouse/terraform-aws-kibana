locals {
  kibana_url      = "https://${var.elasticsearch_cluster_name}-kibana.${data.aws_route53_zone.kibana_zone.name}"
  kibana_username = "kibana_system"
  kibana_password = var.kibana_system_password
}
