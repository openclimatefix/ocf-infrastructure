/*====

This is the main terraform code for the UK platform. It is used to deploy the platform to AWS.

The componentes ares:
0.1 - Networking
0.2 - EC2 bastion
0.3 - S3 buckets
0.4 - ECS cluster
0.5 - S3 bucket for forecasters
1.1 - API
2.1 - Database
2.2 - NWP Consumer Secret
2.3 - Satellite Consumer Secret
2.4 - PV Secret
3.2 - NWP Consumer (MetOffice National)
3.3 - NWP Consumer (ECMWF UK)
3.4 - Satellite Consumer
3.5 - Satellite Data Tailor Clean up
3.6 - PV Consumer
3.7 - PVLive Consumer (From PVLive)
3.8 - PVLive Consumer - GSP Day After
3.9 - PVLive Consumer - National Day After
4.1 - Metrics
4.2 - Forecast PVnet 1
4.3 - Forecast National XG
4.4 - Forecast PVnet 2
4.5 - Forecast PVnet ECMWF only
4.6 - Forecast PVnet DA
4.7 - Forecast Blend
5.1 - OCF Dashboard
5.2 - Airflow instance
6.1 - PVSite database
6.2 - PVSite API
6.3 - PVSite ML bucket
6.4 - PVSite Forecast
6.5 - PVSite Database Clean Up
7.1 - Open Data PVnet

Variables used across all modules
======*/
locals {
  environment = "development"
  domain = "uk"
}

# 0.1
module "networking" {
  source = "../../modules/networking"
  domain = local.domain
  environment = local.environment
  region = var.region
}

# 0.2
module "ec2-bastion" {
  source = "../../modules/networking/ec2_bastion"

  region            = var.region
  vpc_id            = module.networking.vpc_id
  public_subnets_id = module.networking.public_subnet_ids[0]
  bastion_ami = "ami-0069d66985b09d219"
}

# 0.3
module "s3" {
  source = "../../modules/storage/s3-trio"

  region      = var.region
  environment = local.environment
}

# 0.4
module "ecs" {
  source = "../../modules/ecs_cluster"
  name = "Nowcasting-${local.environment}"
  region = var.region
  owner_id = module.networking.owner_id
}

# 0.5
module "forecasting_models_bucket" {
  source = "../../modules/storage/s3-private"

  region              = var.region
  environment         = local.environment
  service_name        = "national-forecaster-models"
  domain              = local.domain
  lifecycled_prefixes = []
}

# 1.1
module "api" {
  source             = "../../modules/services/eb_app"
  domain             = local.domain
  aws-region         = var.region
  aws-environment    = local.environment
  aws-subnet_id      = module.networking.public_subnet_ids[0]
  aws-vpc_id         = module.networking.vpc_id
  container-command  = ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "80"]
  container-env_vars = [
    { "name" : "DB_URL", "value" :  module.database.forecast-database-secret-url},
    { "name" : "ORIGINS", "value" : "*" },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn_api },
    { "name" : "AUTH0_DOMAIN", "value" : var.auth_domain },
    { "name" : "AUTH0_API_AUDIENCE", "value" : var.auth_api_audience },
    { "name" : "AUTH0_RULE_NAMESPACE", "value" : "https://openclimatefix.org"},
    { "name" : "AUTH0_CLIENT_ID", "value" : var.auth_dashboard_client_id },
    { "name" : "ADJUST_MW_LIMIT", "value" : "1000" },
    { "name" : "N_HISTORY_DAYS", "value" : "2" },
    { "name" : "ENVIRONMENT", "value" : local.environment },
  ]
  container-name = "nowcasting_api"
  container-tag  = var.api_version
  container-registry = "openclimatefix"
  eb-app_name    = "nowcasting-api"
  eb-instance_type = "t3.small"
  s3_bucket = [
    { bucket_read_policy_arn = module.s3.iam-policy-s3-nwp-read.arn },
    { bucket_read_policy_arn = module.s3.iam-policy-s3-sat-read.arn }
  ]
  max_ec2_count = 2
}

