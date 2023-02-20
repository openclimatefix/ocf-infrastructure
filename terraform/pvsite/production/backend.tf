terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "openclimatefix"

    workspaces {
      name = "pvsite_infrastructure_production-eu-west-1"
    }
  }
}
