resource "aws_cloudwatch_log_group" "nwp" {
  name = "ecs/consumer/nwp/"

  retention_in_days=7

  tags = {
    Environment = var.environment
    Application = "nowcasting"
  }
}
