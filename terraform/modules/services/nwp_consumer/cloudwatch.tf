# Creates:
# 1. Cloudwatch log group
# 2. IAM policy to allow read and write to cloudwatch logs

locals {
  log_group_name = "/aws/ecs/${var.ecs-task_type}/${var.ecs-task_name}"
}

# 1.
resource "aws_cloudwatch_log_group" "log_group" {
  name = local.log_group_name

  retention_in_days = 7

  tags = {
    application = "ecs-${var.ecs-task_name}"
  }
}

# Describe actions of IAM policy allowing cloudwatch read and write
data "aws_iam_policy_document" "log_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
      "logs:DeleteLogGroup",
      "logs:PutRetentionPolicy"
    ]

    resources = [
      "arn:aws:logs:*:*:log-group:${local.log_group_name}*",
    ]
  }
}

# 2. Create IAM policy with above actions on created cloudwatch log group
resource "aws_iam_policy" "log_policy" {
  name        = "${var.ecs-task_name}-cloudwatch-read-and-write"
  path        = "/${var.ecs-task_type}/${var.ecs-task_name}/"
  description = "Policy to allow read and write to cloudwatch logs"

  policy = data.aws_iam_policy_document.log_policy.json
}
