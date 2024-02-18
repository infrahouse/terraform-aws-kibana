output "keypair_name" {
  value = aws_key_pair.test.key_name
}

output "subnet_private_ids" {
  value = module.service-network.subnet_private_ids
}

output "subnet_public_ids" {
  value = module.service-network.subnet_public_ids
}

output "cluster_name" {
  value = local.cluster_name
}

output "elasticsearch_url" {
  value = module.elasticsearch.cluster_master_url
}

output "internet_gateway_id" {
  value = module.service-network.internet_gateway_id
}

output "kibana_system_password" {
  sensitive = true
  value     = module.elasticsearch.kibana_system_password
}

output "ssh_key_name" {
  value = aws_key_pair.test.key_name
}

output "zone_id" {
  value = var.zone_id
}

output "elastic_password" {
  sensitive = true
  value     = module.elasticsearch.elastic_password
}
