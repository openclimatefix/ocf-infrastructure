# Define the IAM task Instance role used to run the task
# This is used when running the task so requires access to the S3 buckets
# It doesn't need access to secrets as those are passed in as env vars
# via the task definition using the cluster-wide task execution role

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

resource "aws_iam_role" "run_task_role" {
  name               = "${var.ecs-task_type}-${var.ecs-task_name}-instance-role"
  path               = "/${var.ecs-task_type}/"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

# For every bucket in the list of buckets, attach its access policy to the run task role
resource "aws_iam_role_policy_attachment" "access_s3_policy" {
  for_each   = {
    for index, bucket_info in var.s3-buckets: bucket_info.id => bucket_info
  }
  role       = aws_iam_role.run_task_role.name
  policy_arn = each.value.access_policy_arn
}

resource "aws_iam_role_policy_attachment" "access_logs_policy" {
  role       = aws_iam_role.run_task_role.name
  policy_arn = aws_iam_policy.log_policy.arn
}
