# set up cloudwatch log group

resource "aws_cloudwatch_log_group" "nwp" {
  name = var.log-group-name

  retention_in_days = 7

  tags = {
    Environment = var.environment
    Application = "nowcasting"
  }
}
