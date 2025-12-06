locals {
  module_version = "2.0.0"

  kibana_url      = "https://${var.elasticsearch_cluster_name}-kibana.${data.aws_route53_zone.kibana_zone.name}"
  kibana_username = "kibana_system"
  kibana_password = var.kibana_system_password
  service_name    = "${var.elasticsearch_cluster_name}-kibana"
  default_module_tags = {
    environment : var.environment
    service : local.service_name
    account : data.aws_caller_identity.current.account_id
    created_by_module : "infrahouse/kibana/aws"
  }
}
