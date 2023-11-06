# Read in required secrets for consumer

data "aws_secretsmanager_secret" "nwp-consumer-secret" {
  name = "${var.environment}/consumer/${var.consumer-name}"
  #  arn = "arn:aws:secretsmanager:eu-west-2::secret:development/consumer/nwp"
}

