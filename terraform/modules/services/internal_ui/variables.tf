variable "environment" {
  description = "The Deployment environment"
}

variable "region" {
  description = "The AWS region"
}

variable "eb_app_name" {
    type = string
    description = "Name of the Elastic Beanstalk application"
}

variable "networking_config" {
  type = object({
    vpc_id = string
    subnets = list(any)
  })
  description = <<EOT
    networking_config = {
      vpc_id : "The id of the vpc where this application will run"
      subnets : "List of subnets where this application will run"
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
    url     = string
    read_policy_arn = string
  })
  description = <<EOT
    docker_config_info = {
      url : "URL of the database connection"
      read_policy_arn : "ARN of the iam policy allowing reading of the connection secret"
    }
  EOT
}
