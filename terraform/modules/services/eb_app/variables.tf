// Namespacing ------------------------------------------------------------
variable domain {
  type = string
  description = "Domain of the application"
}

// AWS configuration ------------------------------------------------------

variable aws-region {
  type = string
  description = "AWS region"
}

variable aws-environment {
  type = string
  description = "Deployment environment"
}

variable aws-vpc_id {
  type = string
  description = "ID of the VPC in which to run the EB app"
}

variable aws-subnet_id {
  type = string
  description = "Subnet ID on which to run the EB app"
}

// Container configuration ---------------------------------------------------

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

variable container-env_vars {
  type = list(object({
      name = string
      value = string
  }))
  description = <<EOT
    container-env_vars = {
      name : "Name of the environment variable"
      value : "Value of the environment variable"
    }
    container-env_vars : "Environment variables to be set in the container"
  EOT
}

variable container-command {
  type = list(string)
  description = "Command to run in the container"
}

variable container-port {
  type = number
  description = "Port on which the container listens"
  default = 80
}

// EB configuration --------------------------------------------------------

variable eb-app_name {
  type = string
  description = "Name of the EB app"
}

variable eb-instance_type {
  type = string
  description = "Instance Type of the EB app"
  default = "t3.small"
}
