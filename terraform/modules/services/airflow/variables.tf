// AWS Configuration ----------------------------------------------------------

variable "aws-environment" {
  description = "The Deployment environment"
  default="testing"
}


variable "aws-region" {
  description = "The AWS region"
    default = "eu-west-1"
}

variable "aws-domain" {
  description = "The domain name for the airflow instance"
}

variable "aws-vpc_id" {
  description = "The id of the vpc where this application will run"
}

variable "aws-owner_id" {
  description = "The owner id of AWS account the airflow instnace is created under"
  type = string
}


variable "aws-subnet_id" {
  description = "Subnet id where this application will run"
  type        = string
}

// EB Environment Configuration -------------------------------------------------

variable "docker-compose-version" {
  description = "The version of this for ocf. This helps bump the docker compose file"
  type = string
}


variable "dags_folder" {
    type = string
    description = "The folder containing the desired dags"
    default = "uk"
}

variable container-env_vars {
  type = list(object({
      name = string
      value = string
  }))
  description = <<EOT
    container-env_vars = {
      name : "Name of the environment variable"
      value : "Value of the environment variable"
    }
    container-env_vars : "Environment variables to be set in the container"
  EOT
}

