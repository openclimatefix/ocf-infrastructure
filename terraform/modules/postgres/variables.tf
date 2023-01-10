
variable "environment" {
  description = "The Deployment environment"
  type = string
}

variable "region" {
  description = "The AWS region"
  type = string
  default     = "eu-west-1"
}

variable "db_subnet_group" {
  description = "The subnet group where the RDS database will be launched"
}

variable "vpc_id" {
  description = "The id of the vpc where this application will run"
  type = string
}

variable "db_name" {
  description = "The name of the database"
  type = string
}

variable "allow_major_version_upgrade" {
  description = "Whether or not to allow major version upgrades on the postgres db"
  type = bool
  default = false
}

variable "rds_instance_class" {
  description = "The instance class of the RDS database"
  type = string

  validation {
    condition     = contains(["db.t3.small", "db.t3.micro"], var.rds_instance_class)
    error_message = "Valid values for var: rds_instance_class are (db.t3.small, db.t3.micro)."
  }
}
