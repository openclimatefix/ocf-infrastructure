variable "environment" {
  description = "The Deployment environment"
}

variable "region" {
  description = "The AWS region"
}

variable "domain" {
    type = string
    description = "The domain of the application"
}

variable "eb_app_name" {
    type = string
    description = "Name of the Elastic Beanstalk application"
}

variable "networking_config" {
  type = object({
    vpc_id = string
    subnets = list(string)
  })
  description = <<EOT
    networking_config = {
      vpc_id : "The id of the vpc where this application will run"
      subnets : "List of subnets IDs where this application will run"
    }
  EOT
}

variable "docker_config" {
  type = object({
    image   = string
    version = string
  })
  description = <<EOT
    docker_config_info = {
      image : "Name of the docker image to use"
      version : "Version (tag) of the docker image to use"
    }
  EOT
}


variable "database_config" {
  type = object({
    secret     = any
    read_policy_arn = string
  })
  description = <<EOT
    docker_config_info = {
      secret : "Secret containing the database connection information"
      read_policy_arn : "ARN of the iam policy allowing reading of the connection secret"
    }
  EOT
}

variable "site_db_url" {
  description = "The URL of the site database"
}


variable "auth_config" {
  type = object({
    auth0_domain     = string
    auth0_client_id = string
  })
  description = <<EOT
    docker_config_info = {
      auth0_domain : "Auth0 Domain"
      auth0_client_id : "Auth0 Client id"
    }
  EOT
}

variable "show_pvnet_gsp_sum" {
  description = "If to use the pvnet gsp sum"
  default = "false"
}
