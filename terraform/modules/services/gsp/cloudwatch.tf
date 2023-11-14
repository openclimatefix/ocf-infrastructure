# set up cloudwatch log group

# Define log group
resource "aws_cloudwatch_log_group" "gsp" {
  name = var.log-group-name

  retention_in_days = 7

  tags = {
    Environment = var.environment
    Application = "nowcasting"
  }
}

# Define log group policy for writing to log group
data "aws_iam_policy_document" "cloudwatch_policy_document" {
    statement {
        actions = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:DeleteLogGroup",
          "logs:PutRetentionPolicy"
        ]

        resources = ["arn:aws:logs:*:*:log-group:${var.log-group-name}*"]
    }
}

# Create log group policy
resource "aws_iam_policy" "cloudwatch-gsp" {
  name        = "cloudwatch-read-and-write-gsp"
  path        = "/consumer/gsp/"
  description = "Policy to allow read and write to cloudwatch logs"

  policy = data.aws_iam_policy_document.cloudwatch_policy_document.json
}
