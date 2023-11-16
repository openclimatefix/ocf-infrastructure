variable "name" {
  description = "The name of the ECS cluster"
}

variable "secretsmanager_arn" {
  description = "The ARN of the secrets manager instance (up to :secret: not inclusive)"
}
