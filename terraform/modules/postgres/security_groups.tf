# Security groups for the database

resource "aws_security_group" "rds-postgres-sg" {
  name   = "${var.environment}-rds-sg"
  vpc_id = var.vpc_id
}

# Inbound Security rule
resource "aws_security_group_rule" "rds-inbound" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds-postgres-sg.id
}
