# Creates:
# 1. ECS Task to run the Consumer

# Create the ECS Task Definition
resource "aws_ecs_task_definition" "nwp-task-definition" {
  family                   = "${var.app_name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  # specific values are needed -
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = 1024
  memory = 5120

  tags = {
    name = "${var.app_name}-consumer"
    type = "ecs"
  }

  volumes : [
    {
      "name" : "tmp",
    }
  ]

  task_role_arn         = aws_iam_role.consumer-nwp-iam-role.arn
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-consumer"
      image     = "ghcr.io/openclimatefix/nwp-consumer:${var.docker_config.container_tag}"
      essential = true

      environment : var.docker_config.environment_vars
      command : var.docker_config.command

      secrets : [
        for key in var.docker_config.secret_vars : {
          name : key
          valueFrom : "${data.aws_secretsmanager_secret_version.current.arn}:${key}::"
        }
      ]

      logConfiguration : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : local.log_group_name,
          "awslogs-region" : var.aws_config.region,
          "awslogs-stream-prefix" : "streaming"
        }
      }

      mountPoints : [
        {
          "containerPath" : "/tmp/nwpc",
          "sourceVolume" : "tmp"
        }
      ]
    }
  ])
}
