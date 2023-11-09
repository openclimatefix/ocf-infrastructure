# Creates:
# 1. Cloudwatch log group
# 2. IAM policy to allow read and write to cloudwatch logs

locals {
  log_group_name = "/aws/ecs/consumer/${var.app_name}/"
}

# 1.
resource "aws_cloudwatch_log_group" "nwp" {
  name = local.log_group_name

  retention_in_days = 7

  tags = {
    Environment = var.aws_config.environment
    Application = "nowcasting"
  }
}

# 2.
resource "aws_iam_policy" "cloudwatch-nwp" {
  name        = "${var.app_name}-cloudwatch-read-and-write"
  path        = "/consumer/${var.app_name}/"
  description = "Policy to allow read and write to cloudwatch logs"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:DeleteLogGroup",
          "logs:PutRetentionPolicy"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:log-group:${local.log_group_name}*"
      },
    ]
  })
}
