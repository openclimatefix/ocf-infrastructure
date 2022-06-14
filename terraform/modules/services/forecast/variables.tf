
variable "environment" {
  description = "The Deployment environment"
}


variable "region" {
  description = "The AWS region"
}


variable "iam-policy-s3-nwp-read" {
  description = "IAM policy to read to s3 bucket for NWP data"
}

variable "iam-policy-s3-sat-read" {
  description = "IAM policy to read to s3 bucket for Satellite data"
}

variable "iam-policy-s3-ml-read" {
  description = "IAM policy to read to s3 bucket for ML models"
}

variable "log-group-name" {
  description = "The log group name where log streams are saved"
  default     = "/aws/ecs/forecast/"
}


variable "ecs-cluster" {
  description = "The ECS cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Public subnet ids"
}

variable "iam-policy-rds-read-secret" {
  description = "IAM policy to be able to read the RDS secret for forecast database"
}

variable "iam-policy-rds-pv-read-secret" {
  description = "IAM policy to be able to read the RDS secret for the pv database"
}

variable "database_secret" {
  description = "AWS secret that gives connection details to the forecast database"
}

variable "pv_database_secret" {
  description = "AWS secret that gives connection details to the pv database"
}

variable "docker_version" {
  description = "The version of the docker that should be used"
}

variable "s3-sat-bucket" {
  description = "s3 satellite bucket"
}

variable "s3-nwp-bucket" {
  description = "s3 nwp bucket"
}

variable "s3-ml-bucket" {
  description = "s3 ml bucket"
}
