
variable "environment" {
  description = "The Deployment environment"
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "The CIDR block for the private subnet"
}

variable "region" {
  description = "The AWS region"
}

variable "availability_zones" {
  type        = list(string)
  description = "The az that the resources will be launched"
}

variable "vpc_id" {
  type = string
  description = "The ID of the VPC to build the subnets upon"
}

variable "public_internet_gateway_id" {
  type = string
  description = "The ID of the public internet gateway to use"
}

variable "domain" {
  type = string
  description = "The name of the domain in which to deploy the subnet"
}
