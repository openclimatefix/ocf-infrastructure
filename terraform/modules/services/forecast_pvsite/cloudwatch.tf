# set up cloudwatch log group

resource "aws_cloudwatch_log_group" "predictor" {
  name = local.log-group-name

  retention_in_days = 7

  tags = {
    Environment = var.environment
    Application = var.app-name
  }
}
