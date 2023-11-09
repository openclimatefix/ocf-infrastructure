# Access a secret in secrets manager
# 1. Gets the id of current version of the secret
# 2. Creates a policy to allow read access to the secret

# Read in required secret for task
data "aws_secretsmanager_secret" "secret" {
  name = var.aws-secretsmanager_secret_name
}

# 1. Get the current secret value from AWS for the secret
data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

# Create a policy enabling read access to secrets
data "aws_iam_policy_document" "secret_read_policy" {
  statement {
    version = "2012-10-17"
    actions = [
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:GetSecretValue",
    ]
    effect = "Allow"
    resources = [
      data.aws_secretsmanager_secret_version.current.arn,
    ]
  }
}

# 2. Create an IAM policy to access the current version of the secret
resource "aws_iam_policy" "secret_read_policy" {
  name        = "${var.ecs-task_name}-secret-read-policy"
  path        = "/${var.ecs-task_type}/${var.ecs-task_name}/"
  description = "Policy to allow read access to secret."

  policy = data.aws_iam_policy_document.secret_read_policy.json
}
