# Read in secrets for API for MetOffice Weather DataHub

data "aws_secretsmanager_secret" "database-sites" {
  name = "${var.environment}/rds/pvsite"
}

data "aws_secretsmanager_secret_version" "database-sites-version" {
  secret_id = data.aws_secretsmanager_secret.database-sites.id
}