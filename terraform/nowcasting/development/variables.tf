variable "region" {
  description = "The AWS region to use"
  default     = "eu-west-1"
}

//Networking
variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "api_version" {
  description = "The API version"
}

variable "internal_ui_version" {
  description = "The Internal UI version"
  default     = "main"
}

variable "cloudflare_zone_id" {
  description = "The ZoneID of the nowcasting domain"
}

variable "auth_domain" {
  description = "The Auth domain that should be used"
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

variable "auth_api_audience" {
  description = "The Auth API Audience that should be used"
  default     = "not-set"
}

variable "sentry_dsn" {
  type        = string
  description = "DNS for Sentry monitoring"
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

variable "sentry_dsn_api" {
  type        = string
  description = "The Sentry DSN for all backend components"
  default     = ""
}

variable "airflow_url" {
    description = "The URL for the Airflow instance"
    default     = "not-set"
}

variable "open_quartz_solar" {
  type = string
  description = "Docker version for the open quartz solar API"
  default = "api-v1"
}


variable "data_platform_api_version" {
  type = string
  description = "Docker verions for the data platformapi
  default = "update-build-location"
}