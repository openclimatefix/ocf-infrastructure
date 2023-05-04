# define aws ecs task definition
# needs access to the internet

resource "aws_ecs_task_definition" "gsp-task-definition" {
  family                   = "gsp"
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
      name  = "gsp-consumer"
      image = "openclimatefix/gspconsumer:${var.docker_version}"
      #      cpu       = 128
      #      memory    = 128
      essential = true

      environment : [
        { "name" : "LOGLEVEL", "value" : "DEBUG"},
        { "name" :"REGIME", "value" : "in-day"},
        { "name" :"N_GSPS", "value" : "317"}
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
  family                   = "gsp-day-after"
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
      name  = "gsp-consumer-day-after"
      image = "openclimatefix/gspconsumer:${var.docker_version}"
      #      cpu       = 128
      #      memory    = 128
      essential = true

      environment : [
        { "name" : "LOGLEVEL", "value" : "DEBUG"},
        { "name" :"REGIME", "value" : "day-after"},
        { "name" :"N_GSPS", "value" : "317"},
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

resource "aws_ecs_task_definition" "national-day-after-task-definition" {
  family                   = "national-day-after"
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
      name  = "national-day-after"
      image = "openclimatefix/gspconsumer:${var.docker_version}"
      #      cpu       = 128
      #      memory    = 128
      essential = true

      environment : [
        { "name" : "LOGLEVEL", "value" : "DEBUG"},
        { "name" :"REGIME", "value" : "day-after"},
        { "name" :"N_GSPS", "value" : "0"},
        { "name" :"INCLUDE_NATIONAL", "value" : "True"},
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
}
