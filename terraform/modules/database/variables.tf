
variable "environment" {
  description = "The Deployment environment"
}


variable "region" {
  description = "The AWS region"
}

variable "db_subnet_group" {
  description = "The subnet group where the RDS database will be launched"
}
