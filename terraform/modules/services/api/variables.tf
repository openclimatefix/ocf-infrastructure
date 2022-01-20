
variable "environment" {
  description = "The Deployment environment"
}


variable "region" {
  description = "The AWS region"
}

variable "vpc_id" {
  description = "The id of the vpc where this application will run"
}


variable "subnets" {
  description = "List of subnets where this application will run"
  type        = list(any)
}

variable "iam-policy-rds-read-secret" {
  description = "IAM policy to be able to read the RDS secret"
}

variable "database_secret_url" {
  description = "Secret url that gives connection details to the database"
}

variable docker_version {
  description = "The version of the docker that should be used"
}
