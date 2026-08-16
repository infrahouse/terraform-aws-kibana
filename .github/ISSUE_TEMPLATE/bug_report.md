---
name: Bug report
about: Report a problem with the module
title: ''
labels: bug
assignees: ''
---

## Describe the Bug

A clear and concise description of what the bug is.

## To Reproduce

Module configuration that triggers the problem:

```hcl
module "kibana" {
  source  = "registry.infrahouse.com/infrahouse/kibana/aws"
  version = "x.y.z"
  # ...
}
```

Steps:

1. Run `terraform apply`
2. ...

## Expected Behavior

What you expected to happen.

## Actual Behavior

What actually happened. Include the Terraform error output if any:

```
paste output here
```

## Environment

- Module version:
- Terraform version (`terraform version`):
- AWS provider version:
- Elasticsearch version:

## Additional Context

Anything else that helps: the Kibana container logs from the CloudWatch log
group, the recent events of the ECS service
(`aws ecs describe-services --cluster <cluster>-kibana --services <cluster>-kibana`),
target group health reasons, CloudWatch alarms that fired, etc.
