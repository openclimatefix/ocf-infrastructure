
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
  default = "vpc-006140dd0b5a12ba1"
}


variable "subnets" {
  description = "List of subnets where this application will run"
  type        = list(any)
  default = ["subnet-0c3a5f26667adb0c1"]
}
# the type is any, as the subnets are terraform resources





