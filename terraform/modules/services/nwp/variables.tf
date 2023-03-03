locals {
  log_group_name = "/aws/ecs/consumer/${var.consumer-name}/"
}

variable "environment" {
  description = "The Deployment environment"
}

variable "region" {
  description = "The AWS region"
}

variable "iam-policy-s3-nwp-write" {
  description = "IAM policy to write to s3 bucket for NWP data"
}

variable "ecs-cluster" {
  description = "The ECS cluster"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet ids"
}

variable "docker_version" {
  description = "The version of the docker that should be used"
}


variable "database_secret" {
  description = "AWS secret that gives connection details to the database"
}

variable "iam-policy-rds-read-secret" {
  description = "IAM policy to be able to read the RDS secret"
}

variable "consumer-name" {
  description = "Name of the consumer"
}

variable "s3_config" {
  type = object({
    bucket_id = string
    savedir_raw = string
    savedir_data = string
  })
  description = <<EOT
    s3_config = {
      bucket_id : "ID of the nwp S3 bucket"
      savedir_raw : "Folder name for raw data save location"
      savedir_data : "Folder name for data data save location"
    }
  EOT
}
