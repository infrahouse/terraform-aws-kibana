output "kibana_url" {
  value = module.kibana.kibana_url
}

output "kibana_username" {
  value = module.kibana.kibana_username
}

output "kibana_password" {
  sensitive = true
  value     = module.kibana.kibana_password
}
