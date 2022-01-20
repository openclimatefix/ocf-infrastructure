variable "region" {
  description = "The AWS region to use"
}

variable "environment" {
  description = "The Deployment environment"
}

//Networking
variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "The CIDR block for the private subnet"
}
