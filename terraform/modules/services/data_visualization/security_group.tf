# Add secruity group for data_visualization

resource "aws_security_group" "data_visualization-sg_data_visualization" {
  name        = "data_visualization-${var.environment}-sg_data_visualization"
  description = "data visualization security group to allow inbound/outbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port = "80"
    to_port   = "80"
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Environment = "${var.environment}"
  }
}
