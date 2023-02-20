output "public_subnet" {
  value = aws_subnet.public_subnet[0]
}

output "private_subnet_group" {
  value = aws_db_subnet_group.private_subnet_group
}
