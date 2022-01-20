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
  database_secret_url        = module.database.database-secret-url
  iam-policy-rds-read-secret = module.database.iam-policy-db-read
  docker_version             = "0.1.8"
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
  subnet_ids              = [module.networking.public_subnets[0].id]
}


module "forecast" {
  source = "../modules/services/forecast"

  region                     = var.region
  environment                = var.environment
  ecs-cluster                = module.ecs.ecs_cluster
  subnet_ids                 = [module.networking.public_subnets[0].id]
  iam-policy-rds-read-secret = module.database.iam-policy-db-read
  iam-policy-s3-nwp-read     = module.s3.iam-policy-s3-nwp-read
  database_secret            = module.database.database-secret
}
