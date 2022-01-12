/*====
Variables used across all modules
======*/
locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

module "networking" {
  source = "./modules/networking"

  region               = "${var.region}"
  environment          = "${var.environment}"
  vpc_cidr             = "${var.vpc_cidr}"
  public_subnets_cidr  = "${var.public_subnets_cidr}"
  private_subnets_cidr = "${var.private_subnets_cidr}"
  availability_zones   = "${local.production_availability_zones}"
}

module "s3" {
  source = "./modules/s3"

  region               = "${var.region}"
  environment          = "${var.environment}"
}

module "ecs" {
  source = "./modules/ecs"

  region               = "${var.region}"
  environment          = "${var.environment}"
}
