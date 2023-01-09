output "iam-policy-rds-secret-read" {
  value = aws_iam_policy.rds-secret-policy
}

output "rds-db-secret" {
  value = aws_secretsmanager_secret.db-secret
}

output "rds-db-secret-url" {
  value = jsondecode(aws_secretsmanager_secret_version.db-secret-version.secret_string)["url"]
}