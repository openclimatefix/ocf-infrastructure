/*====
Variables used across all modules
======*/
locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

module "networking" {
  source = "../modules/networking"

  region               = var.region
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = local.production_availability_zones
}

module "s3" {
  source = "../modules/s3"

  region      = var.region
  environment = var.environment
}

module "ecs" {
  source = "../modules/ecs"

  region      = var.region
  environment = var.environment
}

module "api" {
  source = "../modules/services/api"

  region                     = var.region
  environment                = var.environment
  vpc_id                     = module.networking.vpc_id
  subnets                    = module.networking.public_subnets
  database_secret_url        = module.database.forecast-database-secret-url
  iam-policy-rds-read-secret = module.database.iam-policy-forecast-db-read
  docker_version             = var.api_version
}

module "database" {
  source = "../modules/database"

  region          = var.region
  environment     = var.environment
  db_subnet_group = module.networking.private_subnet_group
  vpc_id          = module.networking.vpc_id
}

module "nwp" {
  source = "../modules/services/nwp"

  region                  = var.region
  environment             = var.environment
  iam-policy-s3-nwp-write = module.s3.iam-policy-s3-nwp-write
  s3-bucket               = module.s3.s3-nwp-bucket
  ecs-cluster             = module.ecs.ecs_cluster
  public_subnet_ids       = [module.networking.public_subnets[0].id]
  docker_version          = var.nwp_version
}

module "sat" {
  source = "../modules/services/sat"

  region                  = var.region
  environment             = var.environment
  iam-policy-s3-sat-write = module.s3.iam-policy-s3-sat-write
  s3-bucket               = module.s3.s3-sat-bucket
  ecs-cluster             = module.ecs.ecs_cluster
  public_subnet_ids       = [module.networking.public_subnets[0].id]
  docker_version          = var.sat_version
}


module "pv" {
  source = "../modules/services/pv"

  region                  = var.region
  environment             = var.environment
  ecs-cluster             = module.ecs.ecs_cluster
  public_subnet_ids       = [module.networking.public_subnets[0].id]
  database_secret         = module.database.pv-database-secret
  docker_version          = var.pv_version
  iam-policy-rds-read-secret = module.database.iam-policy-pv-db-read
}

module "gsp" {
  source = "../modules/services/gsp"

  region                  = var.region
  environment             = var.environment
  ecs-cluster             = module.ecs.ecs_cluster
  public_subnet_ids       = [module.networking.public_subnets[0].id]
  database_secret         = module.database.forecast-database-secret
  docker_version          = var.gsp_version
  iam-policy-rds-read-secret = module.database.iam-policy-forecast-db-read
}


module "forecast" {
  source = "../modules/services/forecast"

  region                     = var.region
  environment                = var.environment
  ecs-cluster                = module.ecs.ecs_cluster
  subnet_ids                 = [module.networking.public_subnets[0].id]
  iam-policy-rds-read-secret = module.database.iam-policy-forecast-db-read
  iam-policy-s3-nwp-read     = module.s3.iam-policy-s3-nwp-read
  iam-policy-s3-ml-read     = module.s3.iam-policy-s3-ml-read
  database_secret            = module.database.forecast-database-secret
  docker_version             = var.forecast_version
}

module "statusdash" {
  source = "../modules/statusdash"

  region                     = var.region
  environment                = var.environment
  ecs-cluster                = module.ecs.ecs_cluster
  subnet_ids                 = [module.networking.public_subnets[0].id]
}
