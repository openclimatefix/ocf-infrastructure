locals {
  environment = "development"
}

# Create the VPC, public and private subnets
module "networks" {
  source = "../../modules/networking"
  environment = local.environment
}

module "ecs_cluster" {
  source = "../../modules/ecs_cluster"
  environment = local.environment
  region = module.networks.vpc_region
  domain = "quartz"
}