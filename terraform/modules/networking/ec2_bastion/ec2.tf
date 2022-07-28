# https://www.middlewareinventory.com/blog/terraform-aws-ec2-user_data-example/

resource "aws_instance" "ec2-bastion" {
  ami           = "ami-005e54dee72cc1d00" # us-west-2
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2-ssh.id]
  user_data = "${file("user_data.sh")}"
  subnet_id = var.public_subnets_id
}

resource "aws_eip" "ip-bastion" {
  instance = aws_instance.ec2-bastion.id
  vpc      = true
}
