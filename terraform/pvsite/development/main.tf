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

module "metrics" {
  source = "../../modules/services/metrics"

  region                  = var.region
  environment             = var.environment
  ecs-cluster             = module.ecs.ecs_cluster
  public_subnet_ids       = [module.networking.public_subnets[0].id]
  database_secret         = module.pvsite_database.secret
  docker_version          = var.metrics_version
  iam-policy-rds-read-secret = module.pvsite_database.secret-policy
}
