module "forecast-database" {
  source = "terraform/modules/postgres"

  region             = var.region
  environment        = var.environment
  db_subnet_group    = module.networking.private_subnet_group
  vpc_id             = module.networking.vpc_id
  db_name            = "forecast"
  rds_instance_class = "db.t3.small"
}