# 2.1
module "database" {
  source = "../../modules/storage/database-pair"

  region               = var.region
  environment          = local.environment
  db_subnet_group_name = module.networking.private_subnet_group_name
  vpc_id               = module.networking.vpc_id
}

# 2.2
resource "aws_secretsmanager_secret" "nwp_consumer_secret" {
  name = "${local.environment}/data/nwp-consumer"
}


# 2.3
resource "aws_secretsmanager_secret" "satellite_consumer_secret" {
  name = "${local.environment}/data/satellite-consumer"
}

# 2.4
# TODO remove
import {
  to = aws_secretsmanager_secret.pv_consumer_secret
  id = "arn:aws:secretsmanager:eu-west-1:008129123253:secret:development/consumer/solar_sheffield-2Tyskm"
}

resource "aws_secretsmanager_secret" "pv_consumer_secret" {
  name = "${local.environment}/data/solar-sheffield"
}


# 3.2
module "nwp-metoffice" {
  source = "../../modules/services/ecs_task"

  ecs-task_name = "nwp-metoffice"
  ecs-task_type = "consumer"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs-task_size = {
    cpu    = 1024
    memory = 8192
  }

  aws-region                     = var.region
  aws-environment                = local.environment

  s3-buckets = [
    {
      id : module.s3.s3-nwp-bucket.id
      access_policy_arn : module.s3.iam-policy-s3-nwp-write.arn
    }
  ]

  container-env_vars = [
    { "name" : "AWS_REGION", "value" : "eu-west-1" },
    { "name" : "AWS_S3_BUCKET", "value" : module.s3.s3-nwp-bucket.id },
    { "name" : "LOGLEVEL", "value" : "DEBUG" },
    { "name" : "METOFFICE_ORDER_ID", "value" : "uk-12params-42steps" },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
    { "name" : "ENVIRONMENT", "value" : local.environment },
  ]
  container-secret_vars = [
  {secret_policy_arn: aws_secretsmanager_secret.nwp_consumer_secret.arn,
  values: ["METOFFICE_API_KEY"]}
  ]
  container-tag         = var.nwp_version
  container-name        = "openclimatefix/nwp-consumer"
  container-command     = [
    "download",
    "--source=metoffice",
    "--sink=s3",
    "--rdir=raw-metoffice",
    "--zdir=data-metoffice",
    "--create-latest"
  ]
}


# 3.3
module "nwp-ecmwf" {
  source = "../../modules/services/ecs_task"

  ecs-task_name               = "nwp-consumer-ecmwf-uk"
  ecs-task_type               = "consumer"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn

  ecs-task_size = {
    cpu = 512
    memory = 1024
  }

  aws-region                    = var.region
  aws-environment               = local.environment

  s3-buckets = [{
    id : module.s3.s3-nwp-bucket.id
    access_policy_arn : module.s3.iam-policy-s3-nwp-write.arn
  }]

  container-env_vars = [
    { "name" : "MODEL_REPOSITORY", "value" : "ecmwf-realtime" },
    { "name" : "AWS_REGION", "value" : "eu-west-1" },
    { "name" : "ECMWF_REALTIME_S3_REGION", "value": "eu-west-1" },
    { "name" : "ECMWF_REALTIME_S3_BUCKET", "value" : "ocf-ecmwf-production" },
    { "name" : "ZARRDIR", "value" : "s3://${module.s3.s3-nwp-bucket.id}/ecmwf/data" },
    { "name" : "LOGLEVEL", "value" : "DEBUG" },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
    { "name" : "CONCURRENCY", "value" : "false" },
    # legacy ones
    { "name" : "AWS_S3_BUCKET", "value" : module.s3.s3-nwp-bucket.id },
    { "name" : "ECMWF_AWS_REGION", "value": "eu-west-1" },
    { "name" : "ECMWF_AWS_S3_BUCKET", "value" : "ocf-ecmwf-production" },
    { "name" : "ECMWF_AREA", "value" : "uk" },
    { "name" : "ENVIRONMENT", "value" : local.environment },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
    { "name" : "LOGLEVEL", "value" : "DEBUG" }
  ]
  container-secret_vars = [
  {secret_policy_arn: aws_secretsmanager_secret.nwp_consumer_secret.arn,
  values: ["ECMWF_REALTIME_S3_ACCESS_KEY", "ECMWF_REALTIME_S3_ACCESS_SECRET"]}
  ]
  container-tag         = var.nwp_ecmwf_version
  container-name        = "openclimatefix/nwp-consumer"
  container-command     = ["consume"]
}

