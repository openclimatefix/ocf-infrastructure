# Define the IAM task Instance role, used to run the task

data "aws_iam_policy_document" "ecs_assumerole_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Create the role
resource "aws_iam_role" "consumer-gsp-iam-role" {
  name               = "consumer-gsp-iam-role"
  path               = "/consumer/"
  assume_role_policy = data.aws_iam_policy_document.ecs_assumerole_policy_document.json
}

# Attach policies
resource "aws_iam_role_policy_attachment" "attach-logs" {
  role       = aws_iam_role.consumer-gsp-iam-role.name
  policy_arn = aws_iam_policy.cloudwatch-gsp.arn
}
resource "aws_iam_role_policy_attachment" "read-db-secret" {
  role       = aws_iam_role.consumer-gsp-iam-role.name
  policy_arn = var.iam-policy-rds-read-secret.arn
}
