terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9.0"
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
