
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

variable "docker_version" {
  description = "The version of the docker that should be used"
}

variable "auth_domain" {
  description = "The Auth domain that should be used"
  default = "not-set"
}

variable "auth_api_audience" {
  description = "The Auth API Audience that should be used"
  default = "not-set"
}

variable n_history_days {
  description = "The number of days to load. 'yesterday' loads up to yesterday morning"
  default = "yesterday"
}
