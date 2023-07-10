/*====
Variables used across all modules
======*/
locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  domain = "nowcasting"
}


module "airflow" {
  source = "../../modules/services/airflow"

  region                              = var.region
  environment                         = var.environment
  vpc_id                              = var.vpc_id
}
