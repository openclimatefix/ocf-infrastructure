# Read in secrets for API for pvoutput.org API

data "aws_secretsmanager_secret" "pv-api" {
  name = "${var.environment}/consumer/pvoutput"
}

data "aws_secretsmanager_secret_version" "pv-api-version" {
  secret_id = data.aws_secretsmanager_secret.pv-api.id
}
