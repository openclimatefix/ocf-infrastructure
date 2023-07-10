# Create secret for database password and connection details.
# This connection details will be used to read and write to the database

# Firstly we will create a random generated password which we will use in secrets.
resource "random_password" "airflow-password" {
  length           = 16
  special          = true
  override_special = "%"
}

resource "random_password" "secret-password" {
  length           = 16
  special          = true
  override_special = "%"
}

resource "random_password" "fernet-password" {
  length           = 16
  special          = true
  override_special = "%"
}


# Now create secret and secret versions for database main account
resource "aws_secretsmanager_secret" "airflow-secret" {
  name = "${var.environment}/airflow/login/"
  # Once the secret is deleted, we cant get it back.
  # If we don't do this, then a new secret can be made with the same name until the recovery window is over
  recovery_window_in_days = 0

  description = "Secret to hold log in details for airflow"
}

resource "aws_secretsmanager_secret_version" "forecast-version" {
  secret_id = aws_secretsmanager_secret.airflow-secret.id
  secret_string = jsonencode(
    {
      username : "airflow",
      password : random_password.airflow-password.result,
      secret : random_password.secret-password.result,
      fernet : random_password.fernet-password.result,
  })
}
