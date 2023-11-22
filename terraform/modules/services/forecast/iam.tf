# Define the IAM task Instance role, used to run the task

data "aws_iam_policy_document" "ec2-instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "forecast-iam-role" {
  name               = "forecast-iam-role"
  path               = "/forecast/"
  assume_role_policy = data.aws_iam_policy_document.ec2-instance-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "attach-write-s3" {
  role       = aws_iam_role.forecast-iam-role.name
  policy_arn = var.iam-policy-s3-nwp-read.arn
}

resource "aws_iam_role_policy_attachment" "attach-write-s3-sat" {
  role       = aws_iam_role.forecast-iam-role.name
  policy_arn = var.iam-policy-s3-sat-read.arn
}

resource "aws_iam_role_policy_attachment" "attach-write-s3-ml" {
  role       = aws_iam_role.forecast-iam-role.name
  policy_arn = var.iam-policy-s3-ml-read.arn
}
