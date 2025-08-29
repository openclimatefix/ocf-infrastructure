/*====

This is the main terraform code for the UK platform. It is used to deploy the platform to AWS.

0.1 - Networking
0.2 - EC2 bastion
0.3 - S3 buckets
0.4 - ECS cluster
0.5 - S3 bucket for forecasters
0.6 - Database
1.1 - API
2.1 - NWP Consumer Secret
2.2 - Satellite Consumer Secret
2.3 - PV Secret
3.1 - Airflow EB instance
4.1 - OCF Dashboard
5.1 - PVSite database
5.2 - PVSite API
5.3 - PVSite ML bucket
6.1 - Open Data PVnet
7.0 - API Open Quartz Solar

Variables used across all modules
======*/
locals {
  environment = "development"
  domain = "uk"
}

# 0.1
module "networking" {
  source = "../../modules/networking"
  domain = local.domain
  environment = local.environment
  region = var.region
}

# 0.2
module "ec2-bastion" {
  source = "../../modules/networking/ec2_bastion"
  region            = var.region
  vpc_id            = module.networking.vpc_id
  public_subnets_id = module.networking.public_subnet_ids[0]
  bastion_ami = "ami-0069d66985b09d219"
}

# 0.3
module "s3" {
  source = "../../modules/storage/s3-trio"
  region      = var.region
  environment = local.environment
}

# 0.4
module "ecs" {
  source = "../../modules/ecs_cluster"
  name = "Nowcasting-${local.environment}"
  region = var.region
  owner_id = module.networking.owner_id
}

# 0.5
module "forecasting_models_bucket" {
  source = "../../modules/storage/s3-private"
  region              = var.region
  environment         = local.environment
  service_name        = "national-forecaster-models"
  domain              = local.domain
  lifecycled_prefixes = []
}

# 0.6
module "database" {
  source = "../../modules/storage/database-pair"
  region               = var.region
  environment          = local.environment
  db_subnet_group_name = module.networking.private_subnet_group_name
  vpc_id               = module.networking.vpc_id
}

# 1.1
module "api" {
  source             = "../../modules/services/eb_app"
  domain             = local.domain
  aws-region         = var.region
  aws-environment    = local.environment
  aws-subnet_id      = module.networking.public_subnet_ids[0]
  aws-vpc_id         = module.networking.vpc_id
  container-command  = ["uvicorn", "nowcasting_api.main:app", "--host", "0.0.0.0", "--port", "80"]
  container-env_vars = [
    { "name" : "DB_URL", "value" :  module.database.forecast-database-secret-url},
    { "name" : "ORIGINS", "value" : "*" },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn_api },
    { "name" : "AUTH0_DOMAIN", "value" : var.auth_domain },
    { "name" : "AUTH0_API_AUDIENCE", "value" : var.auth_api_audience },
    { "name" : "AUTH0_RULE_NAMESPACE", "value" : "https://openclimatefix.org"},
    { "name" : "AUTH0_CLIENT_ID", "value" : var.auth_dashboard_client_id },
    { "name" : "ADJUST_MW_LIMIT", "value" : "1000" },
    { "name" : "N_HISTORY_DAYS", "value" : "2" },
    { "name" : "ENVIRONMENT", "value" : local.environment },
  ]
  container-name = "nowcasting_api"
  container-tag  = var.api_version
  container-registry = "openclimatefix"
  eb-app_name    = "nowcasting-api"
  eb-instance_type = "t3.small"
  s3_bucket = [
    { bucket_read_policy_arn = module.s3.iam-policy-s3-nwp-read.arn },
    { bucket_read_policy_arn = module.s3.iam-policy-s3-sat-read.arn }
  ]
  min_ec2_count = 2
  max_ec2_count = 2
}

# 2.1
resource "aws_secretsmanager_secret" "nwp_consumer_secret" {
  name = "${local.environment}/data/nwp-consumer"
}

# 2.2
resource "aws_secretsmanager_secret" "satellite_consumer_secret" {
  name = "${local.environment}/data/satellite-consumer"
}

# 2.3
resource "aws_secretsmanager_secret" "pv_consumer_secret" {
  name = "${local.environment}/data/solar-sheffield"
}

# 3.1
module "airflow" {
  source = "../../modules/services/airflow"
  aws-environment            = local.environment
  aws-domain                 = local.domain
  aws-vpc_id                 = module.networking.vpc_id
  aws-subnet_id              = module.networking.public_subnet_ids[0]
  aws-owner_id               = module.networking.owner_id
  docker-compose-version     = "0.0.14"
  container-env_vars = [
    { "name" : "AIRFLOW_UID", "value" : 50000 },
    { "name" : "AIRFLOW_CONN_SLACK_API_DEFAULT", "value" : var.airflow_conn_slack_api_default },
    { "name" : "AWS_DEFAULT_REGION", "value": var.region},
    { "name" : "AUTH0_API_AUDIENCE", "value" : var.auth_api_audience },
    { "name" : "AUTH0_CLIENT_ID", "value" : var.auth_dashboard_client_id },
    { "name" : "AUTH0_DOMAIN", "value" : var.auth_domain },
    { "name" : "AUTH0_USERNAME", "value" : var.airflow_auth_username },
    { "name" : "AUTH0_PASSWORD", "value" : var.airflow_auth_password },
    { "name" : "AUTH0_AUDIENCE", "value" : var.auth_api_audience },
    { "name" : "DB_URL", "value" :  module.database.forecast-database-secret-airflow-url},
    { "name" : "ECS_EXECUTION_ROLE_ARN", "value" : module.ecs.ecs_task_execution_role_arn},
    { "name" : "ECS_SECURITY_GROUP", "value" : module.networking.default_security_group_id },
    { "name" : "ECS_SUBNET", "value" : module.networking.public_subnet_ids[0] },
    { "name" : "ECS_TASK_ROLE_ARN", "value" : module.ecs.ecs_task_run_role_arn },
    { "name" : "ENVIRONMENT", "value" : local.environment },
    { "name" : "LOGLEVEL", "value" : "INFO" },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn_api },
    { "name" : "URL", "value" : var.airflow_url },
  ]
}

