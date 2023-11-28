# Defines the development India platform
# Creates the following in AWS:
# 1.0 - VPC and Subnets
# 1.1 - ECS Cluster
# 2.0 - S3 bucket for NWP data
# 3.0 - Secret containing environment variables for the NWP consumer
# 3.1 - ECS task definition for the NWP consumer
# 4.0 - Airflow EB Instance

locals {
  environment = "development"
  domain      = "india"
}

# 1.0
module "network" {
  source      = "../../modules/networking"
  environment = local.environment
  vpc_cidr    = "10.1.0.0/16"
  region      = "ap-south-1"
}

# 1.1
module "ecs-cluster" {
  source   = "../../modules/ecs_cluster"
  name     = "india-ecs-cluster-${local.environment}"
  region   = var.region
  owner_id = module.network.owner_id
}

# 2.0
module "s3-nwp-bucket" {
  source              = "../../modules/storage/s3-private"
  environment         = local.environment
  region              = var.region
  domain              = local.domain
  service_name        = "nwp"
  lifecycled_prefixes = ["ecmwf/data", "ecmwf/raw"]
}

# 3.0
resource "aws_secretsmanager_secret" "nwp_consumer_secret" {
  name = "${local.environment}/data/nwp-consumer"
}

# 3.1
module "npw_consumer_ecmwf_ecs" {
  source = "../../modules/services/nwp_consumer"

  ecs-task_name               = "nwp-consumer-ecmwf"
  ecs-task_type               = "consumer"
  ecs-task_execution_role_arn = module.ecs-cluster.ecs_task_execution_role_arn

  aws-region                     = var.region
  aws-environment                = local.environment
  aws-secretsmanager_secret_name = aws_secretsmanager_secret.nwp_consumer_secret.name

  s3-buckets = [
    {
      id : module.s3-nwp-bucket.bucket_id,
      access_policy_arn : module.s3-nwp-bucket.write_policy_arn
    }
  ]

  container-env_vars = [
    { "name" : "AWS_REGION", "value" : var.region },
    { "name" : "AWS_S3_BUCKET", "value" : module.s3-nwp-bucket.bucket_id },
    { "name" : "LOGLEVEL", "value" : "DEBUG" },
    { "name" : "ECMWF_AREA", "value" : "nw-india" },
  ]
  container-secret_vars = ["ECMWF_API_KEY", "ECMWF_API_EMAIL", "ECMWF_API_URL"]
  container-tag         = var.version_nwp
  container-name        = "openclimatefix/nwp-consumer"
  container-command     = [
    "download",
    "--source=ecmwf-mars",
    "--sink=s3",
    "--rdir=ecmwf/raw",
    "--zdir=ecmwf/data",
    "--create-latest"
  ]

}

# 4.0
module "airflow" {
  source                         = "../../modules/services/airflow"
  environment                    = local.environment
  vpc_id                         = module.network.vpc_id
  subnet_id                      = module.network.public_subnet_ids[0]
  db_url                         = "not-set"
  docker-compose-version         = "0.0.4"
  ecs_subnet_id                  = module.network.public_subnet_ids[0]
  ecs_security_group             = module.network.default_security_group_id
  owner_id                       = module.network.owner_id
  airflow_conn_slack_api_default = var.airflow_conn_slack_api_default
}


