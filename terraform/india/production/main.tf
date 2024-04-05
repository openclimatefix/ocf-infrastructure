# Defines the production India platform
# Creates the following in AWS:
# 1.0 - VPC and Subnets
# 1.1 - RDS Postgres database
# 1.2 - Bastion instance
# 1.2 - ECS Cluster

locals {
  environment = "production"
  domain      = "india"
  region      = "ap-south-1"
}

# 1.0
module "network" {
  source             = "../../modules/networking"
  environment        = local.environment
  vpc_cidr           = "10.1.0.0/16"
  region             = local.region
  availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  domain             = local.domain
}

# 1.1
module "postgres-rds" {
  source               = "../../modules/storage/postgres"
  region               = local.region
  environment          = local.environment
  vpc_id               = module.network.vpc_id
  db_subnet_group_name = module.network.private_subnet_group_name
  db_name              = "indiadb"
  rds_instance_class   = "db.t3.small"
  allow_major_version_upgrade  = true
  engine_version = "16.1"
}

# 0.2
module "ec2-bastion" {
  source = "../../modules/networking/ec2_bastion"

  region            = local.region
  vpc_id            = module.network.vpc_id
  public_subnets_id = module.network.public_subnet_ids[0]
}

# 1.2
module "ecs-cluster" {
  source   = "../../modules/ecs_cluster"
  name     = "india-ecs-cluster-${local.environment}"
  region   = local.region
  owner_id = module.network.owner_id
}

