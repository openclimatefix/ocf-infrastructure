# Defines the production India platform
# Creates the following in AWS:
# 1.0 - VPC and Subnets
# 1.1 - RDS Postgres database
# 1.2 - Bastion instance
# 1.3 - ECS Cluster
# 2.0 - S3 bucket for NWP data
# 2.1 - S3 bucket for Satellite data
# 2.2 - S3 bucket for Forecast data
# 3.0 - Secret containing environment variables for the NWP consumer
# 3.1 - Secret containing environment variables for the Satellite consumer
# 3.2 - Secret containing HF read access
# 5.0 - Airflow EB Instance
# 5.1 - India API EB Instance
# 5.2 - India Analysis Dashboard

locals {
  environment = "production"
  domain      = "india"
  region      = "ap-south-1"
}

# 1.0
module "network" {
  source             = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/networking?ref=205465e"
  environment        = local.environment
  vpc_cidr           = "10.1.0.0/16"
  region             = local.region
  availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  domain             = local.domain
}

# 1.1
module "postgres-rds" {
  source               = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/storage/postgres?ref=a79aaa8"
  region               = local.region
  environment          = local.environment
  vpc_id               = module.network.vpc_id
  db_subnet_group_name = module.network.private_subnet_group_name
  db_name              = "indiadb"
  rds_instance_class   = "db.t3.small"
  allow_major_version_upgrade  = true
  engine_version = "17.4"
}

# 1.2
module "ec2-bastion" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/networking/ec2_bastion?ref=205465e"
  region            = local.region
  vpc_id            = module.network.vpc_id
  public_subnets_id = module.network.public_subnet_ids[0]
}

# 1.3
module "ecs-cluster" {
  source   = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/ecs_cluster?ref=7e48923"
  name     = "india-ecs-cluster-${local.environment}"
  region   = local.region
  owner_id = module.network.owner_id
}

# 2.0
module "s3-nwp-bucket" {
  source              = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/storage/s3-private?ref=205465e"
  environment         = local.environment
  region              = var.region
  domain              = local.domain
  service_name        = "nwp"
  lifecycled_prefixes = ["ecmwf", "gfs", "metoffice"]
}

# 2.1
module "s3-satellite-bucket" {
  source              = "../../modules/storage/s3-private"
  environment         = local.environment
  region              = var.region
  domain              = local.domain
  service_name        = "satellite"
  lifecycled_prefixes = ["data", "raw"]
}

# 2.2
module "s3-forecast-bucket" {
  source              = "../../modules/storage/s3-private"
  environment         = local.environment
  region              = var.region
  domain              = local.domain
  service_name        = "forecast"
  lifecycled_prefixes = [""]
}

# 3.0
resource "aws_secretsmanager_secret" "nwp_consumer_secret" {
  name = "${local.environment}/data/nwp-consumer"
}

# 3.1
resource "aws_secretsmanager_secret" "satellite_consumer_secret" {
  name = "${local.environment}/data/satellite-consumer"
}

# 3.2
resource "aws_secretsmanager_secret" "huggingface_consumer_secret" {
  name = "${local.environment}/huggingface/token"
}

# 4.0
module "airflow" {
  source                    = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/airflow?ref=81fca80"
  source                    = "../../modules/services/airflow"
  aws-environment           = local.environment
  aws-region                = local.region
  aws-domain                = local.domain
  aws-vpc_id                = module.network.vpc_id
  aws-subnet_id             = module.network.public_subnet_ids[0]
  aws-owner_id              = module.network.owner_id
  docker-compose-version    = "0.0.11"
  dags_folder               = "india"
  container-env_vars = [
    { "name" : "AIRFLOW_CONN_SLACK_API_DEFAULT", "value" : var.apikey-slack },
    { "name" : "AIRFLOW_UID", "value" : 50000 },
    { "name" : "AWS_DEFAULT_REGION", "value": var.region},
    { "name" : "DB_URL", "value" :  "${module.postgres-rds.instance_connection_url}/airflow"},
    { "name" : "ECS_EXECUTION_ROLE_ARN", "value" : module.ecs-cluster.ecs_task_execution_role_arn},
    { "name" : "ECS_SECURITY_GROUP", "value" : module.network.default_security_group_id },
    { "name" : "ECS_SUBNET", "value" : module.network.public_subnet_ids[0] },
    { "name" : "ECS_TASK_ROLE_ARN", "value" : module.ecs-cluster.ecs_task_run_role_arn },
    { "name" : "ENVIRONMENT", "value" : local.environment },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn_api },
    { "name" : "LOGLEVEL", "value" : "INFO" },
  ]
}

# 5.1
module "india-api" {
  source             = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/eb_app?ref=6e24edf"
  domain             = local.domain
  aws-region         = local.region
  aws-environment    = local.environment
  aws-subnet_id      = module.network.public_subnet_ids[0]
  aws-vpc_id         = module.network.vpc_id
  container-command  = []
  container-env_vars = [
    { "name" : "SOURCE", "value" : "indiadb" },
    { "name" : "PORT", "value" : "80" },
    { "name" : "DB_URL", "value" : module.postgres-rds.default_db_connection_url},
    { "name" : "AUTH0_DOMAIN", "value" : var.auth_domain },
    { "name" : "AUTH0_API_AUDIENCE", "value" : var.auth_api_audience },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn_api },
    { "name" : "ENVIRONMENT", "value": local.environment},
  ]
  container-name = "india-api"
  container-tag  = var.version-india_api
  eb-app_name    = "india-api"
}

# 5.2
module "analysis_dashboard" {
  source             = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/eb_app?ref=5bc9429"
  domain             = local.domain
  aws-region         = var.region
  aws-environment    = local.environment
  aws-subnet_id      = module.network.public_subnet_ids[0]
  aws-vpc_id         = module.network.vpc_id
  container-command  = ["streamlit", "run", "main_india.py", "--server.port=8501", "--browser.serverAddress=0.0.0.0", "--server.address=0.0.0.0", "–server.enableCORS False"]
  container-env_vars = [
    { "name" : "DB_URL", "value" :  module.postgres-rds.default_db_connection_url},
    { "name" : "SITES_DB_URL", "value" :  module.postgres-rds.default_db_connection_url},
    { "name" : "ORIGINS", "value" : "*" },
    { "name" : "REGION", "value": local.domain},
    { "name" : "ENVIRONMENT", "value": local.environment},
    { "name" : "AUTH0_DOMAIN", "value" : var.auth_domain },
    { "name" : "AUTH0_CLIENT_ID", "value" : var.auth_dashboard_client_id },
  ]
  container-name = "analysis-dashboard"
  container-tag  = var.analysis_dashboard_version
  container-registry = "ghcr.io/openclimatefix"
  container-port = 8501
  eb-app_name    = "analysis-dashboard"
  eb-instance_type = "t3.small"
  s3_bucket = [
    { bucket_read_policy_arn = module.s3-nwp-bucket.read_policy_arn },
    { bucket_read_policy_arn = module.s3-satellite-bucket.read_policy_arn }
  ]
}

