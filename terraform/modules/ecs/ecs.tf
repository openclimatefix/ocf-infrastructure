# Make ECS cluster
# useful blog - https://engineering.finleap.com/posts/2020-02-20-ecs-fargate-terraform/
resource "aws_ecs_cluster" "main" {
  name = "${title(var.domain)}-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
