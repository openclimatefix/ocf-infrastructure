# define aws ecs task definition
# needs access to the internet

resource "aws_ecs_task_definition" "ecs-task-definition" {
  family                   = var.app-name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  # specific values are needed -
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = 1024
  memory = var.ecs_config.memory_mb

  task_role_arn      = aws_iam_role.app-role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name  = "forecast"
      image = "${var.ecs_config.docker_image}:${var.ecs_config.docker_version}"
      #      cpu       = 128
      #      memory    = 128
      essential = true

      environment : [
        {"name": "LOGLEVEL", "value" : "DEBUG"},
        {"name": "NWP_ZARR_PATH", "value":"s3://${var.s3_nwp_bucket.bucket_id}/data/latest.netcdf"},
        {"name": "ML_MODEL_PATH", "value": "s3://${var.s3_ml_bucket.bucket_id}/"},
        {"name": "ENVIRONMENT", "value": var.environment},
      ]

      secrets : [
        {
          "name" : "OCF_PV_DB_URL",
          "valueFrom" : "${var.rds_config.database_secret_arn}:url::",
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
