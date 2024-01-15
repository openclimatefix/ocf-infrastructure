# Defines the development India platform
# Creates the following in AWS:
# 1.0 - VPC and Subnets
# 1.1 - RDS Postgres database
# 1.2 - Bastion instance
# 1.2 - ECS Cluster
# 2.0 - S3 bucket for NWP data
# 3.0 - Secret containing environment variables for the NWP consumer
# 3.1 - ECS task definition for the NWP consumer
# 4.0 - Airflow EB Instance
# 5.0 - India API EB Instance

locals {
  environment = "development"
  domain      = "india"
  region      = "ap-south-1"
}

# 1.0
module "network" {
  source             = "../../modules/networking"
  environment        = local.environment
  vpc_cidr           = "10.1.0.0/16"
  region             = local.region
  availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  domain             = local.domain
}

# 1.1
module "postgres-rds" {
  source               = "../../modules/storage/postgres"
  region               = local.region
  environment          = local.environment
  vpc_id               = module.network.vpc_id
  db_subnet_group_name = module.network.private_subnet_group_name
  db_name              = "indiadb"
  rds_instance_class   = "db.t3.small"
}

# 0.2
module "ec2-bastion" {
  source = "../../modules/networking/ec2_bastion"

  region            = local.region
  vpc_id            = module.network.vpc_id
  public_subnets_id = module.network.public_subnet_ids[0]
}

# 1.2
module "ecs-cluster" {
  source   = "../../modules/ecs_cluster"
  name     = "india-ecs-cluster-${local.environment}"
  region   = local.region
  owner_id = module.network.owner_id
}

/*
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

  aws-region                    = var.region
  aws-environment               = local.environment
  aws-secretsmanager_secret_arn = aws_secretsmanager_secret.nwp_consumer_secret.arn

  s3-buckets = [{ 
    id: module.s3-nwp-bucket.bucket_id,
    access_policy_arn: module.s3-nwp-bucket.write_policy_arn
  }]

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

*/

# 4.0
module "airflow" {
  source                    = "../../modules/services/airflow"
  aws-environment           = local.environment
  aws-region                = local.region
  aws-domain                = local.domain
  aws-vpc_id                = module.network.vpc_id
  aws-subnet_id             = module.network.public_subnet_ids[0]
  airflow-db-connection-url = "${module.postgres-rds.instance_connection_url}/airflow"
  docker-compose-version    = "0.0.6"
  ecs-subnet_id             = module.network.public_subnet_ids[0]
  ecs-security_group        = module.network.default_security_group_id
  aws-owner_id              = module.network.owner_id
  slack_api_conn            = var.apikey-slack
  dags_folder               = "india"
}

# 5.0
module "india-api" {
  source             = "../../modules/services/eb_app"
  domain             = local.domain
  aws-region         = local.region
  aws-environment    = local.environment
  aws-subnet_id      = module.network.public_subnet_ids[0]
  aws-vpc_id         = module.network.vpc_id
  container-command  = []
  container-env_vars = [
    { "name" : "SOURCE", "value" : "dummydb" },
    { "name" : "PORT", "value" : "80" },
  ]
  container-name = "india-api"
  container-tag  = var.version-india_api
  eb-app_name    = "india-api"
}

