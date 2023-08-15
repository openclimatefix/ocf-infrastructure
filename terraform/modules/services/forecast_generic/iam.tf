# Define the IAM task execution role and the instance role
# Execution role is used to deploy the task
# Instance role is used to run the task

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-${var.app-name}-execution-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "cloudwatch_role" {
  name        = "cloudwatch-read-and-write-${var.app-name}"
  path        = "/${var.app-name}/"
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
        Resource = "arn:aws:logs:*:*:log-group:${local.log-group-name}*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ec2-instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app-role" {
  name               = "${var.app-name}-iam-role"
  path               = "/${var.app-name}/"
  assume_role_policy = data.aws_iam_policy_document.ec2-instance-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "attach-read-s3-nwp" {
  role       = aws_iam_role.app-role.name
  policy_arn = var.s3_nwp_bucket.bucket_read_policy_arn
}

resource "aws_iam_role_policy_attachment" "attach-read-s3-satellite" {
  count      = var.s3_satellite_bucket.bucket_read_policy_arn != "not-set" ? 1 : 0
  role       = aws_iam_role.app-role.name
  policy_arn = var.s3_satellite_bucket.bucket_read_policy_arn
}

resource "aws_iam_role_policy_attachment" "attach-write-s3-ml" {
  role       = aws_iam_role.app-role.name
  policy_arn = var.s3_ml_bucket.bucket_read_policy_arn
}

resource "aws_iam_role_policy_attachment" "read-secret-execution" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = var.rds_config.database_secret_read_policy_arn
}

resource "aws_iam_role_policy_attachment" "read-secret" {
  role       = aws_iam_role.app-role.name
  policy_arn = var.rds_config.database_secret_read_policy_arn
}
