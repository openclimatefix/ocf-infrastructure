# Create secret for database password and connection details.
# This connection details will be used to read and write to the database

# Firstly we will create a random generated password which we will use in secrets.
resource "random_password" "db-forecast-password" {
  length           = 16
  special          = true
  override_special = "%"
}

resource "random_password" "db-pv-password" {
  length           = 16
  special          = true
  override_special = "%"
}


# Now create secret and secret versions for database main account
resource "aws_secretsmanager_secret" "db-forecast-secret" {
  name = "${var.environment}/rds/forecast/"
  # Once the secret is deleted, we cant get it back.
  # If we don't do this, then a new secret can be made with the same name until the recovery window is over
  recovery_window_in_days = 0

  description = "Secret to hold log in details for RDS forecast database"
}


resource "aws_secretsmanager_secret_version" "forecast-version" {
  secret_id = aws_secretsmanager_secret.db-forecast-secret.id
  secret_string = jsonencode(
    {
      username : "main",
      password : random_password.db-forecast-password.result,
      dbname : aws_db_instance.db-forecast.db_name,
      engine : "postgresql",
      address : aws_db_instance.db-forecast.address,
      port : "5432",
      url : "postgresql://main:${random_password.db-forecast-password.result}@${aws_db_instance.db-forecast.address}:5432/${aws_db_instance.db-forecast.db_name}"
      DB_URL : "postgresql://main:${random_password.db-forecast-password.result}@${aws_db_instance.db-forecast.address}:5432/${aws_db_instance.db-forecast.db_name}"
      airflow_url : "postgresql://main:${random_password.db-forecast-password.result}@${aws_db_instance.db-forecast.address}:5432/airflow"
  })
}

