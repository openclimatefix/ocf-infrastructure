# Read in required secrets for consumer
# Get the secret resource from AWS for each entry in the list
data "aws_secretsmanager_secret" "secret" {
  name = var.aws_config.secretsmanager_secret_name
}

# Get the current secret value from AWS for the secret
data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

# Get an IAM role to access the secret 
resource "aws_iam_policy" "secret_read_policy" {
  name        = "${var.app_name}-secret-read-policy"
  path        = "/consumer/nwp/"
  description = "Policy to allow read access to secret."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:GetSecretValue",
        ]
        Effect   = "Allow"
        Resource = data.aws_secretsmanager_secret_version.current.arn
      },
    ]
  })
}

