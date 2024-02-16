# RDS postgres database

resource "aws_db_instance" "db-forecast" {
  allocated_storage            = 150
  max_allocated_storage        = 200
  engine                       = "postgres"
  engine_version               = var.engine_version
  instance_class               = "db.t3.medium"
  db_name                      = "forecast${var.environment}"
  identifier                   = "forecast-${var.environment}"
  username                     = "main"
  password                     = random_password.db-forecast-password.result
  skip_final_snapshot          = true
  publicly_accessible          = false
  vpc_security_group_ids       = [aws_security_group.rds-postgres-sg.id]
  ca_cert_identifier           = "rds-ca-2019"
  backup_window                = "00:00-00:30"
  backup_retention_period      = 7
  db_subnet_group_name         = var.db_subnet_group_name # update name with private/public
  auto_minor_version_upgrade   = true
  performance_insights_enabled = true
  allow_major_version_upgrade  = true
  storage_type                 = "gp3"
  parameter_group_name         = aws_db_parameter_group.parameter-group.name

  tags = {
    Name        = "${var.environment}-rds"
    Environment = "var.environment"
  }

}


resource "aws_db_parameter_group" "parameter-group" {
  name   = "forecast${var.environment}-parameter-group-${split(".",var.engine_version)[0]}"
  family = "postgres${split(".",var.engine_version)[0]}"

  lifecycle {
    create_before_destroy = true
  }

  parameter {
    name  = "random_page_cost"
    value = "1.1"
  }

}