# 3.4 Sat Consumer
module "sat" {
  source = "../../modules/services/ecs_task"

  aws-region                    = var.region
  aws-environment               = local.environment

  s3-buckets = [
    {
      id : module.s3.s3-sat-bucket.id,
      access_policy_arn : module.s3.iam-policy-s3-sat-write.arn
    }
  ]

  ecs-task_name               = "sat"
  ecs-task_type               = "consumer"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs-task_size = {
    memory = 5120
    cpu    = 1024
  }

  container-env_vars = [
    { "name" : "AWS_REGION", "value" : var.region },
    { "name" : "LOGLEVEL", "value" : "DEBUG" },
    { "name" : "SAVE_DIR", "value" : "s3://${module.s3.s3-sat-bucket.id}/data" },
    { "name" : "SAVE_DIR_NATIVE", "value" : "s3://${module.s3.s3-sat-bucket.id}/raw" },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
    { "name" : "ENVIRONMENT", "value" : local.environment },
    { "name" : "HISTORY", "value" : "120 minutes" },
  ]
  container-secret_vars = [
  {secret_policy_arn: aws_secretsmanager_secret.satellite_consumer_secret.arn,
        values: ["API_KEY", "API_SECRET"]
       }]
  container-tag         = var.sat_version
  container-name        = "openclimatefix/satip"
  container-registry = "docker.io"
  container-command     = []
}

# 3.5 Sat Data Tailor clean up
module "sat_clean_up" {
  source = "../../modules/services/ecs_task"

  aws-region                    = var.region
  aws-environment               = local.environment

  s3-buckets = [
    {
      id : module.s3.s3-sat-bucket.id,
      access_policy_arn : module.s3.iam-policy-s3-sat-write.arn
    }
  ]

  ecs-task_name               = "sat-clean-up"
  ecs-task_type               = "consumer"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs-task_size = {
    memory = 1024
    cpu    = 512
  }

  container-env_vars = [
    { "name" : "AWS_REGION", "value" : var.region },
    { "name" : "LOGLEVEL", "value" : "DEBUG" },
    { "name" : "SAVE_DIR", "value" : "s3://${module.s3.s3-sat-bucket.id}/data" },
    { "name" : "SAVE_DIR_NATIVE", "value" : "s3://${module.s3.s3-sat-bucket.id}/raw" },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
    { "name" : "ENVIRONMENT", "value" : local.environment },
    { "name" : "HISTORY", "value" : "120 minutes" },
    { "name" : "CLEANUP",  "value" : "1" },

  ]
  container-secret_vars = [
  {secret_policy_arn: aws_secretsmanager_secret.satellite_consumer_secret.arn,
        values: ["API_KEY", "API_SECRET"]
       }]
  container-tag         = var.sat_version
  container-name        = "openclimatefix/satip"
  container-registry = "docker.io"
  container-command     = []
}

# 3.6
module "pv" {
  source = "../../modules/services/ecs_task"

  ecs-task_name = "pv"
  ecs-task_type = "consumer"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs-task_size = {
    cpu    = 256
    memory = 512
  }

  aws-region                     = var.region
  aws-environment                = local.environment

  s3-buckets = []

