variable "region" {
  description = "AWS region where the Elasticsearch cluster and Kibana are deployed."
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Name of the environment Kibana belongs to."
  type        = string
}

variable "zone_name" {
  description = <<-EOT
    Route53 hosted zone name where the Elasticsearch and Kibana DNS records are
    created, with a trailing dot. For example, "ci-cd.infrahouse.com.".
  EOT
  type        = string
}

variable "elasticsearch_cluster_name" {
  description = <<-EOT
    Name of the Elasticsearch cluster. It is also the prefix of the Kibana
    resources and of the DNS record
    <elasticsearch_cluster_name>-kibana.<zone domain>.
  EOT
  type        = string
  default     = "elastic"
}

variable "private_subnets" {
  description = <<-EOT
    Private subnets that host the Elasticsearch nodes, the Kibana ECS instances
    and both load balancers. Use at least three subnets in different
    availability zones so the master quorum survives an availability zone
    outage.
  EOT
  type        = list(string)

  validation {
    condition     = length(var.private_subnets) >= 2
    error_message = "At least 2 subnets are required for high availability. Provided: ${length(var.private_subnets)}"
  }
}

variable "ssh_key_name" {
  description = <<-EOT
    Name of an existing EC2 key pair installed on the Elasticsearch nodes and on
    the Kibana ECS host instances.
  EOT
  type        = string
}

variable "admin_cidr_block" {
  description = <<-EOT
    CIDR range allowed to SSH into the instances, for example the VPN network.
    Never set this to 0.0.0.0/0 in production.
  EOT
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr_block, 0))
    error_message = "admin_cidr_block must be a valid IPv4 CIDR block (e.g., 10.0.0.0/16). Got: ${var.admin_cidr_block}"
  }
}

variable "alert_emails" {
  description = "Email addresses that receive CloudWatch alarm notifications."
  type        = list(string)

  validation {
    condition     = length(var.alert_emails) > 0
    error_message = "At least one address is required, otherwise nobody is notified when an alarm fires."
  }
}

variable "replication_region" {
  description = <<-EOT
    Region the ALB access-log buckets are replicated to. Must differ from
    var.region.
  EOT
  type        = string
  default     = "us-east-1"
}

variable "bootstrap_mode" {
  description = <<-EOT
    Elasticsearch cluster bootstrap flag. Apply once with true to form the
    cluster, then set it back to false and apply again. Kibana only becomes
    healthy after the second apply.
  EOT
  type        = bool
  default     = false
}
