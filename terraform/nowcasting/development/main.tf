/*====
Variables used across all modules
======*/
locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  domain = "nowcasting"
}


module "networking" {
  source = "../../modules/networking"

  region               = var.region
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = local.production_availability_zones
}

module "ec2-bastion" {
  source = "../../modules/networking/ec2_bastion"

  region               = var.region
  vpc_id               = module.networking.vpc_id
  public_subnets_id    = module.networking.public_subnets[0].id
}

module "s3" {
  source = "../../modules/storage/s3-trio"

  region      = var.region
  environment = var.environment
}

module "ecs" {
  source = "../../modules/ecs"

  region      = var.region
  environment = var.environment
  domain = local.domain
}

module "forecasting_models_bucket" {
  source = "../../modules/storage/s3-private"

  region              = var.region
  environment         = var.environment
  service_name        = "national-forecaster-models"
  domain              = local.domain
  lifecycled_prefixes = []
}

module "api" {
  source = "../../modules/services/api"

  region                              = var.region
  environment                         = var.environment
  vpc_id                              = module.networking.vpc_id
  subnets                             = module.networking.public_subnets
  docker_version                      = var.api_version
  database_forecast_secret_url        = module.database.forecast-database-secret-url
  database_pv_secret_url              = module.database.pv-database-secret-url
  iam-policy-rds-forecast-read-secret = module.database.iam-policy-forecast-db-read
  iam-policy-rds-pv-read-secret       = module.database.iam-policy-pv-db-read
  auth_domain = var.auth_domain
  auth_api_audience = var.auth_api_audience
  n_history_days = "2"
}

module "data_visualization" {
  source = "../../modules/services/data_visualization"

  region                              = var.region
  environment                         = var.environment
  vpc_id                              = module.networking.vpc_id
  subnets                             = module.networking.public_subnets
  docker_version                      = var.data_visualization_version
  database_forecast_secret_url        = module.database.forecast-database-secret-url
  database_pv_secret_url              = module.database.pv-database-secret-url
  iam-policy-rds-forecast-read-secret = module.database.iam-policy-forecast-db-read
  iam-policy-rds-pv-read-secret       = module.database.iam-policy-pv-db-read
  api_url                             = module.api.api_url
  iam-policy-s3-nwp-read              = module.s3.iam-policy-s3-nwp-read
  iam-policy-s3-sat-read              = module.s3.iam-policy-s3-sat-read
}

module "database" {
  source = "../../modules/storage/database-pair"

  region          = var.region
  environment     = var.environment
  db_subnet_group = module.networking.private_subnet_group
  vpc_id          = module.networking.vpc_id
}

module "nwp" {
  source = "../../modules/services/nwp"

  region                  = var.region
  environment             = var.environment
  iam-policy-s3-nwp-write = module.s3.iam-policy-s3-nwp-write
  s3-bucket               = module.s3.s3-nwp-bucket
  ecs-cluster             = module.ecs.ecs_cluster
  public_subnet_ids       = [module.networking.public_subnets[0].id]
  docker_version          = var.nwp_version
  database_secret         = module.database.forecast-database-secret
  iam-policy-rds-read-secret = module.database.iam-policy-forecast-db-read
  consumer-name = "nwp"
}

module "nwp-regional" {
  source = "../../modules/services/nwp"

  region                  = var.region
  environment             = var.environment
  iam-policy-s3-nwp-write = module.s3.iam-policy-s3-nwp-write
  s3-bucket               = module.s3.s3-nwp-bucket
  ecs-cluster             = module.ecs.ecs_cluster
  public_subnet_ids       = [module.networking.public_subnets[0].id]
  docker_version          = var.nwp_version
  database_secret         = module.database.forecast-database-secret
  iam-policy-rds-read-secret = module.database.iam-policy-forecast-db-read
  consumer-name = "nwp-regional"
}

module "sat" {
  source = "../../modules/services/sat"

