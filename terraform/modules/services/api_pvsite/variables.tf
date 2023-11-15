variable "environment" {
  description = "The Deployment environment"
}

variable "region" {
  description = "The AWS region"
}

variable "app_name" {
  description = "The name of the application"
  default     = "api"
}

variable "vpc_id" {
  description = "The id of the vpc where this application will run"
}

variable "subnet_id" {
  description = "ID of the subnet where this application will run"
  type        = string
}

variable "docker_version" {
  description = "The version of the docker that should be used"
}

variable "domain" {
  description = "The domain/name of the api"
}

variable "database_secret_url" {
  type = string
  description = "URL of the database connection"
}

variable "database_secret_read_policy_arn" {
  type = string
  description = "ARN of the iam policy allowing reading of the connection secret"
}

variable "sentry_dsn" {
  type = string
  description = "DNS for Sentry monitoring"
}

variable "auth_domain" {
  type = string
  description = "Authorization domain"
}

variable "auth_api_audience" {
  type = string
  description = "Authorization API audience"
}
