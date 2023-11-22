# define aws ecs task definition
# needs access to the internet

resource "aws_ecs_task_definition" "sat-task-definition" {
  family                   = "sat"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  # specific values are needed -
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = 1024
  memory = 5120

  tags = {
    name = "sat-consumer"
    type = "ecs"
  }


  task_role_arn      = aws_iam_role.consumer-sat-iam-role.arn
  execution_role_arn = var.ecs-task_execution_role_arn
  container_definitions = jsonencode([
    {
      name  = "sat-consumer"
      image = "openclimatefix/satip:${var.docker_version}"
      #      cpu       = 128
      #      memory    = 128
      essential = true

      environment : [
        { "name" : "SAVE_DIR", "value" : "s3://${var.s3-bucket.id}/data" },
        { "name" : "SAVE_DIR_NATIVE", "value" : "s3://${var.s3-bucket.id}/raw" },
        { "name" : "LOG_LEVEL", "value" : "DEBUG"},
        { "name" : "HISTORY", "value" : "120 minutes"},
      ]

      secrets : [
        {
          "name" : "API_KEY",
          "valueFrom" : "${data.aws_secretsmanager_secret_version.sat-api-version.arn}:API_KEY::",
        },
        {
          "name" : "API_SECRET",
          "valueFrom" : "${data.aws_secretsmanager_secret_version.sat-api-version.arn}:API_SECRET::",
        },
        {
          "name" : "DB_URL",
          "valueFrom" : "${var.database_secret.arn}:url::",
        }
      ]

      logConfiguration : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : var.log-group-name,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "streaming"
        }
      }
    }
  ])
}


resource "aws_ecs_task_definition" "sat-clean-up-task-definition" {
  family                   = "sat-clean-up"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  # specific values are needed -
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = 512
  memory = 1024


  task_role_arn      = aws_iam_role.consumer-sat-iam-role.arn
  execution_role_arn = var.ecs-task_execution_role_arn
  container_definitions = jsonencode([
    {
      name  = "sat-clean-up-consumer"
      image = "openclimatefix/satip:${var.docker_version}"
      #      cpu       = 128
      #      memory    = 128
      essential = true

      environment : [
        { "name" : "SAVE_DIR", "value" : "s3://${var.s3-bucket.id}/data" },
        { "name" : "LOG_LEVEL", "value" : "DEBUG"},
        { "name" : "CLEANUP",  "value" : "1" },
      ]

      secrets : [
        {
          "name" : "API_KEY",
          "valueFrom" : "${data.aws_secretsmanager_secret_version.sat-api-version.arn}:API_KEY::",
        },
        {
          "name" : "API_SECRET",
          "valueFrom" : "${data.aws_secretsmanager_secret_version.sat-api-version.arn}:API_SECRET::",
        },
        {
          "name" : "DB_URL",
          "valueFrom" : "${var.database_secret.arn}:url::",
        }
      ]

      logConfiguration : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : var.log-group-name,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "streaming"
        }
      }
    }
  ])
}
