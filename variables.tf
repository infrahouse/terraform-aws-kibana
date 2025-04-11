variable "access_log_force_destroy" {
  description = "Destroy S3 bucket with access logs even if non-empty"
  type        = bool
  default     = false
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
}

variable "internet_gateway_id" {
  description = "Internet gateway id. Usually created by 'infrahouse/service-network/aws'"
  type        = string
}

variable "kibana_system_password" {
  description = "Password for kibana_system user. This user is an Elasticsearch built-in user."
  type        = string
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
