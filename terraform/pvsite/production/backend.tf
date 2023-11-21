terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "openclimatefix"

    workspaces {
      name = "pvsite_infrastructure_production-eu-west-1"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.47.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = "eu-west-1"
}
