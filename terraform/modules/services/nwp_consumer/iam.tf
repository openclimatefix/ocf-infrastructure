# Define the IAM task execution role and the instance role
# Execution role is used to deploy the task
# Instance role is used to run the task

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

// Create Task Role ------------------------------------------------------

resource "aws_iam_role" "create_task_role" {
  name = "${var.ecs-task_name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "create_task_policy" {
  role       = aws_iam_role.create_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "create_logs_policy" {
  role       = aws_iam_role.create_task_role.name
  policy_arn = aws_iam_policy.log_policy.arn
}

resource "aws_iam_role_policy_attachment" "create_secret_policy" {
  role       = aws_iam_role.create_task_role.name
  policy_arn = aws_iam_policy.secret_read_policy.arn
}

// Run Task Role ---------------------------------------------------------

resource "aws_iam_role" "run_task_role" {
  name               = "${var.ecs-task_type}-${var.ecs-task_name}-iam-role"
  path               = "/${var.ecs-task_type}/"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "access_s3_policy" {
  for_each   = var.s3-buckets
  role       = aws_iam_role.run_task_role.name
  policy_arn = each.value.access_policy_arn
}

resource "aws_iam_role_policy_attachment" "access_logs_policy" {
  role       = aws_iam_role.run_task_role.name
  policy_arn = aws_iam_policy.log_policy.arn
}

resource "aws_iam_role_policy_attachment" "access_secret_policy" {
  role       = aws_iam_role.run_task_role.name
  policy_arn = aws_iam_policy.secret_read_policy.arn
}

