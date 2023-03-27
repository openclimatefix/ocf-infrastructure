variable "environment" {
  type        = string
  description = "The Deployment environment"
}

variable "region" {
  type        = string
  description = "The AWS region"
}

variable "app-name" {
  type        = string
  description = "The name of the application"
}

variable "rds_config" {
  type = object({
    database_secret_arn             = string
    database_secret_read_policy_arn = string
  })
  description = <<EOT
    rds_config_info = {
      database_secret_arn : "ARN of the secret containing connection info for the database"
      database_secret_read_policy_arn : "ARN of the iam policy allowing reading of the connection secret"
    }
  EOT
}

variable "ecs_config" {
  type = object({
    docker_image   = string
    docker_version = string
    memory_mb = number
    cpu = number
  })
  description = <<EOT
    ecs_config_info = {
      docker_image : "Name of the docker image to use"
      docker_image_version : "Tag of the docker image to use"
      memory_mb : "The amount of RAM in MB to assign to the container"
      cpu : "The amount of CPU assign to the container"
    }
  EOT
}

variable "scheduler_config" {
  type = object({
    subnet_ids      = list(string)
    ecs_cluster_arn = string
    cron_expression = string
  })
  description = <<EOT
    scheduler_config_info = {
      subnet_ids : "List of strings specifying the public subnets to use"
      ecs_cluster_arn : "ARN of the ECS cluster to use"
      cron_expression : "CRON string defining the schedule of the task"
    }
  EOT
}

locals {
  log-group-name = "/aws/ecs/${var.app-name}/"
}
