# Create secret for database password and connection details.
# This connection details will be used to read and write to the database

# Firstly we will create a random generated password which we will use in secrets.
resource "random_password" "db-password" {
  length           = 16
  special          = true
  override_special = "%"
}

# Now create secret and secret versions for database main account
resource "aws_secretsmanager_secret" "db-secret" {
  name = "${var.environment}/rds/${var.db_name}"
  # Once the secret is deleted, we cant get it back.
  # If we don't do this, then a new secret can be made with the same name until the recovery window is over
  recovery_window_in_days = 0

  description = "Secret to hold log in details for RDS database"
}

resource "aws_secretsmanager_secret_version" "db-secret-version" {
  secret_id = aws_secretsmanager_secret.db-secret.id
  secret_string = jsonencode(
    {
      username : "main",
      password : random_password.db-password.result,
      dbname : aws_db_instance.postgres-db.db_name,
      engine : "postgresql",
      address : aws_db_instance.postgres-db.address,
      port : "5432",
      url : "postgresql://main:${random_password.db-password.result}@${aws_db_instance.postgres-db.address}:5432/${aws_db_instance.postgres-db.db_name}"
      DB_URL : "postgresql://main:${random_password.db-password.result}@${aws_db_instance.postgres-db.address}:5432/${aws_db_instance.postgres-db.db_name}"
      OCF_PV_DB_URL : "postgresql://main:${random_password.db-password.result}@${aws_db_instance.postgres-db.address}:5432/${aws_db_instance.postgres-db.db_name}"
  })
}
