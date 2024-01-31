variable region {
  type = string
  default = "ap-south-1"
  description = "AWS region"
}

variable version-nwp {
  type = string
  default = "0.1.25"
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

variable version-runvl-consumer {
  type = string
  default = "0.0.1"
  description = "Container image tag of the forecast to use: openclimatefix/ruvnl_consumer_app"
}
