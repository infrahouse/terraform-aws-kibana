variable "elasticsearch_request_timeout" {
}
variable "environment" {
  default = "development"
}
variable "region" {}
variable "role_arn" {
  default = null
}
variable "test_zone_id" {}

variable "alert_emails" {
}
variable "asg_subnets" {
}
variable "cluster_name" {
}
variable "elasticsearch_url" {
}
variable "kibana_system_password" {
}
variable "load_balancer_subnets" {
}
variable "ssh_key_name" {
}
