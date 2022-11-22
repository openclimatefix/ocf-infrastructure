
region      = "eu-west-1"
environment = "unittest"

/* module networking */
vpc_cidr             = "11.0.0.0/16"
public_subnets_cidr  = ["11.0.1.0/24"]                  //List of Public subnet cidr range
private_subnets_cidr = ["11.0.10.0/24", "11.0.11.0/24"] //List of private subnet cidr range

auth_api_audience = "nowcasting-dev.eu.auth0.com"
auth_domain       = "https://nowcasting-api-eu-auth0.com/"