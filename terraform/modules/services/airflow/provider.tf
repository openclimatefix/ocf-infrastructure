terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.1"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}