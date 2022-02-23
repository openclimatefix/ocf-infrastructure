terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "openclimatefix"

    workspaces {
      name = "nowcasting_infrastructure_development-eu-west-1"
    }
  }
}
