// AWS configuration ------------------------------------------------------

variable aws-region {
  type = string
  description = "AWS region"
}

variable aws-environment {
  type = string
  description = "Deployment environment"
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

variable container-command {
  type = list(string)
  description = "Command to run in the container"
}

variable container-secret_vars {
  type = list(object({
    secret_policy_arn = string
    values=list(string)
  }))
  description = <<EOH
  ARN of the secretsmanager secret to pull environment variables from.
  The values will be set as (secret) environment variables in the container.
  For example {
  secret_policy_arn = 'arn:aws:iam::123456789012:policy/my-policy',
  values=['key1', 'key2'] }
  EOH
  default = []
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
    storage = number
  })

  description = <<EOT
    ecs-task_size = {
      cpu : "CPU units for the ECS task"
      memory : "Memory units (MB) for the ECS task"
      storage : "Ephemeral storage (GB) for the ECS task"
    }
    ecs-task_size: "Size of the ECS task in terms of compute, memory, and ephemeral storage."
  EOT

  default = {
    cpu = 1024
    memory = 5120
    storage = 21
  }
  
  validation {
    condition = length(keys(var.ecs-task_size)) == 3
    error_message = "Variable ecs-task_size must have exactly three keys: cpu, memory, and storage."
  }
  validation {
    condition = contains([256, 512, 1024, 2048, 4096, 8192], var.ecs-task_size.cpu)
    error_message = "CPU must be one of 256, 512, 1024, 2048, 4096, or 8192."
  }
  validation {
    // See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#data
    // for valid CPU and memory values.
    condition = (
      var.ecs-task_size.cpu == 256 ? contains([512, 1024, 2048], var.ecs-task_size.memory) :
      var.ecs-task_size.cpu == 512 ? contains(range(1024, 4096, 1024), var.ecs-task_size.memory) :
      var.ecs-task_size.cpu == 1024 ? contains(range(2048, 9216, 1024), var.ecs-task_size.memory) :
      var.ecs-task_size.cpu == 2048 ? contains(range(4096, 16384, 1024), var.ecs-task_size.memory) :
      var.ecs-task_size.cpu == 4096 ? contains(range(8192, 30720, 1024), var.ecs-task_size.memory) :
      var.ecs-task_size.cpu == 8192 ? contains(range(16384, 61440, 4096), var.ecs-task_size.memory) :
      true
    )
    error_message = "Invalid combination of CPU and memory."
  }
  validation {
    condition = var.ecs-task_size.storage >= 21
    error_message = "Storage must be at least 21."
  }
  validation {
    condition = var.ecs-task_size.storage <= 200
    error_message = "Storage must be at most 200."
  }
}

variable "ecs-task_execution_role_arn" {
  description = "The arn of the ECS cluster task execution role."
  type = string
}