  container-env_vars = [
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
    { "name" : "ENVIRONMENT", "value" : local.environment },
    { "name" : "LOGLEVEL", "value" : "INFO"},
    { "name" : "PROVIDER", "value" : "solar_sheffield_passiv"},
  ]
  container-secret_vars = [
  {secret_policy_arn: module.pvsite_database.secret.arn,
  values: ["DB_URL"]},
  {secret_policy_arn: aws_secretsmanager_secret.pv_consumer_secret.arn,
  values: ["SS_USER_ID", "SS_KEY", "SS_URL"]}
  ]
  container-tag         = var.pv_ss_version
  container-name        = "openclimatefix/pvconsumer"
  container-registry = "docker.io"
  container-command     = []
}


# 3.7
module "gsp-consumer" {
  source = "../../modules/services/ecs_task"

  ecs-task_name = "pvlive"
  ecs-task_type = "consumer"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs-task_size = {
    cpu    = 256
    memory = 512
  }

  aws-region                     = var.region
  aws-environment                = local.environment

  s3-buckets = []

  container-env_vars = [
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
    { "name" : "ENVIRONMENT", "value" : local.environment },
    { "name" : "LOGLEVEL", "value" : "DEBUG"},
    { "name" :"REGIME", "value" : "in-day"},
    { "name" :"N_GSPS", "value" : "317"}
  ]
  container-secret_vars = [
  {secret_policy_arn: module.database.forecast-database-secret.arn,
  values: ["DB_URL"]}
  ]
  container-tag         = var.gsp_version
  container-name        = "openclimatefix/pvliveconsumer"
  container-registry = "docker.io"
  container-command     = []
}

# 3.8
module "gsp-consumer-day-after-gsp" {
  source = "../../modules/services/ecs_task"

  ecs-task_name = "pvlive-gsp-day-after"
  ecs-task_type = "consumer"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs-task_size = {
    cpu    = 256
    memory = 512
  }

  aws-region                     = var.region
  aws-environment                = local.environment

  s3-buckets = []

  container-env_vars = [
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
    { "name" : "ENVIRONMENT", "value" : local.environment },
    { "name" : "LOGLEVEL", "value" : "DEBUG"},
    { "name" :"REGIME", "value" : "day-after"},
    { "name" :"N_GSPS", "value" : "317"}
  ]
  container-secret_vars = [
  {secret_policy_arn: module.database.forecast-database-secret.arn,
  values: ["DB_URL"]}
  ]
  container-tag         = var.gsp_version
  container-name        = "openclimatefix/pvliveconsumer"
  container-registry = "docker.io"
  container-command     = []
}

# 3.9
module "gsp-consumer-day-after-national" {
  source = "../../modules/services/ecs_task"

  ecs-task_name = "pvlive-national-day-after"
  ecs-task_type = "consumer"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs-task_size = {
    cpu    = 256
    memory = 512
  }

  aws-region                     = var.region
  aws-environment                = local.environment

  s3-buckets = []

  container-env_vars = [
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
    { "name" : "ENVIRONMENT", "value" : local.environment },
    { "name" :"REGIME", "value" : "day-after"},
    { "name" :"N_GSPS", "value" : "0"},
    { "name" :"INCLUDE_NATIONAL", "value" : "True"},
  ]
  container-secret_vars = [
  {secret_policy_arn: module.database.forecast-database-secret.arn,
  values: ["DB_URL"]}
  ]
  container-tag         = var.gsp_version
  container-name        = "openclimatefix/pvliveconsumer"
  container-registry = "docker.io"
  container-command     = []
}

# 4.1
module "metrics" {
  source = "../../modules/services/ecs_task"

  aws-environment = local.environment
  aws-region = var.region

  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs-task_name = "metrics"
  ecs-task_type = "analysis"
  ecs-task_size = {
    cpu = 256
    memory = 512
  }

  container-name = "openclimatefix/nowcasting_metrics"
  container-tag = var.metrics_version
  container-registry = "docker.io"
  container-command = []
  container-env_vars = [
    {"name": "LOGLEVEL", "value": "DEBUG"},
    {"name": "USE_PVNET_GSP_SUM", "value": "true"},
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
    { "name" : "ENVIRONMENT", "value": local.environment},
  ]
  container-secret_vars = [
  {secret_policy_arn: module.database.forecast-database-secret.arn,
  values: ["DB_URL"]}
  ]
  s3-buckets = []
}

