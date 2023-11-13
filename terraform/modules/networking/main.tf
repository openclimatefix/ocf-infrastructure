locals {
  prefix = "${var.domain}-${var.environment}"

  // Access the A.B part of the CIDR
  ab = regex("^(\\d+.\\d+).", var.vpc_cidr)[0]
}

// VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    name        = "${local.prefix}-vpc"
  }
}

// Internet gateway for the VPC
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    name        = "${local.prefix}-igw"
  }
}

// Elastic IP for the NAT
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.ig]
}

// NAT gateway on first public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    name = "nat"
  }
}

// Create the desired number of public subnets
resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = var.num_public_subnets
  cidr_block              = "${local.ab}.${count.index + 1}.0/24"
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    name = "${local.prefix}-${element(var.availability_zones, count.index)}-public-subnet"
  }
}

moved {
  from = aws_subnet.public_subnet[0]
  to = aws_subnet.public_subnets[0]
}

// Create the desired number of private subnets
resource "aws_subnet" "private_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = var.num_private_subnets
  cidr_block              = "${local.ab}.${count.index + 20}.0/24"
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = {
    name = "${local.prefix}-${element(var.availability_zones, count.index)}-private-subnet"
  }
}

moved {
  from = aws_subnet.private_subnet[0]
  to = aws_subnet.private_subnets[0]
}
moved {
  from = aws_subnet.private_subnet[1]
  to = aws_subnet.private_subnets[1]
}

// Create a subnet group from the private subnets
resource "aws_db_subnet_group" "private_subnet_group" {
  name        = "${local.prefix}-private-subnet-group"
  description = "Terraform private subnet group"
  subnet_ids = [
    for subnet in aws_subnet.private_subnets : subnet.id
  ]
}

// Rounting table for the private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    name = "${local.prefix}-private-route-table"
  }
}

// Routing table for the public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    name = "${local.prefix}-public-route-table"
  }
}

// Create routes to internet.
// * Public subnet -> internet gateway
// * Private subnet -> NAT gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

// Add the routes to the route tables
resource "aws_route_table_association" "public" {
  count = var.num_public_subnets
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count = var.num_private_subnets
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

// VPC default security group
resource "aws_security_group" "default" {
  name        = "${local.prefix}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
}
