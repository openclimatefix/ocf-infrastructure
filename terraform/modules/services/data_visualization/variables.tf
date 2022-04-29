
variable "environment" {
  description = "The Deployment environment"
}


variable "region" {
  description = "The AWS region"
}

variable "vpc_id" {
  description = "The id of the vpc where this application will run"
}


variable "subnets" {
  description = "List of subnets where this application will run"
  type        = list(any)
}
# the type is any, as the subnets are terraform resources

variable "iam-policy-rds-forecast-read-secret" {
  description = "IAM policy to be able to read the RDS secret"
}

variable "database_forecast_secret_url" {
  description = "Secret url that gives connection details to the database"
}

variable "iam-policy-rds-pv-read-secret" {
  description = "IAM policy to be able to read the RDS PV secret"
}

variable "database_pv_secret_url" {
  description = "Secret url that gives connection details to the PV database"
}

variable "api_url" {
  description = "API url where the data is pulled"
}

variable "docker_version" {
  description = "The version of the docker that should be used"
}

variable "iam-policy-s3-nwp-read" {
  description = "IAM policy to read to s3 bucket for NWP data"
}

variable "iam-policy-s3-sat-read" {
  description = "IAM policy to read to s3 bucket for Satellite data"
}