# 4.2 - We have removed PVnet 1

# 4.3
module "national_forecast" {
source = "../../modules/services/ecs_task"

  aws-region                    = var.region
  aws-environment               = local.environment

  s3-buckets = [
    {
      id : module.s3.s3-nwp-bucket.id,
      access_policy_arn : module.s3.iam-policy-s3-nwp-read.arn
    },
    {
      id : module.forecasting_models_bucket.bucket_id,
      access_policy_arn : module.forecasting_models_bucket.read_policy_arn
    }
  ]

  ecs-task_name               = "forecast_national"
  ecs-task_type               = "forecast"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs-task_size = {
    memory = 11264
    cpu    = 2048
  }

  container-env_vars = [
    { "name" : "AWS_REGION", "value" : var.region },
    { "name" : "ENVIRONMENT", "value" : local.environment },
    { "name" : "LOGLEVEL", "value" : "INFO" },
    { "name" : "NWP_ZARR_PATH", "value":"s3://${module.s3.s3-nwp-bucket.id}/data-metoffice/latest.zarr"},
    { "name" : "SENTRY_DSN",  "value": var.sentry_dsn},
    { "name": "ML_MODEL_BUCKET", "value": module.forecasting_models_bucket.bucket_id}
  ]

  container-secret_vars = [
       {secret_policy_arn: module.database.forecast-database-secret.arn,
        values: ["DB_URL"]
       }
       ]

  container-tag         = var.national_forecast_version
  container-name        = "openclimatefix/gradboost_pv"
  container-registry    = "docker.io"
  container-command     = []
}

# 4.4
module "forecast_pvnet" {
source = "../../modules/services/ecs_task"

  aws-region                    = var.region
  aws-environment               = local.environment

  s3-buckets = [
    {
      id : module.s3.s3-nwp-bucket.id,
      access_policy_arn : module.s3.iam-policy-s3-nwp-read.arn
    },
    {
      id : module.s3.s3-sat-bucket.id,
      access_policy_arn : module.s3.iam-policy-s3-sat-read.arn
    }
  ]

  ecs-task_name               = "forecast_pvnet"
  ecs-task_type               = "forecast"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs-task_size = {
    memory = 8192
    cpu    = 2048
  }

  container-env_vars = [
    { "name" : "AWS_REGION", "value" : var.region },
    { "name" : "ENVIRONMENT", "value" : local.environment },
    { "name" : "LOGLEVEL", "value" : "INFO" },
    { "name" : "NWP_ECMWF_ZARR_PATH", "value": "s3://${module.s3.s3-nwp-bucket.id}/ecmwf/data/latest.zarr" },
    { "name" : "NWP_UKV_ZARR_PATH", "value":"s3://${module.s3.s3-nwp-bucket.id}/data-metoffice/latest.zarr"},
    { "name" : "SATELLITE_ZARR_PATH", "value":"s3://${module.s3.s3-sat-bucket.id}/data/latest/latest.zarr.zip"},
    { "name" : "SENTRY_DSN",  "value": var.sentry_dsn},
    { "name" : "USE_ADJUSTER", "value": "true"},
    { "name" : "SAVE_GSP_SUM", "value": "true"},
    { "name" : "RUN_EXTRA_MODELS",  "value": "true"},
    { "name" : "DAY_AHEAD_MODEL",  "value": "false"},
    { "name" : "USE_OCF_DATA_SAMPLER", "value": "true"}
  ]

  container-secret_vars = [
       {secret_policy_arn: module.database.forecast-database-secret.arn,
        values: ["DB_URL"]
       }
       ]

  container-tag         = var.forecast_pvnet_version
  container-name        = "openclimatefix/pvnet_app"
  container-registry    = "docker.io"
  container-command     = []
}

