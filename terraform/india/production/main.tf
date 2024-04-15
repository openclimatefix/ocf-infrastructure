# Defines the production India platform
# Creates the following in AWS:
# 1.0 - VPC and Subnets
# 1.1 - RDS Postgres database
# 1.2 - Bastion instance
# 1.2 - ECS Cluster
# 2.0 - S3 bucket for NWP data
# 3.0 - Secret containing environment variables for the NWP consumer
# 3.1 - ECS task definition for the NWP consumer
# 3.2 - ECS task definition for Collection RUVNL data
# 3.3 - ECS task definition for the Forecast
# 4.0 - Airflow EB Instance
# 5.0 - India API EB Instance
# 5.1 - India Analysis Dashboard

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
  source               = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/storage/postgres?ref=205465e"
  region               = local.region
  environment          = local.environment
  vpc_id               = module.network.vpc_id
  db_subnet_group_name = module.network.private_subnet_group_name
  db_name              = "indiadb"
  rds_instance_class   = "db.t3.small"
  allow_major_version_upgrade  = true
  engine_version = "16.1"
}

# 0.2
module "ec2-bastion" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/networking/ec2_bastion?ref=205465e"

  region            = local.region
  vpc_id            = module.network.vpc_id
  public_subnets_id = module.network.public_subnet_ids[0]
}

# 1.2
module "ecs-cluster" {
  source   = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/ecs_cluster?ref=205465e"
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
  lifecycled_prefixes = ["ecmwf/data", "ecmwf/raw"]
}

# 3.0
resource "aws_secretsmanager_secret" "nwp_consumer_secret" {
  name = "${local.environment}/data/nwp-consumer"
}

# 3.1
module "nwp_consumer_ecmwf_live_ecs_task" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/ecs_task?ref=205465e"

  ecs-task_name               = "nwp-consumer-ecmwf-india"
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
    { "name" : "ECMWF_AWS_REGION", "value": "eu-west-1" },
    { "name" : "ECMWF_AWS_S3_BUCKET", "value" : "ocf-ecmwf-production" },
    { "name" : "LOGLEVEL", "value" : "DEBUG" },
    { "name" : "ECMWF_AREA", "value" : "nw-india" },
  ]
  container-secret_vars = ["ECMWF_AWS_ACCESS_KEY", "ECMWF_AWS_ACCESS_SECRET"]
  container-tag         = var.version-nwp
  container-name        = "openclimatefix/nwp-consumer"
  container-command     = [
    "download",
    "--source=ecmwf-s3",
    "--sink=s3",
    "--rdir=ecmwf/raw",
    "--zdir=ecmwf/data",
    "--create-latest"
  ]
}


# 3.2
module "ruvnl_consumer_ecs" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/ecs_task?ref=205465e"

  ecs-task_name               = "runvl-consumer"
  ecs-task_type               = "consumer"
  ecs-task_execution_role_arn = module.ecs-cluster.ecs_task_execution_role_arn

  aws-region                    = var.region
  aws-environment               = local.environment
  aws-secretsmanager_secret_arn = module.postgres-rds.secret.arn

  s3-buckets = []

  ecs-task_size = {
    memory = 512
    cpu    = 256
  }

  container-env_vars = [
    { "name" : "AWS_REGION", "value" : var.region },
    { "name" : "LOGLEVEL", "value" : "DEBUG" },
  ]
  container-secret_vars = ["DB_URL"]
  container-tag         = var.version-runvl-consumer
  container-name        = "ruvnl_consumer_app"
  container-registry    = "openclimatefix"
  container-command     = [
    "--write-to-db",
  ]
}


# 3.3 - Forecast
module "forecast" {
  source = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/forecast_generic?ref=205465e"

  region      = var.region
  environment = local.environment
  app-name    = "forecast"
  ecs_config  = {
    docker_image   = "openclimatefix/india_forecast_app"
    docker_version = var.version-forecast
    memory_mb      = 2048
    cpu            = 1024
  }
  rds_config = {
    database_secret_arn             = module.postgres-rds.secret.arn
    database_secret_read_policy_arn = module.postgres-rds.secret-policy.arn
  }
  s3_nwp_bucket = {
    bucket_id              = module.s3-nwp-bucket.bucket_id
    bucket_read_policy_arn = module.s3-nwp-bucket.read_policy_arn
    datadir                = "ecmwf/data"
  }
  // this isnt really needed
  s3_ml_bucket = {
    bucket_id              = module.s3-nwp-bucket.bucket_id
    bucket_read_policy_arn = module.s3-nwp-bucket.read_policy_arn
  }
  loglevel      = "INFO"
  ecs-task_execution_role_arn = module.ecs-cluster.ecs_task_execution_role_arn
}


# 4.0
module "airflow" {
  source                    = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/airflow?ref=968dd92"
  aws-environment           = local.environment
  aws-region                = local.region
  aws-domain                = local.domain
  aws-vpc_id                = module.network.vpc_id
  aws-subnet_id             = module.network.public_subnet_ids[0]
  airflow-db-connection-url = "${module.postgres-rds.instance_connection_url}/airflow"
  docker-compose-version    = "0.0.11"
  ecs-subnet_id             = module.network.public_subnet_ids[0]
  ecs-security_group        = module.network.default_security_group_id
  aws-owner_id              = module.network.owner_id
  slack_api_conn            = var.apikey-slack
  dags_folder               = "india"
}

# 5.0
module "india-api" {
  source             = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/eb_app?ref=205465e"
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
  ]
  container-name = "india-api"
  container-tag  = var.version-india_api
  eb-app_name    = "india-api"
}

# 5.1
module "analysis_dashboard" {
  source             = "github.com/openclimatefix/ocf-infrastructure//terraform/modules/services/eb_app?ref=205465e"
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
  ]
  container-name = "uk-analysis-dashboard"
  container-tag  = var.analysis_dashboard_version
  container-registry = "ghcr.io/openclimatefix"
  container-port = 8501
  eb-app_name    = "analysis-dashboard"
  eb-instance_type = "t3.small"
  s3_nwp_bucket = {
    bucket_read_policy_arn = module.s3-nwp-bucket.read_policy_arn
  }
}

