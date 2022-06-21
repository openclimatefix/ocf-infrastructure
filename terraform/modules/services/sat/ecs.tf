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

  task_role_arn      = aws_iam_role.consumer-sat-iam-role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name  = "sat-consumer"
      image = "openclimatefix/satip:${var.docker_version}"
      #      cpu       = 128
      #      memory    = 128
      essential = true

      environment : [
        { "name" : "SAVE_DIR", "value" : "s3://${var.s3-bucket.id}/data" },
        { "name" : "LOG_LEVEL", "value" : "DEBUG"},
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

  # add volume? So we dont have to keep downloading same docker image
}
