terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.47.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = var.region
   default_tags {
        tags = {
          environment = var.environment
        }
      }
}
