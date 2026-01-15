module "kibana" {
  source  = "registry.infrahouse.com/infrahouse/ecs/aws"
  version = "7.3.0"
  providers = {
    aws     = aws
    aws.dns = aws.dns
  }
  service_name                              = local.service_name
  docker_image                              = "docker.elastic.co/kibana/kibana:8.12.0"
  load_balancer_subnets                     = var.load_balancer_subnets
  ami_id                                    = var.ami_id
  asg_subnets                               = var.asg_subnets
  zone_id                                   = var.zone_id
  dns_names                                 = ["${var.elasticsearch_cluster_name}-kibana"]
  alarm_emails                              = var.alert_emails
  ssh_key_name                              = var.ssh_key_name
  ssh_cidr_block                            = var.ssh_cidr_block
  container_port                            = 5601
  container_healthcheck_command             = "curl -sqf http://localhost:5601/status || exit 1"
  healthcheck_path                          = "/login"
  cloudinit_extra_commands                  = var.cloudinit_extra_commands
  healthcheck_response_code_matcher         = "200"
  enable_cloudwatch_logs                    = true
  on_demand_base_capacity                   = var.on_demand_base_capacity
  access_log_force_destroy                  = var.access_log_force_destroy
  extra_instance_profile_permissions        = var.extra_instance_profile_permissions
  idle_timeout                              = var.elasticsearch_request_timeout
  asg_health_check_grace_period             = 900
  service_health_check_grace_period_seconds = 900

  asg_instance_type = "t3.medium" # 2vCPU, 4GB RAM
  container_cpu     = 1024        # One vCPU is 1024
  container_memory  = 2 * 1024    # Value in MB
  environment       = var.environment
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
        name : "SERVER_PUBLICBASEURL",
        value : local.kibana_url
      },
      {
        name : "ELASTICSEARCH_USERNAME",
        value : local.kibana_username
      },
      {
        name : "ELASTICSEARCH_REQUEST_TIMEOUT",
        value : var.elasticsearch_request_timeout * 1000
      }
    ],
  )
  execution_extra_policy = {
    "allow_secrets" : aws_iam_policy.task_role_exec.arn
  }
  task_secrets = [
    {
      name : "XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY",
      valueFrom : module.kibana-encryptionKey.secret_arn
    },
    {
      name : "XPACK_SECURITY_ENCRYPTIONKEY",
      valueFrom : module.kibana-encryptionKey.secret_arn
    },
    {
      name : "XPACK_REPORTING_ENCRYPTIONKEY",
      valueFrom : module.kibana-encryptionKey.secret_arn
    },
    {
      name : "ELASTICSEARCH_PASSWORD",
      valueFrom : module.kibana-password.secret_arn
    },
  ]

}
