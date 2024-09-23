variable region {
    type = string
    default = "ap-south-1"
    description = "AWS region"
}

variable version-nwp {
    type = string
    default = "0.5.1"
    description = "Container image tag of the NWP consumer to use: openclimatefix/nwp-consumer"
}

variable version-india_api {
    type = string
    default = "0.1.0"
    description = "Container image tag of the India API to use: openclimatefix/india-api"
}

variable apikey-slack {
    type = string
    default = "not-set"
    description = "Slack API key"
}

variable version-forecast {
    type = string
    default = "0.1.0"
    description = "Container image tag of the forecast to use: openclimatefix/forecast"
}

variable version-forecast-ad {
  type = string
  default = "0.1.0"
  description = "Container image tag of the forecast ad to use: openclimatefix/forecast"
}

variable version-runvl-consumer {
    type = string
    default = "0.0.1"
    description = "Container image tag of the runvl data consumer to use: openclimatefix/ruvnl_consumer_app"
}


variable "analysis_dashboard_version" {
    description = "The Analysis Dashboard version"
    default = "main"
}

variable "sentry_dsn" {
  type = string
  description = "DNS for Sentry monitoring"
  default = ""
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

variable satellite-consumer {
  type = string
  default = "0.0.1"
  description = "Container image tag of the satellite data consumer to use: openclimatefix/satip"
}
