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

variable "s3_nwp_bucket" {
  type = object({
    bucket_id              = string
    bucket_read_policy_arn = string
    datadir = string
  })
  description = <<EOT
    s3_nwp_bucket_info = {
      bucket_id : "ID of the nwp S3 bucket"
      bucket_read_policy_arn : "ARN of the read policy on the nwp S3 bucket"
      datadir : "Name of the top-level folder in which the NWP data is saved"
    }
  EOT
}

variable "s3_satellite_bucket" {
  type = object({
    bucket_id              = string
    bucket_read_policy_arn = string
    datadir = string
  })
  default = {
    bucket_id              = "not-set"
    bucket_read_policy_arn = "not-set"
    datadir                = "not-set"
  }
  description = <<EOT
    s3_nwp_bucket_info = {
      bucket_id : "ID of the satellite S3 bucket"
      bucket_read_policy_arn : "ARN of the read policy on the satellite S3 bucket"
      datadir : "Name of the top-level folder in which the satellite data is saved"
    }
  EOT
}


variable "s3_ml_bucket" {
  type = object({
    bucket_id              = string
    bucket_read_policy_arn = string
  })
  description = <<EOT
    s3_ml_bucket_info = {
      bucket_id : "ID of the ml S3 bucket"
      bucket_read_policy_arn : "ARN of the read policy on the ml S3 bucket"
    }
  EOT
}

locals {
  log-group-name = "/aws/ecs/${var.app-name}/"
}

variable "loglevel" {
  type        = string
  description = "The log level"
  default     = "DEBUG"
}

variable "use_adjuster" {
  type        = string
  description = "Whether to use the adjuster"
  default     = "true"
}