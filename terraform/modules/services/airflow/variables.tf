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


variable "aws-subnet_id" {
  description = "Subnet id where this application will run"
  type        = string
}

variable "aws-owner_id" {
  description = "The owner id of AWS account the airflow instnace is created under"
  type = string
}

// EB Environment Configuration -------------------------------------------------

variable "airflow-db-connection-url" {
  description = "The connection url to the database to store airflow metadata"
  type = string
}

variable "ecs-security_group" {
  description = "The security group for airflow ecs tasks"
  type = string
}

variable "ecs-subnet_id" {
  description = "The subnet on which to run airflow ecs tasks"
  type = string
}

variable "ecs-execution_role_arn" {
  description = "The role with which to execute ecs tasks"
  type = string
}

variable "ecs-task_role_arn" {
  description = "The role with which to run ecs tasks"
  type = string
}

variable "docker-compose-version" {
  description = "The version of this for ocf. This helps bump the docker compose file"
  type = string
}

variable "slack_api_conn" {
  type = string
  description = "The slack connection string for airflow"
  default = "not-set"
}

variable "dags_folder" {
    type = string
    description = "The folder containing the desired dags"
    default = "uk"
}


