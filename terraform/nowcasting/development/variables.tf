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

variable "forecast_version" {
  description = "The Forecast version"
}

variable "nwp_version" {
  description = "The NWP version"
}

variable "nwp_ecmwf_version" {
  description = "The ECMWF NWP version"
  default="1.0.9"
}

variable "sat_version" {
  description = "The Satellite version"
}

variable "pv_version" {
  description = "The PV Consumer version"
}

variable "pv_ss_version" {
  description = "The PV Consumer version for solar sheffield"
}

variable "gsp_version" {
  description = "The GSP Consumer version"
  default     = "0.0.2"
}

variable "internal_ui_version" {
  description = "The Internal UI version"
  default     = "main"
}

variable "cloudflare_zone_id" {
  description = "The ZoneID of the nowcasting domain"
}

variable "metrics_version" {
  description = "The Metrics version"
  default     = "0.0.2"
}

variable "auth_domain" {
  description = "The Auth domain that should be used"
  default     = "not-set"
}

variable "auth_dashboard_client_id" {
  description = "The Auth client id for the dashboard that should be used"
  default     = "not-set"
}

variable "auth_api_audience" {
  description = "The Auth API Audience that should be used"
  default     = "not-set"
}

variable "national_forecast_version" {
  description = "The National Forecast version"
}

variable "sentry_dsn" {
  type        = string
  description = "DNS for Sentry monitoring"
}

variable "forecast_pvnet_version" {
  description = "The Forecast PVnet 2.0 docker version"
}


variable "forecast_blend_version" {
  description = "The Forecast Blend docker version"
}

variable "pvsite_api_version" {
  type        = string
  description = "This gives the version of the PV Site API"
}

variable "pvsite_forecast_version" {
  type        = string
  description = "The version of the PVSite forecaster to use"
}

variable "database_cleanup_version" {
  type        = string
  description = "The version of the database clean up to use"
}

variable "airflow_conn_slack_api_default" {
  type        = string
  description = "The slack connection string for airflow"
  default     = "not-set"
}

variable "forecast_pvnet_day_ahead_docker_version" {
  type        = string
  description = "The Forecast PVnet 2.0 day ahead docker version"
  default     = "not-set"
}

variable "sentry_dsn_api" {
  type        = string
  description = "The Sentry DSN for all backend components"
  default     = ""
}

variable "neso_forecast_consumer_version" {
  type        = string
  description = "The version of the neso forecast consumer"
  default     = "1.0.3"
}

variable "cloudcasting_app_version" {
  type        = string
  description = "The version of the cloucasting app forecast consumer"
  default     = "0.0.2"
}

variable "satellite_consumer_version" {
  type        = string
  description = "The version of the satellite consumer"
  default     = "0.0.2"
}
