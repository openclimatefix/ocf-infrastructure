# Read in secrets for API for MetOffice Weather DataHub

data "aws_secretsmanager_secret" "nwp-api" {
  name = "development/consumer/nwp"
  #  arn = "arn:aws:secretsmanager:eu-west-2::secret:development/consumer/nwp"
}

data "aws_secretsmanager_secret_version" "nwp-api-version" {
  secret_id = data.aws_secretsmanager_secret.nwp-api.id
  #  arn = "arn:aws:secretsmanager:eu-west-2::secret:development/consumer/nwp"
}
