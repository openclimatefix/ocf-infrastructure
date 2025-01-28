# Defines the production India platform
# Creates the following in AWS:
# 1.0 - VPC and Subnets
# 1.1 - RDS Postgres database
# 1.2 - Bastion instance
# 1.3 - ECS Cluster
# 2.0 - S3 bucket for NWP data
# 2.1 - S3 bucket for Satellite data
# 2.2 - S3 bucket for Forecast data
# 3.0 - Secret containing environment variables for the NWP consumer
# 3.1 - Secret containing environment variables for the Satellite consumer
# 3.2 - Secret containing HF read access
# 4.0 - ECS task definition for the NWP consumer
# 4.1 - ECS task definition for the GFS consumer
# 4.2 - ECS task definition for the MetOffice consumer
# 4.3 - ECS task definition for Collection RUVNL data
# 4.4 - Satellite Consumer
# 4.5 - ECS task definition for the Forecast - Client RU
# 4.6 - ECS task definition for the Forecast - Client AD
# 5.0 - Airflow EB Instance
# 5.1 - India API EB Instance
# 5.2 - India Analysis Dashboard

locals {
  environment = "production"
  domain      = "india"
  region      = "ap-south-1"
}

# 1.0
module "network" {
  source             = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/networking?ref=205465e"
  environment        = local.environment
  vpc_cidr           = "10.1.0.0/16"
  region             = local.region
  availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  domain             = local.domain
}

# 1.1
module "postgres-rds" {
  source               = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/storage/postgres?ref=6e24edf"
  region               = local.region
  environment          = local.environment
  vpc_id               = module.network.vpc_id
  db_subnet_group_name = module.network.private_subnet_group_name
  db_name              = "indiadb"
  rds_instance_class   = "db.t3.small"
  allow_major_version_upgrade  = true
  engine_version = "16.3"
}

# 1.2
module "ec2-bastion" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/networking/ec2_bastion?ref=205465e"

  region            = local.region
  vpc_id            = module.network.vpc_id
  public_subnets_id = module.network.public_subnet_ids[0]
}

# 1.3
module "ecs-cluster" {
  source   = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/ecs_cluster?ref=205465e"
  name     = "india-ecs-cluster-${local.environment}"
  region   = local.region
  owner_id = module.network.owner_id
}

# 2.0
module "s3-nwp-bucket" {
  source              = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/storage/s3-private?ref=205465e"
  environment         = local.environment
  region              = var.region
  domain              = local.domain
  service_name        = "nwp"
  lifecycled_prefixes = ["ecmwf/data", "ecmwf/raw", "gfs/data", "gfs/raw"]
}

# 2.1
module "s3-satellite-bucket" {
  source              = "../../modules/storage/s3-private"
  environment         = local.environment
  region              = var.region
  domain              = local.domain
  service_name        = "satellite"
  lifecycled_prefixes = ["data"]
}

# 2.2
module "s3-forecast-bucket" {
  source              = "../../modules/storage/s3-private"
  environment         = local.environment
  region              = var.region
  domain              = local.domain
  service_name        = "forecast"
  lifecycled_prefixes = [""]
}

# 3.0
resource "aws_secretsmanager_secret" "nwp_consumer_secret" {
  name = "${local.environment}/data/nwp-consumer"
}

# 3.1
resource "aws_secretsmanager_secret" "satellite_consumer_secret" {
  name = "${local.environment}/data/satellite-consumer"
}

import {
  to = aws_secretsmanager_secret.satellite_consumer_secret
  id = "arn:aws:secretsmanager:ap-south-1:752135663966:secret:production/data/satellite-consumer-SOZCn1"
}

# 3.2
resource "aws_secretsmanager_secret" "huggingface_consumer_secret" {
  name = "${local.environment}/huggingface/token"
}

# TODO temporary import statement remove this
import {
  to = aws_secretsmanager_secret.huggingface_consumer_secret
  id = "arn:aws:secretsmanager:ap-south-1:752135663966:secret:prod/huggingface/token-9lPQsb"
}

