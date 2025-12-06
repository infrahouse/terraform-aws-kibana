resource "random_string" "kibana-encryptionKey" {
  length  = 32
  special = false
}

module "kibana-encryptionKey" {
  source             = "registry.infrahouse.com/infrahouse/secret/aws"
  version            = "1.1.1"
  environment        = var.environment
  secret_description = "Kibana encryption key for Elasticsearch cluster ${var.elasticsearch_cluster_name}"
  secret_name_prefix = "${var.elasticsearch_cluster_name}-kibana-"
  secret_value       = random_string.kibana-encryptionKey.result
  readers = [
    module.kibana.task_execution_role_arn
  ]
}

module "kibana-password" {
  source             = "registry.infrahouse.com/infrahouse/secret/aws"
  version            = "1.1.1"
  environment        = var.environment
  secret_description = "Kibana encryption key for Elasticsearch cluster ${var.elasticsearch_cluster_name}"
  secret_name_prefix = "${var.elasticsearch_cluster_name}-kibana-password-"
  secret_value       = local.kibana_password
  readers = [
    module.kibana.task_execution_role_arn
  ]
}
