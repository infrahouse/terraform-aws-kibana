# Production Example

An Elasticsearch cluster and the Kibana instance in front of it, sized and
locked down for production: private subnets only, SSH restricted to the admin
network, alarms wired to an on-call address, and the ALB access logs kept.

## What This Example Creates

- Elasticsearch cluster with three master and three data nodes
  ([infrahouse/elasticsearch/aws](https://registry.terraform.io/modules/infrahouse/elasticsearch/aws/latest))
- ECS cluster, Auto Scaling Group and ECS service running Kibana, with the
  baseline instance on-demand and extra capacity on spot
- Internal Application Load Balancer with an HTTPS listener and an ACM
  certificate validated through Route53
- Secrets Manager secrets holding the Kibana encryption key and the
  `kibana_system` password
- CloudWatch log group, CloudWatch alarms and an SNS topic subscribed by
  `alert_emails`
- DNS records for both the cluster and
  `<elasticsearch_cluster_name>-kibana.<zone domain>`

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.5
- A VPC with at least three private subnets in different availability zones,
  each with outbound internet access through a NAT gateway
- A Route53 hosted zone for your domain
- An EC2 key pair
- VPN or other private connectivity to the VPC - neither the cluster nor Kibana
  is published on the internet

## Usage

The Elasticsearch cluster forms in two applies. Kibana can only connect once the
second one has finished.

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars

terraform init

# 1. Form the cluster.
terraform apply -var="bootstrap_mode=true"

# 2. Turn bootstrap mode off and bring Kibana up.
terraform apply -var="bootstrap_mode=false"
```

Then open the URL over the VPN:

```bash
terraform output kibana_url
terraform output -raw elastic_password
```

Sign in as `elastic` with that password.

## Inputs

| Name | Description |
|------|-------------|
| region | AWS region where the cluster and Kibana are deployed |
| environment | Name of the environment Kibana belongs to |
| zone_name | Route53 hosted zone name, with a trailing dot |
| elasticsearch_cluster_name | Name of the Elasticsearch cluster |
| private_subnets | Private subnets for the nodes, the ECS instances and the load balancers |
| ssh_key_name | Name of an existing EC2 key pair |
| admin_cidr_block | CIDR range allowed to SSH into the instances |
| alert_emails | Addresses that receive CloudWatch alarm notifications |
| replication_region | Region the ALB access-log buckets are replicated to |
| kibana_version | Version of the Kibana image; must match the cluster |
| bootstrap_mode | Elasticsearch cluster bootstrap flag |

## Outputs

| Name | Description |
|------|-------------|
| kibana_url | URL where the Kibana UI is available |
| kibana_username | Elasticsearch user Kibana authenticates with |
| load_balancer_arn | ARN of the load balancer in front of Kibana |
| elasticsearch_url | HTTPS endpoint of the Elasticsearch master nodes |
| elastic_password | Password of the built-in `elastic` user |

## Notes

- `kibana_system_password` comes straight from the Elasticsearch module, so the
  password never leaves Terraform state and no operator has to copy it around.
- `elasticsearch_request_timeout` is matched to the master load balancer's idle
  timeout. If Kibana's timeout is the longer one, the ALB drops long searches
  before Kibana gives up on them and users see a blank error instead of a
  timeout.
- `access_log_force_destroy` stays `false`: the access-log bucket is an audit
  record, and `terraform destroy` should not silently delete it.
- Kibana is stateless. It stores its saved objects in Elasticsearch, so
  replacing an instance loses nothing.
- Kibana and Elasticsearch must run the same version. The cluster's version is a
  Puppet hiera key (`profile::elastic::packages::elasticsearch_version`), not a
  Terraform input, so check a running node with `dpkg -l | grep elasticsearch`
  and set the module's `kibana_version` to match. This example pins the module
  version that predates that input; add `kibana_version` once you move the
  `version` pin forward.
- To publish Kibana on the internet instead, move `load_balancer_subnets` to
  public subnets. The instances should stay in private subnets either way.
