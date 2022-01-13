# read access to secret

resource "aws_iam_policy" "rds-secret-policy" {
  name        = "RDS-secret-policy"
  path        = "/RDS/"
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
        Resource = aws_secretsmanager_secret.DB-forecast-secret.arn
      },
    ]
  })
}