locals {
  environment = "development"
  domain = "india"
}

# Create the VPC, public and private subnets
module "network" {
  source = "../../modules/networking"
  environment = local.environment
  vpc_cidr = "10.1.0.0/16"
}

module "ecs_cluster" {
  source = "../../modules/ecs_cluster"
  environment = local.environment
  region = module.network.vpc_region
  domain = local.domain
}