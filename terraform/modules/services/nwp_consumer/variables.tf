
variable "aws_config" {
  type = object({
    region = string
    environment = string
    ecs_cluster = string
    public_subnet_ids = list(string)
    secretsmanaget_secret_name = string
  })
  description = <<EOT
    aws_config = {
      region : "AWS region"
      environment : "Deployment environment"
      ecs_cluster : "The ECS cluster name"
      public_subnet_ids : "List of public subnet ids"
      secretsmanaget_secret_name : "Name of secret in secrets manager to access"
    }
  EOT
}

variable "s3_config" {
  type = object({
    bucket_id = string
    bucket_write_policy = string
  })
  description = <<EOT
    s3_config = {
      bucket_id : "ID of the nwp S3 bucket"
      bucket_write_policy_arn : "IAM policy to write to the nwp S3 bucket"
    }
  EOT
}

variable "docker_config" {
  type = object({
    container_tag = string
    command = list(string)
    secret_vars = list(string)
    environment_vars = list(object({
      key = string
      value = string
    }))
  })
  description = <<EOT
    docker_config = {
      container_tag : "Docker image tag"
      command : "Command to run in the container"
      secret_name : "Name of the secret in secrets manager to access"
      secret_vars : "List of keys to be mounted from consumer secret in the container env"
      environment_vars : "List of environment variables to be set in the container"
      environment_vars = {
        key : "Name of the environment variable"
        value : "Value of the environment variable"
      }
    }
  EOT
}

variable app_name {
  description = "Name of the application"
}

