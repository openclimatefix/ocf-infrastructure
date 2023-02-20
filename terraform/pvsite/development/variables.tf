variable "region" {
  description = "The AWS region to use"
  type = string
}

variable "environment" {
  description = "The Deployment environment"
  type = string

  validation {
    condition     = contains(["development", "production"], var.environment)
    error_message = "Valid values for var: environment are (development, production)."
  }
}

//Networking
variable "public_subnets_cidr" {
  type        = list(string)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "The CIDR block for the private subnet"
}

variable "auth_domain" {
  description = "The Auth domain that should be used"
  default = "not-set"
}

variable "auth_api_audience" {
  description = "The Auth API Audience that should be used"
  default = "not-set"
}

variable "vpc_id" {
  type = string
  description = "The ID of the VPC to build the subnets upon"
}

variable "public_internet_gateway_id" {
  type = string
  description = "The ID of the public internet gateway to use"
}

variable "pvsite_api_version" {
  type = string
  description = "This gives the version of the PV Site API"
}

variable "pvsite_forecast_version" {
  type = string
  description = "The version of the PVSite forecaster to use"
}

variable "nwp_bucket_config" {
  type = object({
    bucket_id              = string
    bucket_read_policy_arn = string
  })
  description = <<EOT
    nwp_bucket_config = {
      bucket_id : "ID of the nwp S3 bucket"
      bucket_read_policy_arn : "ARN of the read policy on the nwp S3 bucket"
    }
  EOT
}
