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
3.- - NWP Consumer Secret
3.1 - NWP Consumer (MetOffice GSP)
3.2 - NWP Consumer (MetOffice National)
3.3 - NWP Consumer (ECMWF UK)
3.4 - Satellite Consumer
3.5 - PV Consumer
3.6 - GSP Consumer (from PVLive)
4.1 - Metrics
4.2 - Forecast PVnet 1
4.3 - Forecast National XG
4.4 - Forecast PVnet 2
4.5 - Forecast Blend
5.1 - OCF Dashboard
5.2 - Airflow instance
6.1 - PVSite database
6.2 - PVSite API
6.3 - PVSite ML bucket
6.4 - PVSite Forecast
6.5 - PVSite Database Clean Up

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
# TODO: Make sites api and nowcasting api use same module
module "api" {
  source = "../../modules/services/api"

  region                              = var.region
  environment                         = local.environment
  vpc_id                              = module.networking.vpc_id
  subnet_id                           = module.networking.public_subnet_ids[0]
  docker_version                      = var.api_version
  database_forecast_secret_url        = module.database.forecast-database-secret-url
  iam-policy-rds-forecast-read-secret = module.database.iam-policy-forecast-db-read
  auth_domain                         = var.auth_domain
  auth_api_audience                   = var.auth_api_audience
  n_history_days                      = "2"
  adjust_limit                        = 2000.0
  sentry_dsn                          = var.sentry_dsn
}

# 2.1
module "database" {
  source = "../../modules/storage/database-pair"

  region               = var.region
  environment          = local.environment
  db_subnet_group_name = module.networking.private_subnet_group_name
  vpc_id               = module.networking.vpc_id
}

# 3.0
resource "aws_secretsmanager_secret" "nwp_consumer_secret" {
  name = "${local.environment}/data/nwp-consumer"
}

import {
  to = aws_secretsmanager_secret.nwp_consumer_secret
  id = "arn:aws:secretsmanager:eu-west-1:008129123253:secret:development/data/nwp-consumer-UZrR8M"
}

# 3.1
module "nwp" {
  source = "../../modules/services/nwp_consumer"

  ecs-task_name = "nwp"
  ecs-task_type = "consumer"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn

  aws-region                     = var.region
  aws-environment                = local.environment
  aws-secretsmanager_secret_arn = aws_secretsmanager_secret.nwp_consumer_secret.arn

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
    { "name" : "METOFFICE_ORDER_ID", "value" : "uk-11params-12steps" },
  ]
  container-secret_vars = ["METOFFICE_CLIENT_ID", "METOFFICE_CLIENT_SECRET"]
  container-tag         = var.nwp_version
  container-name        = "openclimatefix/nwp-consumer"
  container-command     = [
    "download",
    "--source=metoffice",
    "--sink=s3",
    "--rdir=raw",
    "--zdir=data",
    "--create-latest"
  ]
}

# 3.2
module "nwp-national" {
  source = "../../modules/services/nwp_consumer"

  ecs-task_name = "nwp-national"
  ecs-task_type = "consumer"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn

  aws-region                     = var.region
  aws-environment                = local.environment
  aws-secretsmanager_secret_arn = aws_secretsmanager_secret.nwp_consumer_secret.arn

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
    { "name" : "METOFFICE_ORDER_ID", "value" : "uk-5params-42steps" },
  ]
  container-secret_vars = ["METOFFICE_CLIENT_ID", "METOFFICE_CLIENT_SECRET"]
  container-tag         = var.nwp_version
  container-name        = "openclimatefix/nwp-consumer"
  container-command     = [
    "download",
    "--source=metoffice",
    "--sink=s3",
    "--rdir=raw-national",
    "--zdir=data-national",
    "--create-latest"
  ]
}


# 3.3
module "nwp-ecmwf" {
  source = "../../modules/services/nwp_consumer"

  ecs-task_name = "nwp-ecmwf"
  ecs-task_type = "consumer"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn

