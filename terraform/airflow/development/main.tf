/*====
Variables used across all modules
======*/
locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  domain = "airflow"
}


module "airflow" {
  source = "../../modules/services/airflow"

  environment   = var.environment
  vpc_id        = var.vpc_id
  subnets       = var.subnets
}