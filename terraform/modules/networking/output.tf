output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = [
    for subnet in aws_subnet.public_subnets : subnet.id
  ]
}

output "private_subnet_ids" {
  value = [
    for subnet in aws_subnet.private_subnets : subnet.id
  ]
}

output "private_subnet_group_name" {
  value = aws_db_subnet_group.private_subnet_group.name
}

output "default_security_group_id" {
  value = aws_security_group.default.id
}

output "vpc_region" {
  value = var.region
}