# 4.0
module "nwp_consumer_ecmwf_live_ecs_task" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/ecs_task?ref=205465e"

  ecs-task_name               = "nwp-consumer-ecmwf-india"
  ecs-task_type               = "consumer"
  ecs-task_execution_role_arn = module.ecs-cluster.ecs_task_execution_role_arn
  ecs-task_size = {
      cpu    = 2048
      memory = 10240
  }


  aws-region                    = var.region
  aws-environment               = local.environment
  aws-secretsmanager_secret_arn = aws_secretsmanager_secret.nwp_consumer_secret.arn

  s3-buckets = [{ 
    id: module.s3-nwp-bucket.bucket_id,
    access_policy_arn: module.s3-nwp-bucket.write_policy_arn
}]

  container-env_vars = [
    { "name" : "AWS_REGION", "value" : var.region },
    { "name" : "AWS_S3_BUCKET", "value" : module.s3-nwp-bucket.bucket_id },
    { "name" : "ECMWF_AWS_REGION", "value": "eu-west-1" },
    { "name" : "ECMWF_AWS_S3_BUCKET", "value" : "ocf-ecmwf-production" },
    { "name" : "LOGLEVEL", "value" : "DEBUG" },
    { "name" : "ECMWF_AREA", "value" : "india" },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
    { "name" : "ENVIRONMENT", "value" : local.environment },
  ]
  container-secret_vars = ["ECMWF_AWS_ACCESS_KEY", "ECMWF_AWS_ACCESS_SECRET"]
  container-tag         = var.version-nwp
  container-name        = "openclimatefix/nwp-consumer"
  container-command     = [
    "download",
    "--source=ecmwf-s3",
    "--sink=s3",
    "--rdir=ecmwf/raw",
    "--zdir=ecmwf/data",
    "--create-latest"
  ]
}

# 4.1
module "nwp_consumer_gfs_live_ecs_task" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/ecs_task?ref=205465e"

  ecs-task_name               = "nwp-consumer-gfs-india"
  ecs-task_type               = "consumer"
  ecs-task_size = {
    cpu    = 1024
    memory = 5120
    storage = 60
  }
  ecs-task_execution_role_arn = module.ecs-cluster.ecs_task_execution_role_arn

  aws-region                    = var.region
  aws-environment               = local.environment
  aws-secretsmanager_secret_arn = aws_secretsmanager_secret.nwp_consumer_secret.arn

  s3-buckets = [
    {
      id : module.s3-nwp-bucket.bucket_id,
      access_policy_arn : module.s3-nwp-bucket.write_policy_arn
    }
  ]

  container-env_vars = [
    { "name" : "AWS_REGION", "value" : var.region },
    { "name" : "AWS_S3_BUCKET", "value" : module.s3-nwp-bucket.bucket_id },
    { "name" : "LOGLEVEL", "value" : "DEBUG" },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
    { "name" : "ENVIRONMENT", "value" : local.environment },
  ]
  container-secret_vars = []
  container-tag         = var.version-nwp
  container-name        = "openclimatefix/nwp-consumer"
  container-command     = [
    "download",
    "--source=gfs",
    "--sink=s3",
    "--rdir=gfs/raw",
    "--zdir=gfs/data",
    "--create-latest",
    "--no-rename-vars"
  ]
}

# 4.2
module "nwp-consumer-metoffice-live-ecs-task" {
    source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/ecs_task?ref=f0ecf51"

  ecs-task_name = "nwp-consumer-metoffice-india"
  ecs-task_type = "consumer"
  ecs-task_execution_role_arn = module.ecs-cluster.ecs_task_execution_role_arn
  ecs-task_size = {
    cpu    = 512
    memory = 1024
  }

  aws-region = var.region
  aws-environment = local.environment

  s3-buckets = [
    {
      id : module.s3-nwp-bucket.bucket_id
      access_policy_arn : module.s3-nwp-bucket.write_policy_arn
    }
  ]

  container-env_vars = [
    { "name" : "LOGLEVEL", "value" : "INFO" },
    { "name" : "METOFFICE_ORDER_ID", "value" : "india-11params-54steps" },
    { "name" : "MODEL_REPOSITORY", "value" : "metoffice-datahub" },
    { "name" : "CONCURRENCY", "value" : "false" },
    { "name" : "ZARRDIR", "value" : format("s3://%s/metoffice/data", module.s3-nwp-bucket.bucket_id) },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
  ]
  container-secret_vars = [
    {
      secret_policy_arn: aws_secretsmanager_secret.nwp_consumer_secret.arn,
      values: ["METOFFICE_API_KEY"],
    }
  ]
  container-tag         = "devsjc-major-refactor"
  container-name        = "openclimatefix/nwp-consumer"
  container-command     = ["consume"]
}


# 4.3
module "ruvnl_consumer_ecs" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/ecs_task?ref=205465e"

  ecs-task_name               = "runvl-consumer"
  ecs-task_type               = "consumer"
  ecs-task_execution_role_arn = module.ecs-cluster.ecs_task_execution_role_arn

  aws-region                    = var.region
  aws-environment               = local.environment
  aws-secretsmanager_secret_arn = module.postgres-rds.secret.arn

  s3-buckets = []

  ecs-task_size = {
    memory = 512
    cpu    = 256
  }

  container-env_vars = [
    { "name" : "AWS_REGION", "value" : var.region },
    { "name" : "LOGLEVEL", "value" : "DEBUG" },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
    { "name" : "ENVIRONMENT", "value" : local.environment },
  ]
  container-secret_vars = ["DB_URL"]
  container-tag         = var.version-runvl-consumer
  container-name        = "ruvnl_consumer_app"
  container-registry    = "openclimatefix"
  container-command     = [
    "--write-to-db",
  ]
}


