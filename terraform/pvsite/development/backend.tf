terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "openclimatefix"

    workspaces {
      name = "pvsite_infrastructure_development-eu-west-1"
    }
  }
}
