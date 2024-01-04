
variable "environment" {
  description = "The Deployment environment"
}


variable "region" {
  description = "The AWS region"
}


variable "log-group-name" {
  description = "The log group name where log streams are saved"
  default     = "/aws/ecs/consumer/pv/"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet ids"
}

variable "database_secret_forecast" {
  description = "AWS secret that gives connection details to the forecast database"
}

variable "iam-policy-rds-read-secret_forecast" {
  description = "IAM policy to be able to read the forecast RDS secret"
}

variable "docker_version" {
  description = "The version of the docker that should be used"
}

variable "docker_version_ss" {
  description = "The version of the docker that should be used for the solar sheffield pv consumer"
}


variable "pv_provider" {
  description = "The provider that this service uses. Can be pvoutput.org or solar_sheffield_passiv"
  default = "pvoutput.org"
}

variable "ecs-task_execution_role_arn" {
  description = "The arn of the ECS cluster task execution role"
  type = string
}