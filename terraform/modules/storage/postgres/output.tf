output "secret-policy" {
  description = "The iam policy allowing read access on the database secret"
  value = aws_iam_policy.rds-secret-iam-policy
}

output "secret" {
  description = "The secret generated for AWS secret manager"
  value = aws_secretsmanager_secret.db-secret
}

output "default_db_connection_url" {
  description = "The connection URL to the default database in the RDS instance"
  value = jsondecode(aws_secretsmanager_secret_version.db-secret-version.secret_string)["url"]
}

output "instance_connection_url" {
  description = "The connection URL to the RDS instance. Does not include the database name"
  value = trimsuffix(
    jsondecode(aws_secretsmanager_secret_version.db-secret-version.secret_string)["url"],
    "/${aws_db_instance.postgres-db.db_name}"
    )
}
