# Read in secrets for API for EUMETSAT API

data "aws_secretsmanager_secret" "sat-api" {
  name = "development/consumer/sat"
  arn = "arn:aws:secretsmanager:eu-west-2::secret:development/consumer/sat"
}

data "aws_secretsmanager_secret_version" "sat-api-version" {
  secret_id = data.aws_secretsmanager_secret.sat-api.id
  arn = "arn:aws:secretsmanager:eu-west-2::secret:development/consumer/sat"
}
