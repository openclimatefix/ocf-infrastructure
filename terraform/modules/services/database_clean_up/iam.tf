# Define the IAM task Instance role used to run the task

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
