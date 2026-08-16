# Examples

Working configurations for the terraform-aws-kibana module.

| Example | What it shows |
|---------|---------------|
| [basic](basic/) | The minimum configuration: Kibana in front of an Elasticsearch cluster that already exists. |
| [production](production/) | Elasticsearch and Kibana together, private subnets only, SSH restricted, alarms wired up, access logs kept. |

Each directory is a standalone root module:

```bash
cd basic
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars
terraform init
terraform apply
```

Both examples create real AWS resources that cost money. Run
`terraform destroy` when you are done.
