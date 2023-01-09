/*====
Variables used across all modules
======*/
locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
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


module "pvsite_database" {
  source = "../../modules/postgres"

  region             = var.region
  environment        = var.environment
  db_subnet_group    = module.networking.private_subnet_group
  vpc_id             = module.networking.vpc_id
  db_name            = "pvsite"
  rds_instance_class = "db.t3.small"
}
