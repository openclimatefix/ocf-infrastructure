# https://www.middlewareinventory.com/blog/terraform-aws-ec2-user_data-example/

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")
}

data "aws_ami" "ami_latest" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "ec2-bastion" {
#  ami           = data.aws_ami.ami_latest.id
  ami = "ami-0069d66985b09d219"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2-ssh.id]
  user_data = data.template_file.user_data.rendered
  subnet_id = var.public_subnets_id
  associate_public_ip_address = true

  # temp
#  key_name = "PD_2022_06_14"

  tags = {
    Name = "ec2-bastion"
  }
}

resource "aws_eip" "ip-bastion" {
  instance = aws_instance.ec2-bastion.id
  vpc      = true
}
