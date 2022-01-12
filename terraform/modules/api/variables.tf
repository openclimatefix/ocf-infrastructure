
variable "environment" {
  description = "The Deployment environment"
}


variable "region" {
  description = "The region to launch the bastion host"
}

variable "vpc_id" {
  description = "The id of the vpc where this application will run"
}


variable "subnets" {
  description = "List of subnets where this application will run"
  type        = list
}
