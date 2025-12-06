# ECS Module Upgrade Plan: v5.12.0 → v7.0.0

**Date:** 2025-12-05
**Module:** `registry.infrahouse.com/infrahouse/ecs/aws`
**Current Version:** 5.12.0
**Target Version:** 7.0.0

## Executive Summary

This plan outlines the steps required to upgrade the infrahouse/ecs/aws module from version 5.12.0 to 7.0.0. 
The upgrade includes breaking changes that require modifications to variables, module configuration, and test files.

## Breaking Changes Analysis

### 1. ✅ NEW REQUIRED: `alarm_emails` variable

**Type:** `list(string)`
**Description:** List of email addresses for CloudWatch alarm notifications
**Purpose:** Enable automated notifications for service health issues including high latency, low success rate, and unhealthy hosts

**Validation Requirements:**
- Must contain at least one email address
- All entries must match valid email format (regex validated)

**Impact:**
- Must add to root module `variables.tf`
- Must add to `main.tf` module call
- Must add to test fixtures (`test_data/kibana/`)
- Must update test code to generate this variable

### 2. ❌ REMOVED: `internet_gateway_id` variable

**Status:** Auto-detected in v7.0.0
**Previous:** Optional parameter in v5.12.0

**Impact:**
- Remove from root module `variables.tf`
- Remove from `main.tf` module call (line 15)
- Remove from test fixtures
- Remove from test code generation
- Remove from README.md inputs table

### 3. ⚠️ DEFAULT CHANGED: `enable_cloudwatch_logs`

**v5.12.0:** `default = false`
**v7.0.0:** `default = true`

**Cost Impact:**
- Estimated $15-20/month for typical services logging 1GB/day
- Currently explicitly set to `true` in main.tf:23, so no behavior change

### 4. 📋 DEFAULT CHANGED: `autoscaling_target_cpu_usage`

**v5.12.0:** `default = 80`
**v7.0.0:** `default = 60`

**Impact:**
- Lower threshold may trigger autoscaling earlier
- Potential cost increase due to more aggressive scaling
- Not currently set in configuration, will use new default

### 5. 🔄 AMI CHANGE: Amazon Linux 2 → Amazon Linux 2023

**Changed in:** v6.0.0
**Impact:** None - module explicitly sets `ami_id` in main.tf:11

**Background:**
- Default AMI filter changed from `amzn2-ami-ecs-hvm-*` to `al2023-ami-ecs-hvm-*`
- AL2 enters maintenance mode June 30, 2024, ending June 30, 2025
- AL2023 provides 5-year support per major release

### 6. 🆕 NEW OPTIONAL: CloudWatch KMS Encryption

**Variable:** `cloudwatch_log_kms_key_id`
**Type:** `string`
**Default:** `null`
**Purpose:** Customer-managed KMS encryption for CloudWatch logs
**Use Case:** HIPAA/PCI-DSS compliance
**Cost:** ~$1/month per key

**Impact:** Optional, not required for this upgrade

### 7. 📊 OUTPUT CHANGE: `cloudwatch_log_group_names`

**v5.12.0:** Indexed list
**v7.0.0:** Map structure

**Impact:** Check if output is used by consumers; may require updates

## Implementation Plan

### Phase 1: Variable Updates

#### Task 1.1: Add `alert_emails` variable
**File:** `variables.tf`

```hcl
variable "alert_emails" {
  description = "List of email addresses for CloudWatch alarm notifications"
  type        = list(string)
}
```

#### Task 1.2: Remove `internet_gateway_id` variable
**File:** `variables.tf`
**Action:** Delete lines 40-43

### Phase 2: Main Configuration Updates

#### Task 2.1: Update module version
**File:** `main.tf`
**Change:** Line 3: `version = "5.12.0"` → `version = "7.0.0"`

#### Task 2.2: Remove `internet_gateway_id` parameter
**File:** `main.tf`
**Change:** Remove line 15: `internet_gateway_id = var.internet_gateway_id`

#### Task 2.3: Add `alarm_emails` parameter
**File:** `main.tf`
**Addition:** Add after line 14 or appropriate location:
```hcl
  alarm_emails        = var.alert_emails
```

### Phase 3: Test Infrastructure Updates

#### Task 3.1: Update test module variables
**File:** `test_data/kibana/variables.tf`

Add:
```hcl
variable "alert_emails" {
  description = "List of email addresses for CloudWatch alarm notifications"
  type        = list(string)
}
```

Remove:
```hcl
variable "internet_gateway_id" {
  description = "Internet gateway id. Usually created by 'infrahouse/service-network/aws'"
  type        = string
}
```

#### Task 3.2: Update test module call
**File:** `test_data/kibana/main.tf`

Add:
```hcl
  alarm_emails = var.alert_emails
```

Remove (line 10):
```hcl
  internet_gateway_id = var.internet_gateway_id
```

#### Task 3.3: Update test code
**File:** `tests/test_module.py`

