variable "environment" {
  description = "The Deployment environment"
  default = "development"
  validation {
    condition = contains(["development", "production"], var.environment)
    error_message = "Environment must be either 'development' or 'production'."
  }
}

variable "vpc_cidr" {
  type = string
  description = "The IPv4 CIDR block of the VPC. Use ranges from http://www.faqs.org/rfcs/rfc1918.html."
  default = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "List of IPv4 CIDR blocks for each desired public subnet. Defaults to one subnet."
  default = ["10.0.1.0/24"]
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "List of IPv4 CIDR blocks for each desired private subnet. Defaults to two subnets."
  default = ["10.0.20.0/24", "10.0.21.0/24"]
}

variable "region" {
  description = "The AWS region"
  default = "eu-west-1"
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones within the VPC where resources will be provisioned"
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}
