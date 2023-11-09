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

variable ecs-task_size {

  type = object({
    cpu = number
    memory = number
  })

  description = <<EOT
    ecs-task_size = {
      cpu : "CPU units for the ECS task"
      memory : "Memory units (MB) for the ECS task"
    }
    ecs-task_size: "Size of the ECS task in terms of compute and memory"
  EOT

  default = {
    cpu = 1024
    memory = 5120
  }
  
  validation {
    condition = length(keys(var.ecs-task_size)) == 2
    error_message = "Variable ecs-task_size must have exactly two keys: cpu and memory."
  }
  // See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#data
  // for valid CPU and memory values.
  validation {
    condition = contains(["256", "512", "1024", "2048", "4096", "8192"], var.ecs-task_size.cpu)
    error_message = "CPU must be one of 256, 512, 1024, 2048, 4096, or 8192."
  }
  validation {
    // If the CPU is 256, the memory must be 0.5, 1, or 2 * 1024 MiB. 
    condition = var.ecs-task_size.cpu == "256" && contains(["512", "1024", "2048"], var.ecs-task_size.memory)
    error_message = "For CPU 256, memory must be one of 512, 1024, or 2048."
  }
  validation {
    // If the CPU is 512, the memory must be between 1 and 4 GiB, in 1 GiB increments.
    condition = var.ecs-task_size.cpu == "512" && contains(range(1024, 4096, 1024), var.ecs-task_size.memory)
    error_message = "Fo CPU 512, memory must be one of 1024, 2048, 3072, or 4096."
  }
  validation {
    // If the CPU is 1024, the memory must be between 2 and 8 GiB, in 1 GiB increments.
    condition = var.ecs-task_size.cpu == "1024" && contains(range(2048, 8192, 1024), var.ecs-task_size.memory)
    error_message = "For CPU 1024, memory must be one of 2048 and 8192 in 1024 increments."
  }
  validation {
    // If the CPU is 2048, the memory must be between 4 and 16 GiB, in 1 GiB increments.
    condition = var.ecs-task_size.cpu == "2048" && contains(range(4096, 16384, 1024), var.ecs-task_size.memory)
    error_message = "Memory must be between 4096 and 16384 in 1024 increments."
  }
  validation {
    // If the CPU is 4096, the memory must be between 8 and 30 GiB, in 1 GiB increments.
    condition = var.ecs-task_size.cpu == "4096" && contains(range(8192, 30720, 1024), var.ecs-task_size.memory)
    error_message = "Memory must be between 8192 and 30720 in 1024 increments."
  }
  validation {
    // If the CPU is 8192, the memory must be between 16 and 60 GiB, in 4 GiB increments.
    condition = var.ecs-task_size.cpu == "8192" && contains(range(16384, 61440, 4096), var.ecs-task_size.memory)
    error_message = "Memory must be between 16384 and 61440 in 4096 increments."
  }
}

variable ecs-task_cpu {
  type = number
  description = "CPU units for the ECS task"
  default = 1024
}

variable ecs-task_memory {
  type = number
  description = "Memory units (MB) for the ECS task"
  default = 5120
}

