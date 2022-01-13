
variable "environment" {
  description = "The Deployment environment"
}


variable "region" {
  description = "The AWS region"
}


variable "iam-policy-s3-nwp-write" {
  description = "IAM policy to write to s3 bucket for NWP data"
}

variable "log-group-name" {
  description = "The log group name where log streams are saved"
  default = "/aws/ecs/consumer/nwp/"
}


variable "s3-bucket" {
  description = "s3 Bucket for NWP data to be saved to"
}

variable "ecs-cluster" {
  description = "The ECS cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Public subnet ids"
}

