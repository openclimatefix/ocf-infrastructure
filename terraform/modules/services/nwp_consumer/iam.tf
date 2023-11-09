# Define the IAM task execution role and the instance role
# Execution role is used to deploy the task
# Instance role is used to run the task

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-execution-role"

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

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "attach-logs-execution" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.cloudwatch-nwp.arn
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

resource "aws_iam_role" "consumer-nwp-iam-role" {
  name               = "consumer-${var.app_name}-iam-role"
  path               = "/consumer/"
  assume_role_policy = data.aws_iam_policy_document.ec2-instance-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "attach-write-s3" {
  role       = aws_iam_role.consumer-nwp-iam-role.name
  policy_arn = var.s3_config.bucket_write_policy_arn
}

resource "aws_iam_role_policy_attachment" "attach-logs" {
  role       = aws_iam_role.consumer-nwp-iam-role.name
  policy_arn = aws_iam_policy.cloudwatch-nwp.arn
}

resource "aws_iam_role_policy_attachment" "read-secret-execution" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secret_read_policy.arn
}

resource "aws_iam_role_policy_attachment" "read-secret" {
  role       = aws_iam_role.consumer-nwp-iam-role.name
  policy_arn = aws_iam_policy.secret_read_policy.arn
}

