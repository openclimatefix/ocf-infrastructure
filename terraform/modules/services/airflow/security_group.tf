# Add security group for API

resource "aws_security_group" "api-sg" {
  name        = "ocf-airflow-${var.environment}-sg"
  description = "OCF Airflow security group to allow inbound/outbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port = "80"
    to_port   = "80"
    protocol  = "tcp"
    self      = true
  }

   ingress {
    from_port = "8080"
    to_port   = "8080"
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
}
