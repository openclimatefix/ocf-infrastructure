# Create secret for database password and connection details.
# This connection details will be used to read and write to the database

# Firstly we will create a random generated password which we will use in secrets.
resource "random_password" "DB-forecast-password" {
  length           = 16
  special          = true
  override_special = "%"
}


# Now create secret and secret versions for database main account
resource "aws_secretsmanager_secret" "DB-forecast-secret" {
  name = "RDS/forecast/${var.environment}"
  # Once the secret is deleted, we cant get it back.
  # If we don't do this, then a new secret can be made with the same name until the recovery window is over
  recovery_window_in_days = 0

  description = "Secret to hold log in details for RDS forecast database"
}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id = aws_secretsmanager_secret.DB-forecast-secret.id
  secret_string = jsonencode(
    {
      username : "main",
      password : random_password.DB-forecast-password.result,
      dbname : aws_db_instance.DB-forecast.name,
      engine : "postgresql",
      address : aws_db_instance.DB-forecast.address,
      port : "5432",
      url : "postgresql://main:${random_password.DB-forecast-password.result}@${aws_db_instance.DB-forecast.address}:5432/${aws_db_instance.DB-forecast.name}"
  })
}
