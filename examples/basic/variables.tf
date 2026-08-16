variable "region" {
  description = "AWS region where Kibana is deployed."
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Name of the environment Kibana belongs to."
  type        = string
  default     = "development"
}

variable "zone_name" {
  description = <<-EOT
    Route53 hosted zone name where the Kibana DNS record is created, with a
    trailing dot. For example, "ci-cd.infrahouse.com.".
  EOT
  type        = string
}

variable "elasticsearch_cluster_name" {
  description = <<-EOT
    Name of the Elasticsearch cluster Kibana connects to. It is also the prefix
    of every name this module creates, including the DNS record
    <elasticsearch_cluster_name>-kibana.<zone domain>.
  EOT
  type        = string
}

variable "elasticsearch_url" {
  description = <<-EOT
    HTTPS endpoint of the Elasticsearch master nodes, for example
    https://elastic-master.ci-cd.infrahouse.com. This is the cluster_master_url
    output of the infrahouse/elasticsearch/aws module.
  EOT
  type        = string
}

variable "kibana_system_password" {
  description = <<-EOT
    Password of the built-in Elasticsearch user kibana_system. The
    infrahouse/elasticsearch/aws module exposes it as the
    kibana_system_password output.
  EOT
  type        = string
  sensitive   = true
}

variable "asg_subnets" {
  description = <<-EOT
    Private subnets where the ECS host instances run. Kibana instances must not
    be reachable from the internet.
  EOT
  type        = list(string)
}

variable "load_balancer_subnets" {
  description = <<-EOT
    Subnets where the load balancer is created. Public subnets publish Kibana on
    the internet; private subnets keep it behind your VPN.
  EOT
  type        = list(string)
}

variable "ssh_key_name" {
  description = "Name of an existing EC2 key pair installed on the ECS host instances."
  type        = string
}

variable "alert_emails" {
  description = "Email addresses that receive CloudWatch alarm notifications."
  type        = list(string)
}

variable "replication_region" {
  description = <<-EOT
    Region the ALB access-log bucket is replicated to. Must differ from
    var.region.
  EOT
  type        = string
  default     = "us-east-1"
}
