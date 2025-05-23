module "kibana" {
  source = "../../"
  providers = {
    aws     = aws
    aws.dns = aws
  }
  asg_subnets                = var.asg_subnets
  elasticsearch_cluster_name = var.cluster_name
  elasticsearch_url          = var.elasticsearch_url
  internet_gateway_id        = var.internet_gateway_id
  kibana_system_password     = var.kibana_system_password
  load_balancer_subnets      = var.load_balancer_subnets
  ssh_key_name               = var.ssh_key_name
  zone_id                    = data.aws_route53_zone.test.zone_id
  access_log_force_destroy   = true

  elasticsearch_request_timeout = var.elasticsearch_request_timeout
}
