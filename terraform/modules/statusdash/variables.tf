
variable "environment" {
  description = "The Deployment environment"
}

variable "region" {
  description = "The AWS region"
}

variable "ecs-cluster" {
  description = "The ECS cluster"
}

variable "log-group-name" {
  description = "The log group name where log streams are saved"
  default     = "/aws/ecs/statusdash/"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Public subnet ids"
}