# 4.5
module "forecast_pvnet_ecwmf" {
source = "../../modules/services/ecs_task"

  aws-region                    = var.region
  aws-environment               = local.environment

  s3-buckets = [
    {
      id : module.s3.s3-nwp-bucket.id,
      access_policy_arn : module.s3.iam-policy-s3-nwp-read.arn
    }
  ]

  ecs-task_name               = "forecast_pvnet_ecmwf"
  ecs-task_type               = "forecast"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs-task_size = {
    memory = 8192
    cpu    = 2048
  }

  container-env_vars = [
    { "name" : "AWS_REGION", "value" : var.region },
    { "name" : "ENVIRONMENT", "value" : local.environment },
    { "name" : "LOGLEVEL", "value" : "INFO" },
    { "name" : "NWP_ECMWF_ZARR_PATH", "value": "s3://${module.s3.s3-nwp-bucket.id}/ecmwf/data/latest.zarr" },
    { "name" : "SENTRY_DSN",  "value": var.sentry_dsn},
    {"name": "USE_ADJUSTER", "value": "false"},
    {"name": "SAVE_GSP_SUM", "value": "true"},
    {"name": "RUN_EXTRA_MODELS",  "value": "false"},
    {"name": "DAY_AHEAD_MODEL",  "value": "false"},
    {"name": "USE_ECMWF_ONLY",  "value": "true"}, # THIS IS THE IMPORTANT one
    {"name": "USE_OCF_DATA_SAMPLER", "value": "true"}
  ]

  container-secret_vars = [
       {secret_policy_arn: module.database.forecast-database-secret.arn,
        values: ["DB_URL"]
       }
       ]

  container-tag         = var.forecast_pvnet_version
  container-name        = "openclimatefix/pvnet_app"
  container-registry    = "docker.io"
  container-command     = []
}


# 4.6
module "forecast_pvnet_day_ahead" {
source = "../../modules/services/ecs_task"

  aws-region                    = var.region
  aws-environment               = local.environment

  s3-buckets = [
    {
      id : module.s3.s3-nwp-bucket.id,
      access_policy_arn : module.s3.iam-policy-s3-nwp-read.arn
    },
    {
      id : module.s3.s3-sat-bucket.id,
      access_policy_arn : module.s3.iam-policy-s3-sat-read.arn
    }

  ]

  ecs-task_name               = "forecast_pvnet_day_ahead"
  ecs-task_type               = "forecast"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs-task_size = {
    memory = 8192
    cpu    = 2048
  }

  container-env_vars = [
    { "name" : "AWS_REGION", "value" : var.region },
    { "name" : "ENVIRONMENT", "value" : local.environment },
    { "name" : "LOGLEVEL", "value" : "INFO" },
    { "name" : "NWP_ECMWF_ZARR_PATH", "value": "s3://${module.s3.s3-nwp-bucket.id}/ecmwf/data/latest.zarr" },
    { "name" : "NWP_UKV_ZARR_PATH", "value":"s3://${module.s3.s3-nwp-bucket.id}/data-metoffice/latest.zarr"},
    { "name" : "SATELLITE_ZARR_PATH", "value":"s3://${module.s3.s3-sat-bucket.id}/data/latest/latest.zarr.zip"},
    { "name" : "SENTRY_DSN",  "value": var.sentry_dsn},
    {"name": "USE_ADJUSTER", "value": "true"},
    {"name": "RUN_EXTRA_MODELS",  "value": "false"},
    {"name": "DAY_AHEAD_MODEL",  "value": "true"},
    {"name": "USE_OCF_DATA_SAMPLER", "value": "false"}
  ]

  container-secret_vars = [
       {secret_policy_arn: module.database.forecast-database-secret.arn,
        values: ["DB_URL"]
       }
       ]

  container-tag         = var.forecast_pvnet_day_ahead_docker_version
  container-name        = "openclimatefix/pvnet_app"
  container-registry    = "docker.io"
  container-command     = []
}

