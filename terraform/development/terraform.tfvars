
region      = "eu-west-1"
environment = "development"

/* module networking */
vpc_cidr             = "10.0.0.0/16"
public_subnets_cidr  = ["10.0.1.0/24"]                  //List of Public subnet cidr range
private_subnets_cidr = ["10.0.20.0/24", "10.0.21.0/24"] //List of private subnet cidr range

api_version      = "0.1.15"
nwp_version      = "1.0.10"
forecast_version = "0.0.47"
