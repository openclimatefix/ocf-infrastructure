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

resource "aws_iam_role_policy_attachment" "attach-read-s3-ml" {
  role       = aws_iam_role.app-role.name
  policy_arn = var.s3_ml_bucket.bucket_read_policy_arn
}