  aws-region                     = var.region
  aws-environment                = local.environment
  aws-secretsmanager_secret_arn = aws_secretsmanager_secret.nwp_consumer_secret.arn

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
  ]
  container-secret_vars = ["ECMWF_API_KEY", "ECMWF_API_EMAIL", "ECMWF_API_URL"]
  container-tag         = var.nwp_version
  container-name        = "openclimatefix/nwp-consumer"
  container-command     = [
    "download",
    "--source=ecmwf-mars",
    "--sink=s3",
    "--rdir=ecmwf/raw",
    "--zdir=ecmwf/data",
    "--create-latest"
  ]
}

# 3.4 Sat Consumer
module "sat" {
  source = "../../modules/services/sat"

  region                  = var.region
  environment             = local.environment
  iam-policy-s3-sat-write = module.s3.iam-policy-s3-sat-write
  s3-bucket               = module.s3.s3-sat-bucket
  public_subnet_ids       = module.networking.public_subnet_ids
  docker_version          = var.sat_version
  database_secret         = module.database.forecast-database-secret
  iam-policy-rds-read-secret = module.database.iam-policy-forecast-db-read
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
}

# 3.5
module "pv" {
  source = "../../modules/services/pv"

  region                  = var.region
  environment             = local.environment
  public_subnet_ids       = module.networking.public_subnet_ids
  database_secret_forecast = module.database.forecast-database-secret
  docker_version          = var.pv_version
  docker_version_ss          = var.pv_ss_version
  iam-policy-rds-read-secret_forecast = module.database.iam-policy-forecast-db-read
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
}

# 3.6
module "gsp" {
  source = "../../modules/services/gsp"

  region                  = var.region
  environment             = local.environment
  public_subnet_ids       = module.networking.public_subnet_ids
  database_secret         = module.database.forecast-database-secret
  docker_version          = var.gsp_version
  iam-policy-rds-read-secret = module.database.iam-policy-forecast-db-read
  ecs_task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
}

# 4.1
module "metrics" {
  source = "../../modules/services/metrics"

  region                  = var.region
  environment             = local.environment
  public_subnet_ids       = module.networking.public_subnet_ids
  database_secret         = module.database.forecast-database-secret
  docker_version          = var.metrics_version
  iam-policy-rds-read-secret = module.database.iam-policy-forecast-db-read
  use_pvnet_gsp_sum = "true"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
}

# 4.2 - We have removed PVnet 1

# 4.3
module "national_forecast" {
  source = "../../modules/services/forecast_generic"

  region      = var.region
  environment = local.environment
  app-name    = "forecast_national"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs_config  = {
    docker_image   = "openclimatefix/gradboost_pv"
    docker_version = var.national_forecast_version
    memory_mb      = 11264
    cpu            = 2048
  }
  rds_config = {
    database_secret_arn             = module.database.forecast-database-secret.arn
    database_secret_read_policy_arn = module.database.iam-policy-forecast-db-read.arn
  }
  s3_ml_bucket = {
    bucket_id              = module.forecasting_models_bucket.bucket_id
    bucket_read_policy_arn = module.forecasting_models_bucket.read_policy_arn
  }
  s3_nwp_bucket = {
    bucket_id              = module.s3.s3-nwp-bucket.id
    bucket_read_policy_arn = module.s3.iam-policy-s3-nwp-read.arn
    datadir                = "data-national"
  }
}

# 4.4
module "forecast_pvnet" {
  source = "../../modules/services/forecast_generic"

  region      = var.region
  environment = local.environment
  app-name    = "forecast_pvnet"
  ecs_config  = {
    docker_image   = "openclimatefix/pvnet_app"
    docker_version = var.forecast_pvnet_version
    memory_mb      = 8192
    cpu            = 2048
  }
  rds_config = {
    database_secret_arn             = module.database.forecast-database-secret.arn
    database_secret_read_policy_arn = module.database.iam-policy-forecast-db-read.arn
  }
  s3_ml_bucket = {
    bucket_id              = module.forecasting_models_bucket.bucket_id
    bucket_read_policy_arn = module.forecasting_models_bucket.read_policy_arn
  }
  s3_nwp_bucket = {
    bucket_id              = module.s3.s3-nwp-bucket.id
    bucket_read_policy_arn = module.s3.iam-policy-s3-nwp-read.arn
    datadir                = "data-national"
  }
  s3_satellite_bucket = {
    bucket_id              = module.s3.s3-sat-bucket.id
    bucket_read_policy_arn = module.s3.iam-policy-s3-sat-read.arn
    datadir                = "data/latest"
  }
  loglevel      = "INFO"
  pvnet_gsp_sum = "true"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
}

