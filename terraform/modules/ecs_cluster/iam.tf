# Make ECS cluster task execution role
# This role is used by ECS to execute tasks, and has the following permissions:
# - Read secrets from SSM
# - Write to cloudwatch logs
# - Execute ECS tasks

locals {
  secretsmanager_arn = "arn:aws:secretsmanager:${var.region}:${var.owner_id}"
}

# --- Default ECS Log group --- #

resource "aws_cloudwatch_log_group" "ecs_default_log_group" {
  name = "/aws/ecs/${var.name}"
  retention_in_days = 7
  tags = {
    application = "ecs-${var.name}"
  }
}

# -- Execution Policies -- #

# Policy document for ECS task execution
data "aws_iam_policy_document" "ecs_assume_role_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

# Policy document for reading secrets from SSM
data "aws_iam_policy_document" "secrets_policy_document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]
    resources = ["${local.secretsmanager_arn}:secret:*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecrets",
    ]
    resources = ["*"]
  }
}
# Associated policy
resource "aws_iam_policy" "read_regional_secrets_policy" {
    name        = "ecs-cluster-${var.name}-read-regional-secrets-policy"
    path        = "/ecs-cluster/${var.name}/secrets/"
    description = "Policy to read secrets from SSM"

    policy = data.aws_iam_policy_document.secrets_policy_document.json
}

# Policy documents for cloudwatch logging
data "aws_iam_policy_document" "cloudwatch_policy_document" {
    version = "2012-10-17"
    statement {
        actions = [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:DeleteLogGroup",
          "logs:PutRetentionPolicy"
        ]
        effect = "Allow"
        resources = ["arn:aws:logs:*:*:log-group:/aws/ecs*"]
      }
}
# Associated policy
resource "aws_iam_policy" "write_cloudwatch_policy" {
    name        = "ecs-cluster-${var.name}-write-cloudwatch-policy"
    path        = "/ecs-cluster/${var.name}/cloudwatch/"
    description = "Policy to write to cloudwatch logs"

    policy = data.aws_iam_policy_document.cloudwatch_policy_document.json
}

# Policy document for regional S3 access
data "aws_iam_policy_document" "s3_policy_document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObjectAttributes"
    ]
    resources = ["arn:aws:s3:::*"]
    condition = {
      test     = "StringEquals"
      variable = "aws:region"
      values   = ["${var.region}"]
    }
  }
}
# Associated policy
resource "aws_iam_policy" "s3_policy" {
    name        = "ecs-cluster-${var.name}-read-write-s3-policy"
    path        = "/ecs-cluster/${var.name}/s3/"
    description = "Policy to read and write to S3 in the ${var.region} region"

    policy = data.aws_iam_policy_document.s3_policy_document.json
}

# -- Execution Role -- #

# Create role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-cluster_${var.name}_task-execution-role"
  path = "/ecs-cluster/${var.name}/"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy_document.json
}

# Attach policies to role
# This needs secrets access to pass them to the container when creating the task
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment-cloudwatch" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.write_cloudwatch_policy.arn
}
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment-secrets" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.read_regional_secrets_policy.arn
}

# --- Task Role --- #

# Create role for ECS task running
# * This needs S3 access but not secrets access
resource "aws_iam_role" "ecs_task_run_role" {
  name = "ecs-cluster_${var.name}_task-run-role"
  path = "/ecs-cluster/${var.name}/"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy_document.json
}

# Attach policies to role
resource "aws_iam_role_policy_attachment" "esc-task-run-role-policy-attachment-cloudwatch" {
  role       = aws_iam_role.ecs_task_run_role.name
  policy_arn = aws_iam_policy.write_cloudwatch_policy.arn
}
resource "Aws_iam_role_policy_attachment" "ecs-task-run-role-policy-attachment-s3" {
  role       = aws_iam_role.ecs_task_run_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

