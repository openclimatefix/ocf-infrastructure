
variable "environment" {
  description = "The Deployment environment"
}


variable "region" {
  description = "The AWS region"
}

variable "vpc_id" {
  description = "The id of the vpc where this application will run"
}


variable "subnet_id" {
  description = "Subnet id where this application will run"
  type        = string
}
# the type is any, as the subnets are terraform resources

variable "iam-policy-rds-forecast-read-secret" {
  description = "IAM policy to be able to read the RDS secret"
}

variable "database_forecast_secret_url" {
  description = "Secret url that gives connection details to the database"
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

variable adjust_limit {
  description = "The maximum amount the API can adjust the forecast results by"
  default = 0.0
}

variable "sentry_dsn" {
  type = string
  description = "DNS for Sentry monitoring"
}