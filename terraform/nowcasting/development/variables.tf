variable "region" {
  description = "The AWS region to use"
}

variable "environment" {
  description = "The Deployment environment"
}

//Networking
variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "The CIDR block for the private subnet"
}

variable "api_version" {
  description = "The API version"
}

variable "data_visualization_version" {
  description = "The Data Visualization version"
}

variable "forecast_version" {
  description = "The Forecast version"
}

variable "nwp_version" {
  description = "The NWP version"
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
  default = "0.0.2"
}

variable "internal_ui_version" {
   description = "The Internal UI version"
   default = "main"
}

variable "cloudflare_zone_id" {
  description = "The ZoneID of the nowcasting domain"
}

variable "metrics_version" {
  description = "The Metrics version"
  default = "0.0.2"
}

variable "auth_domain" {
  description = "The Auth domain that should be used"
  default = "not-set"
}

variable "auth_api_audience" {
  description = "The Auth API Audience that should be used"
  default = "not-set"
}

variable "national_forecast_version" {
  description = "The National Forecast version"
}

variable "sentry_dsn" {
  type = string
  description = "DNS for Sentry monitoring"
}

variable "forecast_pvnet_version" {
  description = "The Forecast PVnet 2.0 docker version"
}


variable "forecast_blend_version" {
  description = "The Forecast Blend docker version"
}
