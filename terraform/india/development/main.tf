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
