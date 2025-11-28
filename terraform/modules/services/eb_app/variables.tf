// Namespacing ------------------------------------------------------------
variable domain {
  type = string
  description = "Domain of the application"
}

// AWS configuration ------------------------------------------------------

variable aws-region {
  type = string
  description = "AWS region"
}

variable aws-environment {
  type = string
  description = "Deployment environment"
}

variable aws-vpc_id {
  type = string
  description = "ID of the VPC in which to run the EB app"
}

variable aws-subnet_id {
  type = string
  description = "Subnet ID on which to run the EB app"
}

// Container configuration ---------------------------------------------------

variable container-registry {
  type = string
  description = "Container registry where container resides"
  default = "ghcr.io/openclimatefix"
}

variable container-name {
  type = string
  description = "Container name"
}

variable container-tag {
  type = string
  description = "Container image tag"
  default = "latest"
}

variable container-env_vars {
  type = list(object({
      name = string
      value = string
  }))
  description = <<EOT
    container-env_vars = {
      name : "Name of the environment variable"
      value : "Value of the environment variable"
    }
    container-env_vars : "Environment variables to be set in the container"
  EOT
}

variable container-command {
  type = list(string)
  description = "Command to run in the container"
}

variable elb_ports {
  type = list
  description = "List of ports for listeners for the load balancer"
  default = ["80"]
}

variable container-port-mappings {
  type = list(object({
      host = string
      container = string
  }))
  description = <<EOT
    container-port-mappings = {
      container : "The port number within the container that's listening for connections"
      host : "The port number on your host machine where you want to receive traffic"
    }
    container-port-mappings : "Mapping of ports to and from container"
  EOT
  default = [{"host":"80", "container":"80"}]
}

// EB configuration --------------------------------------------------------

variable eb-app_name {
  type = string
  description = "Name of the EB app"
}

variable eb-instance_type {
  type = string
  description = "Instance Type of the EB app"
  default = "t3.small"
}

variable "s3_bucket" {
  type = list(object({
    bucket_read_policy_arn = string
  }))
  default = [{
    bucket_read_policy_arn = "not-set"
  }]
  description = <<EOT
    s3_nwp_bucket_info = {
      bucket_read_policy_arn : "ARNs of the read policies on the S3 buckets"
    }
  EOT
}

variable "max_ec2_count" {
    type = number
    description = "Maximum number of EC2 instances in the EB environment"
    default = 1
}

variable "min_ec2_count" {
    type = number
    description = "Minimum number of EC2 instances in the EB environment"
    default = 1
}

variable "elbscheme" {
  type = string
  description = "Either public or internal for the load balancer."
  default = "public"
}