Add (around line 84-85):
```python
fp.write(f'alert_emails = ["kibana-test@example.com"]\n')
```

Remove references to `internet_gateway_id` variable generation (around line 80)

### Phase 4: Documentation Updates

#### Task 4.1: Update README.md
**File:** `README.md`

* Ask me to run `terraform-docs .`
* this will be a breaking change. add migration instruction

**Update usage example** (lines 41-56):
Add `alert_emails` parameter to example:
```hcl
module "kibana" {
  source  = "infrahouse/kibana/aws"
  version = "1.13.1"  # Update this to new version after release
  providers = {
    aws     = aws
    aws.dns = aws
  }
  alert_emails               = ["ops-team@example.com"]
  asg_subnets                = module.service-network.subnet_private_ids
  elasticsearch_cluster_name = "some-cluster-name"
  elasticsearch_url          = var.elasticsearch_url
  kibana_system_password     = module.elasticsearch.kibana_system_password
  load_balancer_subnets      = module.service-network.subnet_public_ids
  ssh_key_name               = aws_key_pair.test.key_name
  zone_id                    = var.zone_id
}
```

Remove `internet_gateway_id` reference from notes (if any).

**Update module version in docs:**
Update line 84 to reflect new version when releasing.

### Phase 5: Code Quality & Testing

#### Task 5.1: Format code

* ask me to do it
* 
#### Task 5.3: Run tests

ask me to run 
```bash
make test-keep
```

Expected test execution:
- Tests run with AWS provider  ~> 6.0 (make test-keep)
- Tests should create Kibana instance successfully
- CloudWatch alarms should be created with configured email
- Internet gateway should be auto-detected

### Phase 6: Commit & Release

#### Task 6.1: Create commit
Follow repository commit standards (see `.claude/CODING_STANDARD.md`)

Example commit message:
```
Upgrade ECS module to v7.0.0

Breaking changes:
- Add required alarm_emails variable for CloudWatch notifications
- Remove internet_gateway_id (now auto-detected)

Updates:
- CloudWatch logs now enabled by default
- CPU autoscaling threshold lowered to 60%
- Support for CloudWatch KMS encryption added
```

#### Task 6.3: Create PR
Use standard PR template, include migration notes.

## Testing Strategy

### Integration Tests
- Manual test - make test-keep
- CI runs whole test suite

### Manual Testing Checklist
- [ ] make test-keep is successful

## Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Email not received | Medium | Configure test email, verify SNS subscription |
| Cost increase from CloudWatch logs | Low | Already enabled in current config |
| Cost increase from CPU scaling | Medium | Monitor autoscaling behavior, adjust threshold if needed |
| Gateway detection failure | Low | Module has auto-detection logic; fallback available |
| Test failures | Medium | Run tests before merging; keep resources for debugging |

## Cost Impact Analysis

| Item | Previous | New | Delta |
|------|----------|-----|-------|
| CloudWatch Logs | $0 (disabled) → $15-20/mo (enabled) | Already enabled | $0 |
| CloudWatch Alarms | Included | Included | $0 |
| SNS Notifications | $0 | $0 (first 1000 free) | $0 |
| Autoscaling (CPU threshold change) | 80% → 60% | Potential increase | TBD |

**Total estimated impact:** Minimal, monitoring recommended for autoscaling behavior.

## References

- [ECS Module GitHub](https://github.com/infrahouse/terraform-aws-ecs)
- [ECS Module Changelog](https://github.com/infrahouse/terraform-aws-ecs/blob/master/CHANGELOG.md)
- [Terraform Registry](https://registry.terraform.io/modules/infrahouse/ecs/aws)
- [v7.0.0 Release](https://github.com/infrahouse/terraform-aws-ecs/releases/tag/7.0.0)
- [v6.0.0 Release](https://github.com/infrahouse/terraform-aws-ecs/releases/tag/6.0.0)

## Additional Notes

- The module now supports variable validation blocks for better input validation
- Website-pod module dependency upgraded to 5.12.1
- Consider implementing CloudWatch KMS encryption if compliance requirements exist
- Monitor autoscaling behavior after upgrade due to lowered CPU threshold

## Checklist Summary

- [ ] Add `alert_emails` variable to `variables.tf`
- [ ] Remove `internet_gateway_id` from `variables.tf`
- [ ] Update module version to `7.0.0` in `main.tf`
- [ ] Add `alarm_emails` to module call in `main.tf`
- [ ] Remove `internet_gateway_id` from module call in `main.tf`
- [ ] Update `test_data/kibana/variables.tf`
- [ ] Update `test_data/kibana/main.tf`
- [ ] Update `tests/test_module.py`
- [ ] Update `README.md` documentation
- [ ] Run `make format`
- [ ] Run `make lint`
- [ ] Run `make test-keep`
- [ ] Run `make test-clean`
- [ ] Create commit with proper message
- [ ] Create PR with migration notes