# 5.1
module "analysis_dashboard" {
  source = "../../modules/services/internal_ui"

  region        = var.region
  environment   = local.environment
  eb_app_name   = "internal-ui"
  domain        = local.domain
  docker_config = {
    image   = "ghcr.io/openclimatefix/uk-analysis-dashboard"
    version = var.internal_ui_version
  }
  networking_config = {
    vpc_id  = module.networking.vpc_id
    subnets = module.networking.public_subnet_ids
  }
  database_config = {
    secret          = module.database.forecast-database-secret-url
    read_policy_arn = module.database.iam-policy-forecast-db-read.arn
  }
  auth_config = {
    auth0_domain    = var.auth_domain
    auth0_client_id = var.auth_dashboard_client_id
  }
  show_pvnet_gsp_sum = "true"
}

# 4.5
module "forecast_blend" {
  source = "../../modules/services/forecast_blend"

  region      = var.region
  environment = local.environment
  app-name    = "forecast_blend"
  ecs_config  = {
    docker_image   = "openclimatefix/uk_pv_forecast_blend"
    docker_version = var.forecast_blend_version
    memory_mb      = 1024
    cpu            = 512
  }
  rds_config = {
    database_secret_arn             = module.database.forecast-database-secret.arn
    database_secret_read_policy_arn = module.database.iam-policy-forecast-db-read.arn
  }
  loglevel = "INFO"
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
}

# 5.2
module "airflow" {
  source = "../../modules/services/airflow"

  aws-environment   = local.environment
  aws-vpc_id        = module.networking.vpc_id
  aws-subnet_id       = module.networking.public_subnet_ids[0]
  rds-db_secret_url        = module.database.forecast-database-secret-airflow-url
  docker-compose-version       = "0.0.4"
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
# TODO: Make sites api and nowcasting api use same module
module "pvsite_api" {
  source = "../../modules/services/api_pvsite"

  region                          = var.region
  app_name                        = "sites-api"
  environment                     = local.environment
  vpc_id                          = module.networking.vpc_id
  subnet_id                       = module.networking.public_subnet_ids[0]
  docker_version                  = var.pvsite_api_version
  domain                          = local.domain
  database_secret_url             = module.pvsite_database.secret-url
  database_secret_read_policy_arn = module.pvsite_database.secret-policy.arn
  sentry_dsn                      = var.sentry_dsn
  auth_api_audience               = var.auth_api_audience
  auth_domain                     = var.auth_domain
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
  source = "../../modules/services/forecast_generic"

  region      = var.region
  environment = local.environment
  app-name    = "pvsite_forecast"
  ecs_config  = {
    docker_image   = "openclimatefix/pvsite_forecast"
    docker_version = var.pvsite_forecast_version
    memory_mb      = 4096
    cpu            = 1024
  }
  rds_config = {
    database_secret_arn             = module.pvsite_database.secret.arn
    database_secret_read_policy_arn = module.pvsite_database.secret-policy.arn
  }
  s3_ml_bucket = {
    bucket_id              = module.pvsite_ml_bucket.bucket_id
    bucket_read_policy_arn = module.pvsite_ml_bucket.read_policy_arn
  }
  s3_nwp_bucket = {
    bucket_id              = module.s3.s3-nwp-bucket.id
    bucket_read_policy_arn = module.s3.iam-policy-s3-nwp-read.arn
    datadir                = "data"
  }
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
}

# 6.5
module "pvsite_database_clean_up" {
  source      = "../../modules/services/database_clean_up"
  region      = var.region
  environment = local.environment
  app-name    = "database_clean_up"
  ecs_config  = {
    docker_image   = "openclimatefix/pvsite_database_cleanup"
    docker_version = var.database_cleanup_version
    memory_mb      = 512
    cpu            = 256
  }
  rds_config = {
    database_secret_arn             = module.pvsite_database.secret.arn
    database_secret_read_policy_arn = module.pvsite_database.secret-policy.arn
  }
  ecs-task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
}
