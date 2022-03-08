variable "region" {
  description = "The AWS region to use"
}

variable "environment" {
  description = "The Deployment environment"
}

//Networking
variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "The CIDR block for the private subnet"
}

variable "api_version" {
  description = "The API version"
}

variable "forecast_version" {
  description = "The Forecast version"
}

variable "nwp_version" {
  description = "The NWP version"
}

variable "sat_version" {
  description = "The Satellite version"
}


variable "cloudflare_zone_id" {
  description = "The ZoneID of the nowcasting domain"
}
