output "secret-policy" {
  description = "The iam policy allowing read access on the database secret"
  value = aws_iam_policy.rds-secret-policy
}

output "secret" {
  description = "The secret generated for AWS secret manager"
  value = aws_secretsmanager_secret.db-secret
}

output "secret-url" {
  description = "The URL to the database secret in aws secret manager"
  value = jsondecode(aws_secretsmanager_secret_version.db-secret-version.secret_string)["url"]
}
