# IAM policy for reading rds secret

resource "aws_iam_policy" "rds-secret-iam-policy" {
  name        = "${var.db_name}-rds-secret-policy"
  path        = "/rds/"
  description = "Read access to RDS secret, in order to connect to database"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.db-secret.arn
      },
    ]
  })
}
