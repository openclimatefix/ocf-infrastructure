# define aws ecs task definition
# needs access to the internet

resource "aws_ecs_task_definition" "nwp-task-definition" {
  family                   = "${var.consumer-name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  # specific values are needed -
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = 1024
  memory = 5120

  tags = {
    name = "${var.consumer-name}-consumer"
    type = "ecs"
  }

  task_role_arn      = aws_iam_role.consumer-nwp-iam-role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name  = "${var.consumer-name}-consumer"
      image = "ghcr.io/openclimatefix/nwp-consumer:${var.docker_version}"
      #      cpu       = 128
      #      memory    = 128
      essential = true

      environment : [
        { "name" : "AWS_REGION", "value" : "eu-west-1" },
        { "name" : "AWS_S3_BUCKET", "value" : var.s3_config.bucket_id },
        { "name" : "LOGLEVEL", "value" : "DEBUG"},
      ]

      command: var.command

      secrets : [
        {
          "name" : "METOFFICE_CLIENT_ID",
          "valueFrom" : "${data.aws_secretsmanager_secret_version.nwp-api-version.arn}:API_KEY::",
        },
        {
          "name" : "METOFFICE_CLIENT_SECRET",
          "valueFrom" : "${data.aws_secretsmanager_secret_version.nwp-api-version.arn}:API_SECRET::",
        },
        {
          "name" : "DB_URL",
          "valueFrom" : "${var.database_secret.arn}:url::",
        },
        {
          "name": "METOFFICE_ORDER_ID",
          "valueFrom": "${data.aws_secretsmanager_secret_version.nwp-api-version.arn}:ORDER_IDS::",
        }
      ]

      logConfiguration : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : local.log_group_name,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "streaming"
        }
      }

      mountPoints: [
        {
          "containerPath" : "/tmp/nwpc",
          "sourceVolume" : "tmp"
        }
      ]

      volumes: [
        {
          "name": "tmp",
        }
      ]

    }
  ])

  # add volume? So we dont have to keep downloading same docker image
}