# 5.1
module "analysis_dashboard" {
  source             = "../../modules/services/eb_app"
  domain             = local.domain
  aws-region         = var.region
  aws-environment    = local.environment
  aws-subnet_id      = module.networking.public_subnet_ids[0]
  aws-vpc_id         = module.networking.vpc_id
  container-command  = ["streamlit", "run", "main.py", "--server.port=8501", "--browser.serverAddress=0.0.0.0", "--server.address=0.0.0.0", "–server.enableCORS False"]
  container-env_vars = [
    { "name" : "DB_URL", "value" :  module.database.forecast-database-secret-url},
    { "name" : "SITES_DB_URL", "value" :  module.pvsite_database.default_db_connection_url},
    { "name" : "SHOW_PVNET_GSP_SUM", "value" : "true" },
    { "name" : "ORIGINS", "value" : "*" },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
    { "name" : "AUTH0_DOMAIN", "value" : var.auth_domain },
    { "name" : "AUTH0_CLIENT_ID", "value" : var.auth_dashboard_client_id },
    { "name" : "REGION", "value": local.domain},
    { "name" : "ENVIRONMENT", "value": local.environment},
  ]
  container-name = "analysis-dashboard"
  container-tag  = var.internal_ui_version
  container-registry = "ghcr.io/openclimatefix"
  container-port = 8501
  eb-app_name    = "internal-ui"
  eb-instance_type = "t3.small"
  s3_bucket = [
    { bucket_read_policy_arn = module.s3.iam-policy-s3-nwp-read.arn },
    { bucket_read_policy_arn = module.s3.iam-policy-s3-sat-read.arn }
  ]
}

# 4.7
module "forecast_blend" {
  source = "../../modules/services/ecs_task"

  ecs-task_name = "forecast_blend"
  ecs-task_type = "blend"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs-task_size = {
    cpu    = 512
    memory = 1024
  }

  aws-region                     = var.region
  aws-environment                = local.environment

  container-env_vars = [
        {"name": "LOGLEVEL", "value" : "INFO"},
        {"name": "OCF_ENVIRONMENT", "value": local.environment},
    { "name" : "ENVIRONMENT", "value" : local.environment },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
  ]
  container-secret_vars = [
  {secret_policy_arn: module.database.forecast-database-secret.arn,
  values: ["DB_URL"]}
  ]
  container-tag         = var.forecast_blend_version
  container-name        = "openclimatefix/uk_pv_forecast_blend"
  container-registry = "docker.io"
  s3-buckets = []
  container-command = []
}


# 5.2
module "airflow" {
  source = "../../modules/services/airflow"

  aws-environment   = local.environment
  aws-domain        = local.domain
  aws-vpc_id        = module.networking.vpc_id
  aws-subnet_id       = module.networking.public_subnet_ids[0]
  airflow-db-connection-url        = module.database.forecast-database-secret-airflow-url
  docker-compose-version       = "0.0.6"
  ecs-subnet_id = module.networking.public_subnet_ids[0]
  ecs-security_group=module.networking.default_security_group_id
  aws-owner_id = module.networking.owner_id
  slack_api_conn=var.airflow_conn_slack_api_default
}

# 6.1
module "pvsite_database" {
  source = "../../modules/storage/postgres"

  region                      = var.region
  environment                 = local.environment
  db_subnet_group_name        = module.networking.private_subnet_group_name
  vpc_id                      = module.networking.vpc_id
  db_name                     = "pvsite"
  rds_instance_class          = "db.t3.small"
  allow_major_version_upgrade = true
}

