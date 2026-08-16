variable "access_log_force_destroy" {
  description = "Destroy S3 bucket with access logs even if non-empty"
  type        = bool
  default     = false
}

variable "alert_emails" {
  description = "List of email addresses for CloudWatch alarm notifications"
  type        = list(string)
}

variable "ami_id" {
  description = "Image for host EC2 instances. If not specified, the latest Amazon image will be used."
  type        = string
  default     = null
}

variable "asg_subnets" {
  description = "Auto Scaling Group Subnets."
  type        = list(string)
}

variable "elasticsearch_cluster_name" {
  description = "Elasticsearch cluster name."
  type        = string
}

variable "elasticsearch_url" {
  description = "URL of Elasticsearch masters."
  type        = string
}

variable "elasticsearch_request_timeout" {
  description = "Elasticsearch request timeout in seconds."
  type        = number
  default     = 4000
}

variable "environment" {
  description = "Name of environment."
  type        = string
  default     = "development"

  # The secret module applies the same rule. Validating here fails the plan on
  # this module's own input instead of deep inside a child module.
  validation {
    condition     = can(regex("^[a-z0-9_]+$", var.environment))
    error_message = "environment must contain only lowercase letters, numbers, and underscores (no hyphens). Got: ${var.environment}"
  }
}

variable "kibana_version" {
  description = <<-EOT
    Version of the Kibana Docker image to run.
    Elastic supports Kibana and Elasticsearch only on the same version (during an
    upgrade Elasticsearch may lead by one minor), so this must match the version
    of the cluster in elasticsearch_url. In InfraHouse deployments the cluster
    version comes from the Puppet hiera key
    profile::elastic::packages::elasticsearch_version.
  EOT
  type        = string
  # renovate: datasource=docker depName=docker.elastic.co/kibana/kibana
  default = "8.15.0"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+(-[0-9A-Za-z.]+)?$", var.kibana_version))
    error_message = "kibana_version must be an exact version such as 8.15.0, not a floating tag. Got: ${var.kibana_version}"
  }
}

variable "kibana_system_password" {
  description = "Password for kibana_system user. This user is an Elasticsearch built-in user."
  type        = string
  sensitive   = true
}

variable "load_balancer_subnets" {
  description = "Load Balancer Subnets."
  type        = list(string)
}

variable "ssh_cidr_block" {
  description = "CIDR range that is allowed to SSH into the backend instances"
  type        = string
  default     = null
}

variable "ssh_key_name" {
  description = "ssh key name installed in ECS host instances."
  type        = string
}

variable "zone_id" {
  description = "Zone where DNS records will be created for the service and certificate validation."
  type        = string
}

variable "extra_instance_profile_permissions" {
  description = "A JSON with a permissions policy document. The policy will be attached to the ASG instance profile."
  type        = string
  default     = null
}

variable "cloudinit_extra_commands" {
  description = "Extra commands for run on ASG."
  type        = list(string)
  default     = []
}

variable "on_demand_base_capacity" {
  description = "If specified, the ASG will request spot instances and this will be the minimal number of on-demand instances."
  type        = number
  default     = null
}

variable "replication_region" {
  description = <<-EOT
    AWS region for cross-region replication of the ALB access-log bucket.
    Must differ from the region this module is deployed in. Required for Vanta
    DR compliance (the access-log bucket is an audit record that must get CRR).
  EOT
  type        = string
}
