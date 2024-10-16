# define aws ecs task definition
# needs access to the internet

resource "aws_ecs_task_definition" "ecs-task-definition" {
  family                   = var.app-name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  tags = {
    name = "${var.app-name}-forecaster"
    type = "ecs"
  }

  # specific values are needed -
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = var.ecs_config.cpu
  memory = var.ecs_config.memory_mb

  task_role_arn      = aws_iam_role.app-role.arn
  execution_role_arn = var.ecs-task_execution_role_arn
  container_definitions = jsonencode([
    {
      name  = "forecast"
      image = "${var.ecs_config.docker_image}:${var.ecs_config.docker_version}"
      #      cpu       = 128
      #      memory    = 128
      essential = true

      environment : [
        {"name": "LOGLEVEL", "value" : var.loglevel},
        {"name": "NWP_ZARR_PATH", "value":"s3://${var.s3_nwp_bucket.bucket_id}/${var.s3_nwp_bucket.datadir}/latest.zarr"},
        {"name": "NWP_UKV_ZARR_PATH", "value":"s3://${var.s3_nwp_bucket.bucket_id}/${var.s3_nwp_bucket.datadir}/latest.zarr"},
        {"name": "NWP_ECMWF_ZARR_PATH", "value":"s3://${var.s3_nwp_bucket.bucket_id}/ecmwf/data/latest.zarr"},
        {"name": "NWP_GFS_ZARR_PATH", "value":"s3://${var.s3_nwp_bucket.bucket_id}/gfs/data/latest.zarr"},
        {"name": "SATELLITE_ZARR_PATH", "value":"s3://${var.s3_satellite_bucket.bucket_id}/${var.s3_satellite_bucket.datadir}/latest.zarr.zip"},
        {"name": "ML_MODEL_PATH", "value": "s3://${var.s3_ml_bucket.bucket_id}/"},
        {"name": "ML_MODEL_BUCKET", "value": var.s3_ml_bucket.bucket_id},
        {"name": "ENVIRONMENT", "value": var.environment},
        {"name": "OCF_ENVIRONMENT", "value": var.environment},
        {"name": "USE_ADJUSTER", "value": var.use_adjuster},
        {"name": "SAVE_GSP_SUM", "value": var.pvnet_gsp_sum},
        {"name": "ESMFMKFILE",  "value": "/opt/conda/lib/esmf.mk"},
        {"name": "SENTRY_DSN",  "value": var.sentry_dsn},
        {"name": "RUN_EXTRA_MODELS",  "value": var.run_extra_models},
        {"name": "DAY_AHEAD_MODEL",  "value": var.day_ahead_model}
        {"name": "USE_OCF_DATA_SAMPLER",  "value": var.use_data_sample}
      ]

      secrets : [
        {
          "name" : "OCF_PV_DB_URL",
          "valueFrom" : "${var.rds_config.database_secret_arn}:url::",
        },
        {
          "name": "DB_URL",
          "valueFrom": "${var.rds_config.database_secret_arn}:url::",
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
