terraform {
  # TODO move to terraform cloud #28
  backend "s3" {
    encrypt = true
    bucket  = "nowcasting-terraform"
    key     = "terraform.tfstate"
    region  = "eu-west-2"
  }
}
