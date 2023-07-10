
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


variable "subnets" {
  description = "List of subnets where this application will run"
  type        = list(any)
}
# the type is any, as the subnets are terraform resources





