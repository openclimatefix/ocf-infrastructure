locals {
  environment = "development"
}

# Create the VPC, public and private subnets
module "networks" {
  source = "../../modules/networking"
  environment = local.environment
}