output "iam-policy-forecast-db-read" {
  value = aws_iam_policy.rds-secret-policy
}

output "forecast-database-secret" {
  value = aws_secretsmanager_secret.db-forecast-secret
}

output "forecast-database-secret-url" {
  value = jsondecode(aws_secretsmanager_secret_version.forecast-version.secret_string)["url"]
}

output "iam-policy-pv-db-read" {
  value = aws_iam_policy.rds-pv-secret-policy
}

output "pv-database-secret" {
  value = aws_secretsmanager_secret.db-pv-secret
}

output "pv-database-secret-url" {
  value = jsondecode(aws_secretsmanager_secret_version.pv-version.secret_string)["url"]
}

output "iam-policy-pvsite-db-read" {
  value = aws_iam_policy.rds-pvsite-secret-policy
}

output "pvsite-database-secret" {
  value = aws_secretsmanager_secret.db-pvsite-secret
}

output "pvsite-database-secret-url" {
  value = jsondecode(aws_secretsmanager_secret_version.pvsite-version.secret_string)["url"]
}
