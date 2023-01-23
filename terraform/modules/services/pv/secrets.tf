# Read in secrets for API for pvoutput.org API

data "aws_secretsmanager_secret" "pv-api" {
  name = "${var.environment}/consumer/pvoutput"
}

data "aws_secretsmanager_secret" "pv-ss" {
  name = "${var.environment}/consumer/solar_sheffield"
}

data "aws_secretsmanager_secret_version" "pv-api-version" {
  secret_id = data.aws_secretsmanager_secret.pv-api.id
}

data "aws_secretsmanager_secret_version" "pv-ss-version" {
  secret_id = data.aws_secretsmanager_secret.pv-ss.id
}


# This gets the URL for the pv sites database
data "aws_secretsmanager_secret" "pv-sites-database" {
  name = "${var.environment}/rds/pvsite/"
}

data "aws_secretsmanager_secret_version" "pv-sites-database-version" {
  secret_id = data.aws_secretsmanager_secret.pv-sites-database.id
}
