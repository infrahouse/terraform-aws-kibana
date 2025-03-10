output "kibana_url" {
  value = local.kibana_url
}

output "kibana_username" {
  value = local.kibana_username
}

output "kibana_password" {
  value = local.kibana_password
}

output "load_balancer_arn" {
  value = module.kibana.load_balancer_arn
}
