variable "region" {
  description = "The AWS region to use"
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "api_version" {
  description = "The API version"
}

variable "cloudflare_zone_id" {
  description = "The ZoneID of the nowcasting domain"
}

variable "auth_domain" {
  description = "The Auth domain that should be used"
  default     = "not-set"
}

variable "auth_api_audience" {
  description = "The Auth API Audience that should be used"
  default     = "not-set"
}

variable "internal_ui_version" {
  description = "The Internal UI version"
  default     = "main"
}

variable "sentry_monitor_dsn_api" {
  type        = string
  description = "DSN for Sentry monitoring for the api"
}

variable "sentry_dsn" {
  type        = string
  description = "DNS for Sentry monitoring"
  default     = ""
}

variable "auth_dashboard_client_id" {
  description = "The Auth client id for the dashboard that should be used"
  default     = "not-set"
}

variable "pvsite_api_version" {
  type        = string
  description = "This gives the version of the PV Site API"
}

variable "airflow_conn_slack_api_default" {
  type        = string
  description = "The slack connection string for airflow"
  default     = "not-set"
}

