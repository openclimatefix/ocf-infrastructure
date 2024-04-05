terraform {

    backend "remote" {
        hostname = "app.terraform.io"
        organization = "openclimatefix"

        workspaces {
            name = "india_infrastructure_production-ap-south-1"
        }
    }

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }

        cloudflare = {
            source = "cloudflare/cloudflare"
            version = "~> 4.0"
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
