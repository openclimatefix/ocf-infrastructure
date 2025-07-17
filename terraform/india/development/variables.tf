variable "region" {
  type = string
  default = "ap-south-1"
  description = "AWS region"
}

variable "version-india_api" {
  type = string
  default = "0.1.0"
  description = "Container image tag of the India API to use: openclimatefix/india-api"
}

variable "apikey-slack" {
  type = string
  default = "not-set"
  description = "Slack API key"
}

variable "analysis_dashboard_version" {
   description = "The Analysis Dashboard version"
   default = "main"
}

variable "sentry_dsn" {
  type = string
  description = "DNS for Sentry monitoring"
}

variable "sentry_dsn_api" {
  type = string
  description = "DNS for Sentry monitoring"
  default=""
}

variable "auth_domain" {
  description = "The Auth domain that should be used"
  default = "not-set"
}

variable "auth_api_audience" {
  description = "The Auth API Audience that should be used"
  default = "not-set"
}

variable "airflow_auth_username" {
    description = "The Auth username for airflow that should be used"
    default     = "not-set"
}

variable "airflow_auth_password" {
    description = "The Auth username for airflow that should be used"
    default     = "not-set"
}

variable "auth_dashboard_client_id" {
  description = "The Auth client id for the dashboard that should be used"
  default     = "not-set"
}

variable "airflow_auth_username" {
    description = "The Auth username for airflow that should be used"
    default     = "not-set"
}

variable "airflow_auth_password" {
    description = "The Auth username for airflow that should be used"
    default     = "not-set"
}
