# Define the IAM task execution role and the instance role
# Execution role is used to deploy the task
# Instance role is used to run the task

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "metrics-execution-role"

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
resource "aws_iam_policy" "cloudwatch-metrics" {
  name        = "cloudwatch-read-and-write-metrics"
  path        = "/metrics/"
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
        Resource = "arn:aws:logs:*:*:log-group:${var.log-group-name}*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "attach-logs-execution" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.cloudwatch-metrics.arn
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

resource "aws_iam_role" "metrics-iam-role" {
  name               = "metrics-iam-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2-instance-assume-role-policy.json
}


resource "aws_iam_role_policy_attachment" "attach-logs" {
  role       = aws_iam_role.metrics-iam-role.name
  policy_arn = aws_iam_policy.cloudwatch-metrics.arn
}


resource "aws_iam_role_policy_attachment" "read-db-secret-execution" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = var.iam-policy-rds-read-secret.arn
}

resource "aws_iam_role_policy_attachment" "read-db-secret" {
  role       = aws_iam_role.metrics-iam-role.name
  policy_arn = var.iam-policy-rds-read-secret.arn
}
