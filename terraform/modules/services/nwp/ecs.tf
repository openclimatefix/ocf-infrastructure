# define aws ecs task definition
# needs access to the internet

resource "aws_ecs_task_definition" "nwp-task-definition" {
  family                   = "nwp"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  # specific values are needed -
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = 256
  memory = 512

  task_role_arn      = aws_iam_role.consumer-nwp-iam-role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name  = "nwp-consumer"
      image = "openclimatefix/metoffice_weather_datahub:latest"
      #      cpu       = 128
      #      memory    = 128
      essential = true

      environment : [
        { "name" : "SAVE_DIR", "value" : "s3://${var.s3-bucket.id}/data" },
      ]

      secrets : [
        {
          "name" : "API_KEY",
          "valueFrom" : "${data.aws_secretsmanager_secret_version.nwp-api-version.arn}:API_KEY::",
        },
        {
          "name" : "API_SECRET",
          "valueFrom" : "${data.aws_secretsmanager_secret_version.nwp-api-version.arn}:API_SECRET::",
        },
        {
          "name" : "LOG_LEVEL",
          "valueFrom" : "DEBUG",
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

  #  volume {
  #    name      = "service-storage"
  #    host_path = "/ecs/service-storage"
  #  }
  #
  #  placement_constraints {
  #    type       = "memberOf"
  #    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  #  }
}
