terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.71"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = "eu-west-1"
}
