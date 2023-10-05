/*====
Variables used across all modules
======*/
locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  domain = "airflow"
}




module "airflow_subnetworking" {
  source = "../../modules/subnetworking"

  region                     = var.region
  environment                = var.environment
  vpc_id                     = var.vpc_id
  public_subnets_cidr        = var.public_subnets_cidr
  private_subnets_cidr       = var.private_subnets_cidr
  availability_zones         = local.production_availability_zones
  domain                     = local.domain
  public_internet_gateway_id = var.public_internet_gateway_id
}

module "airflow" {
  source = "../../modules/services/airflow"

  environment   = var.environment
  vpc_id        = var.vpc_id
  subnets       = [module.airflow_subnetworking.public_subnet.id]
  db_url        = var.db_url
  db_url_airflow        = var.db_url_airflow
  docker-compose-version       = "0.0.4"
  ecs_subnet=module.airflow_subnetworking.public_subnet.id
  ecs_security_group=var.ecs_security_group
}