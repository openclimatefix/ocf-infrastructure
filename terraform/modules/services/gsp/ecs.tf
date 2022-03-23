# define aws ecs task definition
# needs access to the internet

resource "aws_ecs_task_definition" "gsp-task-definition" {
  family                   = "pv"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  # specific values are needed -
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = 256
  memory = 512

  task_role_arn      = aws_iam_role.consumer-gsp-iam-role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name  = "pv-consumer"
      image = "openclimatefix/gspconsumer:${var.docker_version}"
      #      cpu       = 128
      #      memory    = 128
      essential = true

      environment : [
        { "name" : "LOGLEVEL", "value" : "DEBUG"},
        { "name" :"REGIME", "value" : "in-day"}
      ]

      secrets : [
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

  # add volume? So we dont have to keep downloading same docker image
}

resource "aws_ecs_task_definition" "gsp-day-after-task-definition" {
  family                   = "pv"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  # specific values are needed -
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = 256
  memory = 512

  task_role_arn      = aws_iam_role.consumer-gsp-iam-role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name  = "pv-consumer"
      image = "openclimatefix/gspconsumer:${var.docker_version}"
      #      cpu       = 128
      #      memory    = 128
      essential = true

      environment : [
        { "name" : "LOGLEVEL", "value" : "DEBUG"},
        { "name" :"REGIME", "value" : "day-after"}
      ]

      secrets : [
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

  # add volume? So we dont have to keep downloading same docker image
}