# 6.2
module "pvsite_api" {
  source             = "../../modules/services/eb_app"
  domain             = local.domain
  aws-region         = var.region
  aws-environment    = local.environment
  aws-subnet_id      = module.networking.public_subnet_ids[0]
  aws-vpc_id         = module.networking.vpc_id
  container-command  = ["poetry", "run", "uvicorn", "pv_site_api.main:app", "--host", "0.0.0.0", "--port", "80"]
  container-env_vars = [
    { "name" : "PORT", "value" : "80" },
    { "name" : "DB_URL", "value" : module.pvsite_database.default_db_connection_url},
    { "name" : "FAKE", "value" : "0" },
    { "name" : "ORIGINS", "value" : "*" },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn_api },
    { "name" : "AUTH0_API_AUDIENCE", "value" : var.auth_api_audience },
    { "name" : "AUTH0_DOMAIN", "value" : var.auth_domain },
    { "name" : "AUTH0_ALGORITHM", "value" : "RS256" },
    { "name" : "ENVIRONMENT", "value" : "development" },
  ]
  container-name = "nowcasting_site_api"
  container-tag  = var.pvsite_api_version
  container-registry = "openclimatefix"
  eb-app_name    = "sites-api"
  eb-instance_type = "t3.small"
  s3_bucket = [
    { bucket_read_policy_arn = module.s3.iam-policy-s3-nwp-read.arn }
  ]
}


# 6.3
module "pvsite_ml_bucket" {
  source = "../../modules/storage/s3-private"

  region              = var.region
  environment         = local.environment
  service_name        = "site-forecaster-models"
  domain              = local.domain
  lifecycled_prefixes = []
}

# 6.4
module "pvsite_forecast" {
source = "../../modules/services/ecs_task"

  aws-region                    = var.region
  aws-environment               = local.environment

  s3-buckets = [
    {
      id : module.s3.s3-nwp-bucket.id,
      access_policy_arn : module.s3.iam-policy-s3-nwp-read.arn
    },
    {
      id : module.pvsite_ml_bucket.bucket_id,
      access_policy_arn : module.pvsite_ml_bucket.read_policy_arn
    }
  ]

  ecs-task_name               = "pvsite_forecast"
  ecs-task_type               = "forecast"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs-task_size = {
    memory = 4096
    cpu    = 1024
  }

  container-env_vars = [
    { "name" : "AWS_REGION", "value" : var.region },
    { "name" : "OCF_ENVIRONMENT", "value" : local.environment },
    { "name" : "LOGLEVEL", "value" : "DEBUG" },
    { "name" : "NWP_ZARR_PATH", "value": "s3://${module.s3.s3-nwp-bucket.id}/data-metoffice/latest.zarr" },
    { "name" : "SENTRY_DSN",  "value": var.sentry_dsn},
  ]

  container-secret_vars = [
       {secret_policy_arn: module.pvsite_database.secret.arn,
        values: ["OCF_PV_DB_URL"]
       }
       ]

  container-tag         = var.pvsite_forecast_version
  container-name        = "openclimatefix/pvsite_forecast"
  container-registry    = "docker.io"
  container-command     = []
}


# 6.5
module "pvsite_database_clean_up" {
  source = "../../modules/services/ecs_task"

  ecs-task_name = "database_clean_up"
  ecs-task_type = "clean"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs-task_size = {
    cpu    = 256
    memory = 512
  }

  aws-region                     = var.region
  aws-environment                = local.environment

  container-env_vars = [
        {"name": "LOGLEVEL", "value" : "INFO"},
        {"name": "OCF_ENVIRONMENT", "value": local.environment},
    { "name" : "ENVIRONMENT", "value" : local.environment },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
    { "name" : "SAVE_DIR", "value" :  "s3://${module.pvsite_ml_bucket.bucket_id}/database" },
  ]
  container-secret_vars = [
  {secret_policy_arn: module.pvsite_database.secret.arn,
  values: ["DB_URL"]},
  ]
  container-tag         = var.database_cleanup_version
  container-name        = "openclimatefix/pvsite_database_cleanup"
  container-registry = "docker.io"
  s3-buckets = [
                { id : module.pvsite_ml_bucket.bucket_id,
                  access_policy_arn = module.pvsite_ml_bucket.write_policy_arn
                 }
                    ]
  container-command = []
}


# 7.1 Open Data PVnet - Public s3 bucket
module "open_data_pvnet_s3" {
  source = "../../modules/storage/open-data-pvnet-s3"
}
