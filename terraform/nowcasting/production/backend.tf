terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "openclimatefix"

    workspaces {
      name = "nowcasting_infrastructure_production-eu-west-1"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.47.0"
    }

    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 3.9.1"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = var.region
  default_tags {
        tags = {
          environment = local.environment
          domain = local.domain
        }
      }
}

variable "cloudflare_email" {
  description = "Email Address of the Cloudflare account"
}

variable "cloudflare_api_token" {
  description = "API Token of the Cloudflare account"
}

provider "cloudflare" {
  email = var.cloudflare_email
  api_token = var.cloudflare_api_token
}
