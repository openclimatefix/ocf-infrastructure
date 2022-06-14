terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "openclimatefix"

    workspaces {
      name = "nowcasting_infrastructure_production-eu-west-1"
    }
  }
}
