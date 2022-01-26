# define aws ecs task definition
# needs access to the internet

resource "aws_ecs_task_definition" "forecast-task-definition" {
  family                   = "forecast"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  # specific values are needed -
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = 256
  memory = 512

  task_role_arn      = aws_iam_role.forecast-iam-role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role-forecast.arn
  container_definitions = jsonencode([
    {
      name  = "forecast"
      image = "openclimatefix/nowcasting_forecast:latest"
      #      cpu       = 128
      #      memory    = 128
      essential = true

      environment : [
        { "name" : "FAKE", "value" : "False" },
        { "name" : "GIT_PYTHON_REFRESH", "value" : "quiet" },
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
