# Variables used across all modules
locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  domain                        = "pvsite"
}

module "pvsite_subnetworking" {
  source = "../../modules/subnetworking"

  region                     = var.region
  environment                = var.environment
  vpc_id                     = var.vpc_id
  public_subnets_cidr        = var.public_subnets_cidr
  private_subnets_cidr       = var.private_subnets_cidr
  availability_zones         = local.production_availability_zones
  domain                     = local.domain
  public_internet_gateway_id = var.public_internet_gateway_id
}

module "pvsite_database" {
  source = "../../modules/storage/postgres"

  region             = var.region
  environment        = var.environment
  db_subnet_group    = module.pvsite_subnetworking.private_subnet_group
  vpc_id             = var.vpc_id
  db_name            = "pvsite"
  rds_instance_class = "db.t3.small"
}

module "pvsite_api" {
  source = "../../modules/services/api_pvsite"

  region         = var.region
  environment    = var.environment
  vpc_id         = var.vpc_id
  subnets        = var.public_subnets
  docker_version = var.pvsite_api_version
  domain         = local.domain
}

module "pvsite_ml_bucket" {
  source = "../../modules/storage/s3-private"

  region              = var.region
  environment         = var.environment
  service_name        = "ml-models"
  domain              = local.domain
  lifecycled_prefixes = []
}

module "pvsite_ecs" {
  source = "../../modules/ecs"

  region      = var.region
  environment = var.environment
  domain      = local.domain
}

module "pvsite_forecast" {
  source = "../../modules/services/forecast_pvsite"

  region      = var.region
  environment = var.environment
  app-name    = "pvsite_forecast"
  ecs_config  = {
    docker_image   = "openclimatefix/pvsite_forecast"
    docker_version = var.pvsite_forecast_version
  }
  rds_config = {
    database_secret_arn             = module.pvsite_database.secret.arn
    database_secret_read_policy_arn = module.pvsite_database.secret-policy.arn
  }
  scheduler_config = {
    subnet_ids      = [module.pvsite_subnetworking.public_subnets[0].id]
    ecs_cluster_arn = module.pvsite_ecs.ecs_cluster.arn
    cron_expression = "cron(*/10 * * * ? *)" # Every 10 minutes
  }
  s3_ml_bucket = {
    bucket_id              = module.pvsite_ml_bucket.bucket.id
    bucket_read_policy_arn = module.pvsite_ml_bucket.read-policy.arn
  }
  s3_nwp_bucket = var.nwp_bucket_config
}
