output "iam-policy-db-read" {
  value = aws_iam_policy.rds-secret-policy
}

output "database-secret" {
  value = aws_secretsmanager_secret.DB-forecast-secret
}