  region                  = var.region
  environment             = var.environment
  iam-policy-s3-sat-write = module.s3.iam-policy-s3-sat-write
  s3-bucket               = module.s3.s3-sat-bucket
  ecs-cluster             = module.ecs.ecs_cluster
  public_subnet_ids       = [module.networking.public_subnets[0].id]
  docker_version          = var.sat_version
  database_secret         = module.database.forecast-database-secret
  iam-policy-rds-read-secret = module.database.iam-policy-forecast-db-read
}


module "pv" {
  source = "../../modules/services/pv"

  region                  = var.region
  environment             = var.environment
  ecs-cluster             = module.ecs.ecs_cluster
  public_subnet_ids       = [module.networking.public_subnets[0].id]
  database_secret         = module.database.pv-database-secret
  database_secret_forecast = module.database.forecast-database-secret
  docker_version          = var.pv_version
  docker_version_ss          = var.pv_ss_version
  iam-policy-rds-read-secret = module.database.iam-policy-pv-db-read
  iam-policy-rds-read-secret_forecast = module.database.iam-policy-forecast-db-read
}

module "gsp" {
  source = "../../modules/services/gsp"

  region                  = var.region
  environment             = var.environment
  ecs-cluster             = module.ecs.ecs_cluster
  public_subnet_ids       = [module.networking.public_subnets[0].id]
  database_secret         = module.database.forecast-database-secret
  docker_version          = var.gsp_version
  iam-policy-rds-read-secret = module.database.iam-policy-forecast-db-read
}

module "metrics" {
  source = "../../modules/services/metrics"

  region                  = var.region
  environment             = var.environment
  ecs-cluster             = module.ecs.ecs_cluster
  public_subnet_ids       = [module.networking.public_subnets[0].id]
  database_secret         = module.database.forecast-database-secret
  docker_version          = var.metrics_version
  iam-policy-rds-read-secret = module.database.iam-policy-forecast-db-read
}


module "forecast" {
  source = "../../modules/services/forecast"

  region                        = var.region
  environment                   = var.environment
  ecs-cluster                   = module.ecs.ecs_cluster
  subnet_ids                    = [module.networking.public_subnets[0].id]
  iam-policy-rds-read-secret    = module.database.iam-policy-forecast-db-read
  iam-policy-rds-pv-read-secret = module.database.iam-policy-pv-db-read
  iam-policy-s3-nwp-read        = module.s3.iam-policy-s3-nwp-read
  iam-policy-s3-sat-read        = module.s3.iam-policy-s3-sat-read
  iam-policy-s3-ml-read         = module.s3.iam-policy-s3-ml-write #TODO update name
  database_secret               = module.database.forecast-database-secret
  pv_database_secret            = module.database.pv-database-secret
  docker_version                = var.forecast_version
  s3-nwp-bucket                 = module.s3.s3-nwp-bucket
  s3-sat-bucket                 = module.s3.s3-sat-bucket
  s3-ml-bucket                  = module.s3.s3-ml-bucket
}


module "national_forecast" {
  source = "../../modules/services/forecast_pvsite"

  region      = var.region
  environment = var.environment
  app-name    = "forecast_national"
  ecs_config  = {
    docker_image   = "openclimatefix/gradboost_pv"
    docker_version = var.national_forecast_version
    memory_mb = 6144
  }
  rds_config = {
    database_secret_arn             = module.database.forecast-database-secret.arn
    database_secret_read_policy_arn = module.database.iam-policy-forecast-db-read.arn
  }
  scheduler_config = {
    subnet_ids      = [module.networking.public_subnets[0].id]
    ecs_cluster_arn = module.ecs.ecs_cluster.arn
    cron_expression = "cron(15,45 * * * ? *)" # Every 10 minutes
  }
  s3_ml_bucket = {
    bucket_id              = module.forecasting_models_bucket.bucket.id
    bucket_read_policy_arn = module.forecasting_models_bucket.read-policy.arn
  }
  s3_nwp_bucket = {
    bucket_id = module.s3.s3-nwp-bucket.id
    bucket_read_policy_arn = module.s3.iam-policy-s3-nwp-read.arn
  }
}
