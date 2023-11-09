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
  source = "../modules/storage/s3-private"

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

  region            = var.region
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  subnets           = module.networking.public_subnets
  auth_api_audience = var.auth_api_audience
  auth_domain       = var.auth_domain
}

module "postgres" {
  source = "../modules/storage/postgres"

  region          = var.region
  environment     = var.environment
  db_subnet_group = module.networking.private_subnet_group
  vpc_id          = module.networking.vpc_id
  db_name            = "testdb"
  rds_instance_class = "db.t3.micro"
  allow_major_version_upgrade = true
}

module "nwp" {
  source = "../modules/services/nwp_consumer"

  aws_config = {
    region = var.region
    environment = var.environment
    public_subnet_ids = [module.networking.public_subnets[0].id]
  }

  s3_config = {
    bucket_id = module.s3.s3-nwp-bucket.id
    bucket_write_policy_arn = module.s3.iam-policy-s3-nwp-write.arn
  }

  docker_config = {}

  app_name = ""
}
