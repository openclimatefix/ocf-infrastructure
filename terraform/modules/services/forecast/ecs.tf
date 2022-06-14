# define aws ecs task definition
# needs access to the internet

resource "aws_ecs_task_definition" "forecast-task-definition" {
  family                   = "forecast"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  # specific values are needed -
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = 1024
  memory = 2048

  task_role_arn      = aws_iam_role.forecast-iam-role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role-forecast.arn
  container_definitions = jsonencode([
    {
      name  = "forecast"
      image = "openclimatefix/nowcasting_forecast:${var.docker_version}"
      #      cpu       = 128
      #      memory    = 128
      essential = true

      environment : [
        { "name" : "LOGLEVEL", "value" : "DEBUG"},
        { "name" : "FAKE", "value" : "False" },
        { "name" : "GIT_PYTHON_REFRESH", "value" : "quiet" },
        {"name": "MODEL_NAME", "value":"cnn"},
        {"name": "BATCH_SAVE_DIR", "value": "s3://nowcasting-ml-models-development/"},
        {"name": "ENVIRONMENT", "value": var.environment}
      ]

      secrets : [
        {
          "name" : "DB_URL",
          "valueFrom" : "${var.database_secret.arn}:url::",
        },
        {
          "name" : "DB_URL_PV",
          "valueFrom" : "${var.pv_database_secret.arn}:url::",
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
