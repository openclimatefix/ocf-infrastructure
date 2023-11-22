# define aws ecs task definition
# needs access to the internet

resource "aws_ecs_task_definition" "ecs-task-definition" {
  family                   = var.app-name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  tags = {
    name = "db-housekeeper"
    type = "ecs"
  }

  # specific values are needed -
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = var.ecs_config.cpu
  memory = var.ecs_config.memory_mb

  task_role_arn      = aws_iam_role.app-role.arn
  execution_role_arn = var.ecs-task_execution_role_arn
  container_definitions = jsonencode([
    {
      name  = "database_clean_up"
      image = "${var.ecs_config.docker_image}:${var.ecs_config.docker_version}"
      #      cpu       = 128
      #      memory    = 128
      essential = true

      environment : [
        {"name": "LOGLEVEL", "value" : "DEBUG"},
      ]

      secrets : [
        {
          "name" : "OCF_PV_DB_URL",
          "valueFrom" : "${var.rds_config.database_secret_arn}:url::",
        },
        {
          "name": "DB_URL",
          "valueFrom": "${var.rds_config.database_secret_arn}:url::",
        },
      ]

      logConfiguration : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : local.log-group-name,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "streaming"
        }
      }
    }
  ])

}
