data "aws_route53_zone" "kibana_zone" {
  zone_id = var.zone_id
}
