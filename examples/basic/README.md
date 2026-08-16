# Basic Example

The minimum configuration required to deploy Kibana with the
terraform-aws-kibana module, in front of an Elasticsearch cluster that already
exists.

## What This Example Creates

- ECS cluster with an EC2 capacity provider and an Auto Scaling Group of
  `t3.medium` instances
- ECS service running `docker.elastic.co/kibana/kibana` on container port 5601
- Application Load Balancer with an HTTPS listener and an ACM certificate
  validated through Route53
- S3 bucket with the ALB access logs, replicated to `replication_region`
- Two Secrets Manager secrets: the Kibana encryption key and the
  `kibana_system` password, readable only by the ECS task execution role
- CloudWatch log group for the container logs and CloudWatch alarms publishing
  to an SNS topic subscribed by `alert_emails`
- DNS record `<elasticsearch_cluster_name>-kibana.<zone domain>` pointing at the
  load balancer

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.5
- A running Elasticsearch cluster (see
  [infrahouse/elasticsearch/aws](https://registry.terraform.io/modules/infrahouse/elasticsearch/aws/latest))
  and the password of its built-in `kibana_system` user
- A Route53 hosted zone for your domain
- Private subnets for the ECS instances and subnets for the load balancer
- An EC2 key pair

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars

terraform init
terraform apply -var="kibana_system_password=<kibana_system password>"
```

Then open the URL:

```bash
terraform output kibana_url
```

Sign in with the `elastic` user of your Elasticsearch cluster. The first
deployment takes several minutes: the ACM certificate has to be validated, the
EC2 instance has to join the ECS cluster, and Kibana has to migrate its saved
objects indices before `/login` starts answering the ALB health check.

## Inputs

| Name | Description |
|------|-------------|
| region | AWS region where Kibana is deployed |
| environment | Name of the environment Kibana belongs to |
| zone_name | Route53 hosted zone name, with a trailing dot |
| elasticsearch_cluster_name | Name of the Elasticsearch cluster Kibana connects to |
| elasticsearch_url | HTTPS endpoint of the Elasticsearch master nodes |
| kibana_system_password | Password of the built-in `kibana_system` user |
| asg_subnets | Private subnets where the ECS host instances run |
| load_balancer_subnets | Subnets where the load balancer is created |
| ssh_key_name | Name of an existing EC2 key pair |
| alert_emails | Addresses that receive CloudWatch alarm notifications |
| replication_region | Region the ALB access-log bucket is replicated to |

## Outputs

| Name | Description |
|------|-------------|
| kibana_url | URL where the Kibana UI is available |
| kibana_username | Elasticsearch user Kibana authenticates with |
| load_balancer_arn | ARN of the load balancer in front of Kibana |

## Notes

- The hostname is derived from the cluster name and cannot be set directly:
  Kibana is always published as
  `<elasticsearch_cluster_name>-kibana.<zone domain>`.
- `replication_region` must differ from `region` - the ALB access-log bucket is
  an audit record and gets cross-region replication.
- The module reads the hosted zone with **both** providers: `aws.dns` creates
  the records, and the default `aws` provider reads the zone name to build the
  Kibana URL. When the zone lives in another account, the default provider's
  role still needs `route53:GetHostedZone` on it.
- `load_balancer_subnets` may be public, but deploying the load balancer into
  private subnets and reaching it over a VPN keeps Kibana off the internet.
- For a throw-away deployment, add `access_log_force_destroy = true` so
  `terraform destroy` does not stop on a non-empty access-log bucket.
