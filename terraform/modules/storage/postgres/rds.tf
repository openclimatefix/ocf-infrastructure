# RDS postgres database

resource "aws_db_instance" "postgres-db" {
  allocated_storage            = 25
  max_allocated_storage        = 200
  engine                       = "postgres"
  engine_version               = var.engine_version
  instance_class               = var.rds_instance_class
  db_name                      = "${var.db_name}${var.environment}"
  identifier                   = "${var.db_name}-${var.environment}"
  username                     = "main"
  password                     = random_password.db-password.result
  skip_final_snapshot          = true
  publicly_accessible          = false
  vpc_security_group_ids       = [aws_security_group.rds-postgres-sg.id]
  ca_cert_identifier           = "rds-ca-rsa2048-g1"
  backup_window                = "00:00-00:30"
  backup_retention_period      = 7
  db_subnet_group_name         = var.db_subnet_group_name
  auto_minor_version_upgrade   = true
  performance_insights_enabled = true
  allow_major_version_upgrade  = var.allow_major_version_upgrade
  storage_type                 = "gp3"
  parameter_group_name         = aws_db_parameter_group.parameter-group.name

  tags = {
    Name        = "${var.environment}-rds"
    Environment = "var.environment"
  }

}

resource "aws_db_parameter_group" "parameter-group" {
  name   = "${var.db_name}-${var.environment}-parameter-group-${split(".",var.engine_version)[0]}"
  family = "postgres${split(".",var.engine_version)[0]}"

  lifecycle {
    create_before_destroy = true
  }

  parameter {
    name  = "random_page_cost"
    value = "1.1"
  }

}
