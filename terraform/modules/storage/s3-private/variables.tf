variable "environment" {
  description = "The Deployment environment"
  type = string
}

variable "region" {
  description = "The AWS region"
  type = string
}

variable "domain" {
  description = "The domain of the S3 bucket"
  type = string
}

variable "service_name" {
  description = "The name of the service for which the bucket supplies"
  type = string
}

variable "lifecycled_prefixes" {
  description = "The data-slash prefixes requiring lifecycles"
  type = list(string)
}