# 4.4 - Satellite Consumer
module "satellite_consumer_ecs" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/ecs_task?ref=205465e"

  aws-region                    = var.region
  aws-environment               = local.environment
  aws-secretsmanager_secret_arn = aws_secretsmanager_secret.satellite_consumer_secret.arn

  s3-buckets = [
    {
      id : module.s3-satellite-bucket.bucket_id,
      access_policy_arn : module.s3-satellite-bucket.write_policy_arn
    }
  ]

  ecs-task_name               = "sat-consumer"
  ecs-task_type               = "consumer"
  ecs-task_execution_role_arn = module.ecs-cluster.ecs_task_execution_role_arn
  ecs-task_size = {
    memory = 5120
    cpu    = 1024
    storage = 21
  }

  container-env_vars = [
    { "name" : "AWS_REGION", "value" : var.region },
    { "name" : "LOGLEVEL", "value" : "DEBUG" },
    { "name" : "USE_IODC", "value" : "True" },
    { "name" : "SAVE_DIR", "value" : "s3://${module.s3-satellite-bucket.bucket_id}/data" },
    { "name" : "SAVE_DIR_NATIVE", "value" : "s3://${module.s3-satellite-bucket.bucket_id}/raw" },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
    { "name" : "ENVIRONMENT", "value" : local.environment },
  ]
  container-secret_vars = ["API_KEY", "API_SECRET"]
  container-tag         = var.satellite-consumer
  container-name        = "satip"
  container-registry    = "openclimatefix"
  container-command     = []
}


# 4.5 - Forecast - Client RUVNL
module "forecast" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/ecs_task?ref=73255a4"

  aws-region                    = var.region
  aws-environment               = local.environment

  s3-buckets = [
    {
      id : module.s3-nwp-bucket.bucket_id,
      access_policy_arn : module.s3-nwp-bucket.read_policy_arn
    },
    {
      id : module.s3-forecast-bucket.bucket_id,
      access_policy_arn : module.s3-forecast-bucket.write_policy_arn
    }
  ]

  ecs-task_name               = "forecast"
  ecs-task_type               = "forecast"
  ecs-task_execution_role_arn = module.ecs-cluster.ecs_task_execution_role_arn
  ecs-task_size = {
    memory = 3072
    cpu    = 1024
  }

  container-env_vars = [
    { "name" : "AWS_REGION", "value" : var.region },
    { "name" : "ENVIRONMENT", "value" : local.environment },
    { "name" : "LOGLEVEL", "value" : "INFO" },
    { "name" : "NWP_ECMWF_ZARR_PATH", "value": "s3://${module.s3-nwp-bucket.bucket_id}/ecmwf/data/latest.zarr" },
    { "name" : "NWP_GFS_ZARR_PATH", "value": "s3://${module.s3-nwp-bucket.bucket_id}/gfs/data/latest.zarr" },
    { "name" : "NWP_MO_GLOBAL_ZARR_PATH", "value": "s3://${module.s3-nwp-bucket.bucket_id}/metoffice/data/latest.zarr" },
    { "name" : "SENTRY_DSN",  "value": var.sentry_dsn},
    { "name" : "USE_SATELLITE", "value": "False"},
    { "name" : "SAVE_BATCHES_DIR", "value": "s3://${module.s3-forecast-bucket.bucket_id}/RUVNL"}
      ]

  container-secret_vars = [
       {secret_policy_arn: module.postgres-rds.secret.arn,
        values: ["DB_URL"]
       }
       ]

  container-tag         = var.version-forecast
  container-name        = "india_forecast_app"
  container-registry    = "openclimatefix"
  container-command     = []
}

