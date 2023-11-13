
variable "environment" {
  description = "The Deployment environment"
  default="testing"
}


variable "region" {
  description = "The AWS region"
    default = "eu-west-1"
}

variable "vpc_id" {
  description = "The id of the vpc where this application will run"
}


variable "subnet_id" {
  description = "Subnet id where this application will run"
  type        = string
}

variable "db_url" {
  description = "The database url"
  type = string
}

variable "docker-compose-version" {
  description = "The version of this for ocf. This helps bump the docker compose file"
  type = string
}

variable "ecs_security_group" {
  description = "The security group for airflow ecs tasks"
  type = string
}

variable "ecs_subnet_id" {
  description = "The subnet on which to run airflow ecs tasks"
  type = string
}




