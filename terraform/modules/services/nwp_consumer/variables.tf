// AWS configuration ------------------------------------------------------

variable aws-region {
  type = string
  description = "AWS region"
}

variable aws-environment {
  type = string
  description = "Deployment environment"
}

variable aws-secretsmanager_secret_name {
  type = string
  description = "Name of secret in secrets manager to access"
}

// S3 configuration -------------------------------------------------------

variable s3-buckets {
  type = list(object({
    id = string
    access_policy_arn = string
  }))
  description = <<EOT
      s3-buckets = {
      id : "Name of the bucket"
      access_policy_arn : "ARN of the read/write policy to apply to the bucket"
  }
  EOT
}

// Container configuration ---------------------------------------------------

variable container-registry {
  type = string
  description = "Container registry where container resides"
  default = "ghcr.io"
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

variable container-secret_vars {
  type = list(string)
  description = "List of keys to be mounted in the container env from secretsmanager secret"
}

variable container-command {
  type = list(string)
  description = "Command to run in the container"
}

// ECS configuration --------------------------------------------------------

variable ecs-task_name {
  type = string
  description = "Name of the ECS task"
}

variable ecs-task_type {
  type = string
  description = "Type of the ECS task"
  default = "task"
}

variable ecs-task_cpu {
  type = number
  description = "CPU units for the ECS task"
  default = 1024
}

variable ecs-task_memory {
  type = number
  description = "Memory units (MB) for the ECS task"
  default = 5012
}

