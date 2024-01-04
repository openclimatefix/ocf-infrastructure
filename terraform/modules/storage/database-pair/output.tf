output "iam-policy-forecast-db-read" {
  value = aws_iam_policy.rds-secret-policy
}

output "forecast-database-secret" {
  value = aws_secretsmanager_secret.db-forecast-secret
}

output "forecast-database-secret-url" {
  value = jsondecode(aws_secretsmanager_secret_version.forecast-version.secret_string)["url"]
}

output "forecast-database-secret-airflow-url" {
  value = jsondecode(aws_secretsmanager_secret_version.forecast-version.secret_string)["airflow_url"]
}
