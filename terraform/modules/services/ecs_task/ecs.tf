# Creates:
# 1. ECS Task Definition

# 1. Create the ECS Task Definition
resource "aws_ecs_task_definition" "task_def" {
  family                   = var.ecs-task_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = var.ecs-task_size.cpu
  memory = var.ecs-task_size.memory

  tags = {
    name = "${var.ecs-task_name}-${var.ecs-task_type}"
    type = "ecs"
  }

  volume {
    name = "${var.ecs-task_name}-temp-data"
    docker_volume_configuration {
      scope = "task"
      driver = "local"
    }
  }

  ephemeral_storage {
    size_in_gib = var.ecs-task_size.storage
  }

  task_role_arn         = aws_iam_role.run_task_role.arn
  execution_role_arn    = var.ecs-task_execution_role_arn
  container_definitions = jsonencode([
    {
      name      = "${var.ecs-task_name}-${var.ecs-task_type}"
      image     = "${var.container-registry}/${var.container-name}:${var.container-tag}"
      essential = true

      environment : var.container-env_vars
      command : var.container-command

      secrets : [
        for key in var.container-secret_vars : {
          name : key
          valueFrom : "${var.aws-secretsmanager_secret_arn}:${key}::"
        }
      ]

      logConfiguration : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : local.log_group_name,
          "awslogs-region" : var.aws-region,
          "awslogs-stream-prefix" : "streaming"
        }
      }

      mountPoints : [
        {
          "containerPath" : "/tmp/nwpc",
          "sourceVolume" : "${var.ecs-task_name}-temp-data"
        }
      ]
    }
  ])
}
