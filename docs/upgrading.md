# Upgrading

Always pin an exact version and upgrade one release at a time. Run `terraform plan` and read it
before applying — this module fronts a load balancer and an ECS service, so a plan that replaces the
service means a short outage of the Kibana UI (nothing is lost: Kibana keeps all of its state in
Elasticsearch).

```bash
terraform init -upgrade
terraform plan
```

## AWS provider requirement

The module requires AWS provider `>= 6.0, < 7.0`. Provider v5 was supported up to and including
3.0.1; releases after that are tested against v6 only. Upgrade the provider first if you are still
on v5:

```bash
terraform init -upgrade
```

## 3.0.0 → 3.0.1

**New required input: `replication_region`.** The ALB access-log bucket is an audit record and now
gets cross-region replication. Add a region that differs from the one you deploy to:

```hcl
replication_region = "us-east-1" # deploying to us-west-2
```

The underlying ECS module also moves from 7.0.0 to 8.1.0. Expect the plan to touch the access-log
bucket (a replica bucket and a replication role are created).

## 1.x → 3.x

Version 2.0.0 upgraded the underlying ECS module from v5 to v7, and 3.0.0 carried that work forward.
Both are breaking changes.

### Breaking changes

1. **New required variable `alert_emails`.** At least one address for CloudWatch alarm notifications.
   Every address receives an SNS subscription confirmation email that must be accepted before
   notifications are delivered.
2. **Removed variable `internet_gateway_id`.** The internet gateway is detected automatically now.
3. **Default behaviour changes:**
    - CloudWatch logs are enabled (they were off in 1.x).
    - The CPU autoscaling threshold dropped from 80% to 60%.
    - The default AMI moved from Amazon Linux 2 to Amazon Linux 2023 (when `ami_id` is unset).
4. **`kibana_system_password` is marked `sensitive`.** If you pass it through to an output of your
   own, that output has to be marked sensitive as well or Terraform will refuse to plan.

### Migration steps

1. Add the required `alert_emails`:

    ```hcl
    alert_emails = ["ops-team@example.com"]
    ```

2. Remove `internet_gateway_id`:

    ```diff
    - internet_gateway_id = module.service-network.internet_gateway_id
    ```

3. Add `replication_region` (see [3.0.0 → 3.0.1](#300-301) above).

4. Update the version and re-initialize:

    ```hcl
    version = "3.0.1"
    ```

    ```bash
    terraform init -upgrade
    terraform plan
    ```

5. Review the plan. Replacing the ASG instances and the ECS task definition is expected; replacing
   the load balancer or the certificate is not — check `elasticsearch_cluster_name` and `zone_id` if
   you see that.

## Kibana version

The Kibana image tag is pinned inside the module. Elastic requires Kibana and Elasticsearch to run
the same version, so upgrading the Elasticsearch cluster past the module's image means upgrading this
module too. Check `main.tf` for the tag a given release ships.
