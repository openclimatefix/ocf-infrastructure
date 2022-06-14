# Read in secrets for API for EUMETSAT API

data "aws_secretsmanager_secret" "sat-api" {
  name = "${var.environment}/consumer/sat"
}

data "aws_secretsmanager_secret_version" "sat-api-version" {
  secret_id = data.aws_secretsmanager_secret.sat-api.id
}
