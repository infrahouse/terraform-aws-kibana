data "aws_iam_policy_document" "task_role_exec_permissions" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      module.kibana-encryptionKey.secret_arn,
      module.kibana-password.secret_arn,
    ]
  }
}
resource "aws_iam_policy" "task_role_exec" {
  name_prefix = "${var.elasticsearch_cluster_name}-kibana-"
  policy      = data.aws_iam_policy_document.task_role_exec_permissions.json
  tags        = local.default_module_tags
}

