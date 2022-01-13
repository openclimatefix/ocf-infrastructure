
region      = "eu-west-2"
environment = "development"

/* module networking */
vpc_cidr             = "10.0.0.0/16"
public_subnets_cidr  = ["10.0.1.0/24"]                  //List of Public subnet cidr range
private_subnets_cidr = ["10.0.10.0/24", "10.0.11.0/24"] //List of private subnet cidr range
