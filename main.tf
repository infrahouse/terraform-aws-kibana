module "kibana" {
  source = "infrahouse/ecs/aws"
  version = "= 2.6.1"
  providers = {
    aws     = aws
    aws.dns = aws.dns
  }
  service_name                          = "${var.elasticsearch_cluster_name}-kibana"
  docker_image                          = "docker.elastic.co/kibana/kibana:8.12.0"
  load_balancer_subnets                 = var.load_balancer_subnets
  asg_subnets                           = var.asg_subnets
  zone_id                               = var.zone_id
  dns_names                             = ["${var.elasticsearch_cluster_name}-kibana"]
  internet_gateway_id                   = var.internet_gateway_id
  ssh_key_name                          = var.ssh_key_name
  container_port                        = 5601
  container_healthcheck_command         = "curl -sqf http://localhost:5601/status || exit 1"
  alb_healthcheck_path                  = "/login"
  alb_healthcheck_response_code_matcher = "200"
  alb_idle_timeout                      = 600
  task_desired_count                    = 1
  asg_health_check_grace_period         = 900
  alb_healthcheck_interval              = 300
  asg_min_size                          = 1
  asg_instance_type                     = "t3.medium" # 2vCPU, 4GB RAM
  container_cpu                         = 1024        # One vCPU is 1024
  container_memory                      = 2 * 1024    # Value in MB
  environment                           = var.environment
  task_environment_variables = concat(
    [
      {
        name : "SERVER_NAME",
        value : "${var.elasticsearch_cluster_name}-kibana.${data.aws_route53_zone.kibana_zone.name}"
      },
      {
        name : "ELASTICSEARCH_HOSTS",
        value : var.elasticsearch_url
      },
      {
        name : "XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY",
        value : random_string.kibana-encryptionKey.result
      },
      {
        name : "XPACK_SECURITY_ENCRYPTIONKEY",
        value : random_string.kibana-encryptionKey.result
      },
      {
        name : "XPACK_REPORTING_ENCRYPTIONKEY",
        value : random_string.kibana-encryptionKey.result
      },
      {
        name : "SERVER_PUBLICBASEURL",
        value : local.kibana_url
      },
      {
        name : "ELASTICSEARCH_USERNAME",
        value : local.kibana_username
      },
      {
        name : "ELASTICSEARCH_PASSWORD",
        value : local.kibana_password
      },
    ],
  )
}

resource "random_string" "kibana-encryptionKey" {
  length  = 32
  special = false
}
