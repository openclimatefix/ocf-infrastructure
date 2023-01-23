/*====
Variables used across all modules
======*/
locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  domain                        = "pvsite"
}


module "pvsite_subnetworking" {
  source = "../../modules/subnetworking"

  region               = var.region
  environment          = var.environment
  vpc_id               = var.vpc_id
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = local.production_availability_zones
  domain               = local.domain
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

  region                              = var.region
  environment                         = var.environment
  vpc_id                              = var.vpc_id
  subnets                             = var.public_subnets
  docker_version                      = var.pvsite_api_version
  domain                              = local.domain
}

module "pvsite_ml_bucket" {
  source = "../../modules/storage/s3-private"

  region = var.region
  environment = var.environment
  service_name = "ml-models"
  domain = local.domain
  lifecycled_prefixes = []
}
