variable "public_subnets_id" {
  description = "Id of Public subnet that the bastion host will sit on"
}

variable "region" {
  description = "The AWS region"
}

variable "vpc_id" {
  description = "The id of the vpc where this application will run"
}
