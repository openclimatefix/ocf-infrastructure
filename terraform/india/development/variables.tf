variable region {
  type = string
  default = "ap-south-1"
  description = "AWS region"
}

variable "airflow_conn_slack_api_default" {
  type = string
  description = "The slack connection string for airflow"
  default = "not-set"
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