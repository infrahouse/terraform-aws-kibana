# Troubleshooting

## `terraform apply` fails: missing provider `aws.dns`

The module requires a second, aliased AWS provider for Route53. Pass it explicitly:

```hcl
providers = {
  aws     = aws
  aws.dns = aws.dns
}
```

## `terraform apply` fails reading the hosted zone

The module reads the zone with the **default** `aws` provider (to build the Kibana URL) while the
records are created with `aws.dns`. When the zone lives in another AWS account, the default
provider's role also needs read access to it. Symptom: a `NoSuchHostedZone` or `AccessDenied` error
on `data.aws_route53_zone.kibana_zone` even though the DNS provider is configured correctly.

## Replication region error on the access-log bucket

`replication_region` must be a different region than the one you deploy to — S3 cannot replicate a
bucket to itself. Pick any other region, e.g. `us-east-1` for a `us-west-2` deployment.

## The ECS service never stabilizes

`terraform apply` hangs on the ECS service and eventually times out, or the ASG keeps replacing
instances. Work through it in this order:

1. **Give it time.** The first deployment is slow — ACM validation, the instance joining the cluster,
   and Kibana migrating its saved-objects indices in Elasticsearch. Both the ASG and the service
   allow a 900-second grace period.
2. **Read the container logs.** They are in the CloudWatch log group of the service, by default
   `/ecs/<environment>/<elasticsearch_cluster_name>-kibana`. Almost every failure below announces
   itself there.
3. **Check the task state:**

    ```bash
    aws ecs describe-services \
      --cluster <elasticsearch_cluster_name>-kibana \
      --services <elasticsearch_cluster_name>-kibana \
      --query 'services[0].events[:10]'
    ```

## `Kibana server is not ready yet`

Kibana started but cannot use Elasticsearch. The container log says which one it is:

- **`security_exception ... unable to authenticate user [kibana_system]`** — the
  `kibana_system_password` does not match the cluster. Reset it in Elasticsearch, or pass the
  cluster module's `kibana_system_password` output instead of a hand-copied value.
- **`connect ECONNREFUSED` / `getaddrinfo ENOTFOUND`** — `elasticsearch_url` is wrong, or the ECS
  host instances cannot reach the Elasticsearch load balancer. Check that the `asg_subnets` can route
  to it and that the cluster's security group accepts traffic from them.
- **`master_not_discovered_exception`** — the cluster itself has not formed. Kibana cannot come up
  before Elasticsearch does. With the InfraHouse elasticsearch module, that means the second apply
  (`bootstrap_mode = false`) has not completed.
- **`Incompatible Elasticsearch server version`** — the Kibana image tag is pinned inside the module
  and Elastic requires Kibana and Elasticsearch to be on the same version. If your cluster runs a
  newer 8.x than the module's image, upgrade the module (or pin the cluster) so the two line up.

## The task stops with `AccessDeniedException` on Secrets Manager

The ECS agent reads the encryption key and the password with the **task execution role** before the
container starts. The module attaches a policy that allows exactly those two secrets. This normally
only breaks if the secrets were replaced out of band or a permissions boundary blocks
`secretsmanager:GetSecretValue`. Confirm the policy is still attached to the execution role:

```bash
aws iam list-attached-role-policies --role-name <task execution role>
```

## ALB targets are unhealthy but Kibana looks fine

The ALB health check is `GET /login` expecting HTTP 200 — a Kibana that answers `/status` but is
still migrating will fail it. Check the target group health reason: `Target.Timeout` points at
security groups or a task that is still starting, `Target.ResponseCodeMismatch` at a Kibana that is
returning a redirect or an error page for `/login`.

## Long searches fail with a 504 from the load balancer

The ALB idle timeout and Kibana's Elasticsearch request timeout both come from
`elasticsearch_request_timeout`. A 504 usually means the load balancer **in front of the
Elasticsearch masters** has a shorter idle timeout than this module does. Set both to the same value
— with the InfraHouse elasticsearch module, pass `module.elasticsearch.idle_timeout_master`.

## Saved objects, alerting rules or reports break after a change

The three X-Pack encryption keys share one generated random string. If it is regenerated (state lost,
`random_string` tainted, or the secret recreated), everything encrypted with the previous key —
alerting rules, reporting jobs, connectors — can no longer be decrypted. Restore the old value into
the Secrets Manager secret, or delete and recreate the affected saved objects.

## Renaming the cluster recreates everything

`elasticsearch_cluster_name` is the prefix of the ECS service, the DNS record and the secrets.
Changing it is a rename of the whole deployment: a new DNS record, a new certificate and new secrets,
with the old ones destroyed. Kibana's data lives in Elasticsearch, so nothing is lost, but the URL
changes and users have to be pointed at it.

## `terraform destroy` fails on the access-log bucket

S3 will not delete a non-empty bucket. Either empty it first, or deploy non-production environments
with `access_log_force_destroy = true`. Leave it `false` in production — the access logs are an audit
record.

## Still stuck?

- Read the module's own tests: they stand up Elasticsearch, the network and Kibana end to end and are
  the reference for a working configuration
  ([`tests/test_module.py`](https://github.com/infrahouse/terraform-aws-kibana/blob/main/tests/test_module.py),
  [`test_data/kibana`](https://github.com/infrahouse/terraform-aws-kibana/tree/main/test_data/kibana)).
- [Open an issue](https://github.com/infrahouse/terraform-aws-kibana/issues) with the module version,
  the Terraform and AWS provider versions, and the relevant container log lines.
