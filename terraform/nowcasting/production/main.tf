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
3.1 - Airflow instance
4.1 - OCF Dashboard
5.1 - PVSite database
5.2 - PVSite API
5.3 - PVSite ML bucket

Variables used across all modules
======*/
locals {
  environment = "production"
  domain = "uk"
}

# 0.1
module "networking" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/networking?ref=5a5d03a"
  domain = local.domain
  environment = local.environment
  region = var.region
}

# 0.2
module "ec2-bastion" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/networking/ec2_bastion?ref=53a4ac9"
  region            = var.region
  vpc_id            = module.networking.vpc_id
  public_subnets_id = module.networking.public_subnet_ids[0]
}

# 0.3
module "s3" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/storage/s3-trio?ref=17f0d59"
  region      = var.region
  environment = local.environment
}

# 0.4
module "ecs" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/ecs_cluster?ref=7e48923"
  name = "Nowcasting-${local.environment}"
  region = var.region
  owner_id = module.networking.owner_id
}

# 0.5
module "forecasting_models_bucket" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/storage/s3-private?ref=2747e85"
  region              = var.region
  environment         = local.environment
  service_name        = "national-forecaster-models"
  domain              = local.domain
  lifecycled_prefixes = []
}

# 0.6
module "database" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/storage/database-pair?ref=a79aaa8"
  region               = var.region
  environment          = local.environment
  db_subnet_group_name = module.networking.private_subnet_group_name
  vpc_id               = module.networking.vpc_id
  engine_version       = "15.8"
}

# 1.1
module "api" {
  source             = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/eb_app?ref=72ba38d"
  domain             = local.domain
  aws-region         = var.region
  aws-environment    = local.environment
  aws-subnet_id      = module.networking.public_subnet_ids[0]
  aws-vpc_id         = module.networking.vpc_id
  container-command  = ["uvicorn", "nowcasting_api.main:app", "--host", "0.0.0.0", "--port", "80"]
  container-env_vars = [
    { "name" : "DB_URL", "value" :  module.database.forecast-database-secret-url},
    { "name" : "ORIGINS", "value" : "*" },
    { "name" : "SENTRY_DSN", "value" : var.sentry_monitor_dsn_api },
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
  eb-instance_type = "t3.medium"
  s3_bucket = [
    { bucket_read_policy_arn = module.s3.iam-policy-s3-nwp-read.arn },
    { bucket_read_policy_arn = module.s3.iam-policy-s3-sat-read.arn }
  ]
}

# 2.2
resource "aws_secretsmanager_secret" "nwp_consumer_secret" {
  name = "${local.environment}/data/nwp-consumer"
}

# 2.3
resource "aws_secretsmanager_secret" "satellite_consumer_secret" {
  name = "${local.environment}/data/satellite-consumer"
}

# 3.1
module "airflow" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/airflow?ref=a79aaa8"
  aws-environment   = local.environment
  aws-domain        = local.domain
  aws-vpc_id        = module.networking.vpc_id
  aws-subnet_id       = module.networking.public_subnet_ids[0]
  airflow-db-connection-url        = module.database.forecast-database-secret-airflow-url
  docker-compose-version       = "0.0.6"
  ecs-subnet_id = module.networking.public_subnet_ids[0]
  ecs-security_group=module.networking.default_security_group_id
  ecs-execution_role_arn     = module.ecs.ecs_task_execution_role_arn
  ecs-task_role_arn          = module.ecs.ecs_task_run_role_arn
  aws-owner_id = module.networking.owner_id
  slack_api_conn=var.airflow_conn_slack_api_default

}

# 4.1
module "analysis_dashboard" {
  source             = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/eb_app?ref=f16703d"
  domain             = local.domain
  aws-region         = var.region
  aws-environment    = local.environment
  aws-subnet_id      = module.networking.public_subnet_ids[0]
  aws-vpc_id         = module.networking.vpc_id
  container-command  = ["streamlit", "run", "main.py", "--server.port=8501", "--browser.serverAddress=0.0.0.0", "--server.address=0.0.0.0", "–server.enableCORS False"]
  container-env_vars = [
    { "name" : "DB_URL", "value" :  module.database.forecast-database-secret-url},
    { "name" : "SITES_DB_URL", "value" :  module.sites_database.default_db_connection_url},
    { "name" : "SHOW_PVNET_GSP_SUM", "value" : "true" },
    { "name" : "ORIGINS", "value" : "*" },
    { "name" : "AUTH0_DOMAIN", "value" : var.auth_domain },
    { "name" : "AUTH0_CLIENT_ID", "value" : var.auth_dashboard_client_id },
    { "name" : "REGION", "value": local.domain},
    { "name" : "ENVIRONMENT", "value": local.environment},
    { "name" : "SENTRY_DSN", "value" : var.sentry_dsn },
  ]
  container-name = "analysis-dashboard" 
  container-tag  = var.internal_ui_version
  container-registry = "ghcr.io/openclimatefix"
  container-port = 8501
  eb-app_name    = "internal-ui"
  eb-instance_type = "t3.small"
  s3_bucket = [
    { bucket_read_policy_arn = module.s3.iam-policy-s3-nwp-read.arn },
    { bucket_read_policy_arn = module.s3.iam-policy-s3-sat-read.arn }
  ]
}

# 5.1
import {
  to = module.sites_database.aws_db_instance.postgres-db
  id = "sites-production"
}
module "sites_database" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/storage/postgres?ref=a79aaa8"
  region                      = var.region
  environment                 = local.environment
  db_subnet_group_name        = module.networking.private_subnet_group_name
  vpc_id                      = module.networking.vpc_id
  db_name                     = "sites"
  rds_instance_class          = "db.t3.small"
  allow_major_version_upgrade = true
  engine_version = "15.8"
}

# 5.2
module "pvsite_api" {
  source             = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/eb_app?ref=6e24edf"
  domain             = local.domain
  aws-region         = var.region
  aws-environment    = local.environment
  aws-subnet_id      = module.networking.public_subnet_ids[0]
  aws-vpc_id         = module.networking.vpc_id
  container-command  = ["poetry", "run", "uvicorn", "pv_site_api.main:app", "--host", "0.0.0.0", "--port", "80"]
  container-env_vars = [
    { "name" : "PORT", "value" : "80" },
    { "name" : "DB_URL", "value" :  module.sites_database.default_db_connection_url},
    { "name" : "FAKE", "value" : "0" },
    { "name" : "ORIGINS", "value" : "*" },
    { "name" : "SENTRY_DSN", "value" : var.sentry_monitor_dsn_api },
    { "name" : "AUTH0_API_AUDIENCE", "value" : var.auth_api_audience },
    { "name" : "AUTH0_DOMAIN", "value" : var.auth_domain },
    { "name" : "AUTH0_ALGORITHM", "value" : "RS256" },
    { "name" : "ENVIRONMENT", "value" : "production" },
  ]
  container-name = "nowcasting_site_api"
  container-tag  = var.pvsite_api_version
  container-registry = "openclimatefix"
  eb-app_name    = "sites-api"
  eb-instance_type = "t3.small"
}

# 5.3
module "pvsite_ml_bucket" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/storage/s3-private?ref=2747e85"
  region              = var.region
  environment         = local.environment
  service_name        = "site-forecaster-models"
  domain              = local.domain
  lifecycled_prefixes = []
}

