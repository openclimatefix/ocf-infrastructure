# define aws ecs task definition
# needs access to the internet

resource "aws_ecs_task_definition" "metrics-task-definition" {
  family                   = "metrics"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  tags = {
    name = "metrics-consumer"
    type = "ecs"
  }

  # specific values are needed -
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = 256
  memory = 512

  task_role_arn      = aws_iam_role.metrics-iam-role.arn
  execution_role_arn = var.ecs-task_execution_role_arn
  container_definitions = jsonencode([
    {
      name  = "metrics"
      image = "openclimatefix/nowcasting_metrics:${var.docker_version}"
      #      cpu       = 128
      #      memory    = 128
      essential = true

      environment : [
        { "name" : "LOGLEVEL", "value" : "DEBUG"},
        { "name" : "USE_PVNET_GSP_SUM", "value" : var.use_pvnet_gsp_sum},
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