# 4.6 - Forecast - Client AD
module "forecast-ad" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/ecs_task?ref=73255a4"

  aws-region                    = var.region
  aws-environment               = local.environment

  s3-buckets = [
    {
      id : module.s3-satellite-bucket.bucket_id,
      access_policy_arn : module.s3-satellite-bucket.write_policy_arn
    },
    {
      id : module.s3-nwp-bucket.bucket_id,
      access_policy_arn : module.s3-nwp-bucket.write_policy_arn
    },
    {
      id : module.s3-forecast-bucket.bucket_id,
      access_policy_arn : module.s3-forecast-bucket.write_policy_arn
    }
  ]

  ecs-task_name               = "forecast-ad"
  ecs-task_type               = "forecast"
  ecs-task_execution_role_arn = module.ecs-cluster.ecs_task_execution_role_arn
  ecs-task_size = {
    memory = 3072
    cpu    = 1024
    storage = 21
  }

  container-env_vars = [
    { "name" : "AWS_REGION", "value" : var.region },
    { "name" : "ENVIRONMENT", "value" : local.environment },
    { "name" : "LOGLEVEL", "value" : "DEBUG" },
    { "name" : "NWP_ECMWF_ZARR_PATH", "value": "s3://${module.s3-nwp-bucket.bucket_id}/ecmwf/data/latest.zarr" },
    { "name" : "NWP_GFS_ZARR_PATH", "value": "s3://${module.s3-nwp-bucket.bucket_id}/gfs/data/latest.zarr" },
    { "name" : "SATELLITE_ZARR_PATH", "value": "s3://${module.s3-satellite-bucket.bucket_id}/data/latest/iodc_latest.zarr.zip" },
    { "name" : "SENTRY_DSN",  "value": var.sentry_dsn},
    { "name" : "USE_SATELLITE", "value": "True"},
    { "name" : "CLIENT_NAME", "value": "ad"},
    { "name" : "SAVE_BATCHES_DIR", "value": "s3://${module.s3-forecast-bucket.bucket_id}/ad"},
      ]

  container-secret_vars = [
  {secret_policy_arn: aws_secretsmanager_secret.huggingface_consumer_secret.arn,
        values: ["HUGGINGFACE_TOKEN"]
       },
       {secret_policy_arn: module.postgres-rds.secret.arn,
        values: ["DB_URL"]
       }
       ]

  container-tag         = var.version-forecast-ad
  container-name        = "india_forecast_app"
  container-registry    = "openclimatefix"
  container-command     = []
}

# 5.0
module "airflow" {
  source                    = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/airflow?ref=7e27e14"
  aws-environment           = local.environment
  aws-region                = local.region
  aws-domain                = local.domain
  aws-vpc_id                = module.network.vpc_id
  aws-subnet_id             = module.network.public_subnet_ids[0]
  airflow-db-connection-url = "${module.postgres-rds.instance_connection_url}/airflow"
  docker-compose-version    = "0.0.11"
  ecs-subnet_id             = module.network.public_subnet_ids[0]
  ecs-security_group        = module.network.default_security_group_id
  aws-owner_id              = module.network.owner_id
  slack_api_conn            = var.apikey-slack
  dags_folder               = "india"
}

# 5.1
module "india-api" {
  source             = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/eb_app?ref=6e24edf"
  domain             = local.domain
  aws-region         = local.region
  aws-environment    = local.environment
  aws-subnet_id      = module.network.public_subnet_ids[0]
  aws-vpc_id         = module.network.vpc_id
  container-command  = []
  container-env_vars = [
    { "name" : "SOURCE", "value" : "indiadb" },
    { "name" : "PORT", "value" : "80" },
    { "name" : "DB_URL", "value" : module.postgres-rds.default_db_connection_url},
    { "name" : "AUTH0_DOMAIN", "value" : var.auth_domain },
    { "name" : "AUTH0_API_AUDIENCE", "value" : var.auth_api_audience },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn_api },
    { "name" : "ENVIRONMENT", "value": local.environment},

  ]
  container-name = "india-api"
  container-tag  = var.version-india_api
  eb-app_name    = "india-api"
}

# 5.2
module "analysis_dashboard" {
  source             = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/eb_app?ref=5bc9429"
  domain             = local.domain
  aws-region         = var.region
  aws-environment    = local.environment
  aws-subnet_id      = module.network.public_subnet_ids[0]
  aws-vpc_id         = module.network.vpc_id
  container-command  = ["streamlit", "run", "main_india.py", "--server.port=8501", "--browser.serverAddress=0.0.0.0", "--server.address=0.0.0.0", "–server.enableCORS False"]
  container-env_vars = [
    { "name" : "DB_URL", "value" :  module.postgres-rds.default_db_connection_url},
    { "name" : "SITES_DB_URL", "value" :  module.postgres-rds.default_db_connection_url},
    { "name" : "ORIGINS", "value" : "*" },
    { "name" : "REGION", "value": local.domain},
    { "name" : "ENVIRONMENT", "value": local.environment},
    { "name" : "AUTH0_DOMAIN", "value" : var.auth_domain },
    { "name" : "AUTH0_CLIENT_ID", "value" : var.auth_dashboard_client_id },
  ]
  container-name = "analysis-dashboard"
  container-tag  = var.analysis_dashboard_version
  container-registry = "ghcr.io/openclimatefix"
  container-port = 8501
  eb-app_name    = "analysis-dashboard"
  eb-instance_type = "t3.small"
  s3_bucket = [
    { bucket_read_policy_arn = module.s3-nwp-bucket.read_policy_arn },
    { bucket_read_policy_arn = module.s3-satellite-bucket.read_policy_arn }
  ]
}