# 4.1
module "analysis_dashboard" {
  source             = "../../modules/services/eb_app"
  domain             = local.domain
  aws-region         = var.region
  aws-environment    = local.environment
  aws-subnet_id      = module.networking.public_subnet_ids[0]
  aws-vpc_id         = module.networking.vpc_id
  container-command  = ["streamlit", "run", "main.py", "--server.port=8501", "--browser.serverAddress=0.0.0.0", "--server.address=0.0.0.0", "–server.enableCORS False"]
  container-env_vars = [
    { "name" : "DB_URL", "value" :  module.database.forecast-database-secret-url},
    { "name" : "SITES_DB_URL", "value" :  module.pvsite_database.default_db_connection_url},
    { "name" : "SHOW_PVNET_GSP_SUM", "value" : "true" },
    { "name" : "ORIGINS", "value" : "*" },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
    { "name" : "AUTH0_DOMAIN", "value" : var.auth_domain },
    { "name" : "AUTH0_CLIENT_ID", "value" : var.auth_dashboard_client_id },
    { "name" : "REGION", "value": local.domain},
    { "name" : "ENVIRONMENT", "value": local.environment},
  ]
  container-name = "analysis-dashboard"
  container-tag  = var.internal_ui_version
  container-registry = "ghcr.io/openclimatefix"
  container-port = 8501
  eb-app_name    = "internal-ui"
  eb-instance_type = "t3.small"
  s3_bucket = [
    { bucket_read_policy_arn = module.s3.iam-policy-s3-nwp-read.arn },
    { bucket_read_policy_arn = module.s3.iam-policy-s3-sat-read.arn },
    { bucket_read_policy_arn = module.forecasting_models_bucket.read_policy_arn }
  ]
}

# 5.1
module "pvsite_database" {
  source = "../../modules/storage/postgres"
  region                      = var.region
  environment                 = local.environment
  db_subnet_group_name        = module.networking.private_subnet_group_name
  vpc_id                      = module.networking.vpc_id
  db_name                     = "pvsite"
  rds_instance_class          = "db.t3.small"
  allow_major_version_upgrade = true
}

# 5.2
module "pvsite_api" {
  source             = "../../modules/services/eb_app"
  domain             = local.domain
  aws-region         = var.region
  aws-environment    = local.environment
  aws-subnet_id      = module.networking.public_subnet_ids[0]
  aws-vpc_id         = module.networking.vpc_id
  container-command  = ["poetry", "run", "uvicorn", "pv_site_api.main:app", "--host", "0.0.0.0", "--port", "80"]
  container-env_vars = [
    { "name" : "PORT", "value" : "80" },
    { "name" : "DB_URL", "value" : module.pvsite_database.default_db_connection_url},
    { "name" : "FAKE", "value" : "0" },
    { "name" : "ORIGINS", "value" : "*" },
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn_api },
    { "name" : "AUTH0_API_AUDIENCE", "value" : var.auth_api_audience },
    { "name" : "AUTH0_DOMAIN", "value" : var.auth_domain },
    { "name" : "AUTH0_ALGORITHM", "value" : "RS256" },
    { "name" : "ENVIRONMENT", "value" : "development" },
  ]
  container-name = "nowcasting_site_api"
  container-tag  = var.pvsite_api_version
  container-registry = "openclimatefix"
  eb-app_name    = "sites-api"
  eb-instance_type = "t3.small"
  s3_bucket = [
    { bucket_read_policy_arn = module.s3.iam-policy-s3-nwp-read.arn }
  ]
}

# 5.3
module "pvsite_ml_bucket" {
  source = "../../modules/storage/s3-private"
  region              = var.region
  environment         = local.environment
  service_name        = "site-forecaster-models"
  domain              = local.domain
  lifecycled_prefixes = []
}

# 6.1 Open Data PVnet - Public s3 bucket
module "open_data_pvnet_s3" {
  source = "../../modules/storage/open-data-pvnet-s3"
}


# 7.0
module "open_quartz_solar" {
  source = "../../modules/services/lambda_api"
  aws-region              = var.region
  aws-environment         = local.environment
  app_name        = "open-quartz-solar-api"
  container-tag  = var.open_quartz_solar
  container-name = "openclimatefix/open-source-quartz-solar-forecast"
}