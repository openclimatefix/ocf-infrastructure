
variable "environment" {
  description = "The Deployment environment"
}

variable "region" {
  description = "The AWS region"
  default     = "eu-west-1"
}

variable "db_subnet_group_name" {
  description = "The subnet group name where the RDS database will be launched"
}

variable "vpc_id" {
  description = "The id of the vpc where this application will run"
}

variable "engine_version" {
  description = "The version of the postgres database"
  type = string
  default     = "16.3"
}