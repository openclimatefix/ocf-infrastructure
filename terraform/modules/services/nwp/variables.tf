
variable "environment" {
  description = "The Deployment environment"
}


variable "region" {
  description = "The AWS region"
}


variable "iam-policy-s3-nwp-write" {
  description = "IAM policy to write to s3 bucket for NWP data"
}


variable "s3-bucket" {
  default = "s3 Bucket for NWP data to be saved to"
}

