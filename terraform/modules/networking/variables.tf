variable "region" {
  description = "The AWS region"
  default = "eu-west-1"
}

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
  validation {
    condition = can(regex("^((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)\\.?\\b){4}\\/\\d+$", var.vpc_cidr))
    error_message = "Must be a valid IPv4 address of the form A.B.C.D/E."
  }
}

variable "num_public_subnets" {
  type = number
  description = "Number of public subnets to create in the VPC. Only the first will have a NAT."
  default = 1
  validation {
    condition = var.num_public_subnets < 4
    error_message = "Can't create more public subnets than availability zones."
  }
}

variable "num_private_subnets" {
  type = number
  description = "Number of private subnets to create in the VPC"
  default = 2
  validation {
    condition = var.num_private_subnets < 4
    error_message = "Can't create more private subnets than availability zones."
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones within the VPC where resources will be provisioned"
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "domain" {
  type = string
  description = "The domain of the VPC"
  validation {
    condition = contains(["uk", "india"], var.domain)
    error_message = "Domain can only be one of 'uk' or 'india'."
  }
}
