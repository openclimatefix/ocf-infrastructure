# Add secruity group for API

resource "aws_security_group" "sg" {
  name        = "${var.domain}-${var.aws-environment}-${var.eb-app_name}-sg"
  description = "API security group to allow inbound/outbound traffic"
  vpc_id      = var.aws-vpc_id

  tags = {
    Environment = var.aws-environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "basic" {

  security_group_id = aws_security_group.sg.id
  from_port = "80"
  to_port   = "80"
  ip_protocol  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "basic" {

  security_group_id = aws_security_group.sg.id
  from_port        = 0
  to_port          = 0
  protocol         = "-1"
  cidr_ipv4        = "0.0.0.0/0"
  cidr_ipv6        = "::/0"
}

resource "aws_vpc_security_group_ingress_rule" "allow_traffic_ipv4" {
  count = var.ingress_extra_port != -1 ? 1 : 0

  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.ingress_extra_port
  ip_protocol       = "tcp"
  to_port           = var.ingress_extra_port
}
