
variable "environment" {
  description = "The Deployment environment"
}


variable "region" {
  description = "The AWS region"
}


variable "log-group-name" {
  description = "The log group name where log streams are saved"
  default     = "/aws/ecs/metrics/"
}


variable "ecs-cluster" {
  description = "The ECS cluster"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet ids"
}

variable "database_secret" {
  description = "AWS secret that gives connection details to the database"
}

variable "iam-policy-rds-read-secret" {
  description = "IAM policy to be able to read the RDS secret"
}

variable "docker_version" {
  description = "The version of the docker that should be used"
  default = "0.0.2"
}
