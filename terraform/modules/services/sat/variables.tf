
variable "environment" {
  description = "The Deployment environment"
}


variable "region" {
  description = "The AWS region"
}


variable "iam-policy-s3-sat-write" {
  description = "IAM policy to write to s3 bucket for Satellite data"
}

variable "log-group-name" {
  description = "The log group name where log streams are saved"
  default     = "/aws/ecs/consumer/sat/"
}


variable "s3-bucket" {
  description = "s3 Bucket for Satellite data to be saved to"
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
