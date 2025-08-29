variable aws-region {
  type = string
  description = "AWS region"
}

variable aws-environment {
  type = string
  description = "Deployment environment"
}

variable app_name {
    type = string
    description = "The application name"
}

variable container-registry {
  type = string
  description = "Container registry where container resides"
  default = "ghcr.io/openclimatefix"
}

variable container-name {
  type = string
  description = "Container name"
}

variable container-tag {
  type = string
  description = "Container image tag"
  default = "latest"
}