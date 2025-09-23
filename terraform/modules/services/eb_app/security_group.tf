# Add secruity group for API

resource "aws_security_group" "sg" {
  name        = "${var.domain}-${var.aws-environment}-${var.eb-app_name}-sg"
  description = "API security group to allow inbound/outbound traffic"
  vpc_id      = var.aws-vpc_id

  ingress {
    from_port = "80"
    to_port   = "80"
    protocol  = "tcp"
    self      = true
  }

  # TODO tidy this up, as its only needed for Data Platform
  # 
  ingress {
    from_port        = "50051"
    to_port          = "50051"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "tcp"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Environment = var.aws-environment
  }
}
