# IAM policy for reading rds secret

resource "aws_iam_policy" "rds-secret-policy" {
  name        = "rds-secret-policy"
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
        Resource = aws_secretsmanager_secret.db-forecast-secret.arn
      },
    ]
  })
}


resource "aws_iam_policy" "rds-pv-secret-policy" {
  name        = "rds-pv-secret-policy"
  path        = "/rds/"
  description = "Read access to RDS secret, in order to connect to pv database"

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
        Resource = aws_secretsmanager_secret.db-pv-secret.arn
      },
    ]
  })
}

resource "aws_iam_policy" "rds-pvsite-secret-policy" {
  name        = "rds-pvsite-secret-policy"
  path        = "/rds/"
  description = "Read access to RDS secret, in order to connect to pvsite database"

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
        Resource = aws_secretsmanager_secret.db-pvsite-secret.arn
      },
    ]
  })
}
