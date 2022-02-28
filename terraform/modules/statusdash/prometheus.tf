resource "aws_prometheus_workspace" "statusdash" {
  alias = "statusdash-nowcasting"
}

# resource "aws_ecs_service" "monitoring" {
#   name            = "monitoring"
#   cluster         = aws_ecs_cluster.main.id
# var.ecs-cluster.arn
#   task_definition = aws_ecs_task_definition.statusdash-task-definition.arn
#   desired_count   = 1
#   # CHECK DOWN
#   iam_role        = aws_iam_role.foo.arn
#   depends_on      = [aws_iam_role_policy.foo]

#   ordered_placement_strategy {
#     type  = "binpack"
#     field = "cpu"
#   }

#   placement_constraints {
#     type       = "memberOf"
#     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
#   }
# }

# resource "aws_ecs_task_definition" "statusdash-task-definition" {
#   family = "statusdash"
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"

#   cpu    = 256
#   memory = 512

#   container_definitions = jsonencode([
#     {
#       name      = "prometheus"
#       image     = "openclimatefix/nowcasting_status:v0.1.0"
#       essential = true
#     }
#   ])
# }