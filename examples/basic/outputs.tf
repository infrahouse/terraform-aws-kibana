output "kibana_url" {
  description = "URL where the Kibana UI is available"
  value       = module.kibana.kibana_url
}

output "kibana_username" {
  description = "Elasticsearch user Kibana authenticates with"
  value       = module.kibana.kibana_username
}

output "load_balancer_arn" {
  description = "ARN of the load balancer in front of Kibana"
  value       = module.kibana.load_balancer_arn
}
