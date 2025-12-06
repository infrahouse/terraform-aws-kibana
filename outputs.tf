output "kibana_url" {
  description = "URL where Kibana UI is available"
  value       = local.kibana_url
}

output "kibana_username" {
  description = "Username for Kibana authentication"
  value       = local.kibana_username
}

output "kibana_password" {
  description = "Password for Kibana authentication"
  value       = local.kibana_password
  sensitive   = true
}

output "load_balancer_arn" {
  description = "ARN of the load balancer for Kibana service"
  value       = module.kibana.load_balancer_arn
}
