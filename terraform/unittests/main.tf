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
  source = "../modules/ecs_cluster"

  region      = var.region
  environment = var.environment
}


module "postgres" {
  source = "../modules/storage/postgres"

  region          = var.region
  environment     = var.environment
  db_subnet_group_name = module.networking.private_subnet_group
  vpc_id          = module.networking.vpc_id
  db_name            = "testdb"
  rds_instance_class = "db.t3.micro"
  allow_major_version_upgrade = true
}

module "nwp" {
  source = "../modules/services/ecs_task"

  aws-environment = var.environment
  aws-region = var.region
  aws-secretsmanager_secret_arn = ""

  ecs-task_execution_role_arn   = module.ecs.ecs_task_execution_role_arn
  ecs-task_name                 = ""

  container-command = []
  container-env_vars = []
  container-name = ""
  container-tag = ""
  container-secret_vars         = []

  s3-buckets = [{
    id : module.s3.s3-nwp-bucket.id,
    access-policy-arn : module.s3.iam-policy-s3-nwp-write.arn
  }]
}
