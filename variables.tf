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

variable "ssh_key_name" {
  description = "ssh key name installed in ECS host instances."
  type        = string
}

variable "zone_id" {
  description = "Zone where DNS records will be created for the service and certificate validation."
  type        = string
}
