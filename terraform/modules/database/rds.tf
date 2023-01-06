# RDS postgres database

resource "aws_db_instance" "db-forecast" {
  allocated_storage            = 10
  max_allocated_storage        = 100
  engine                       = "postgres"
  engine_version               = "14.4"
  instance_class               = "db.t3.small"
  name                         = "forecast${var.environment}"
  identifier                   = "forecast-${var.environment}"
  username                     = "main"
  password                     = random_password.db-forecast-password.result
  skip_final_snapshot          = true
  publicly_accessible          = false
  vpc_security_group_ids       = [aws_security_group.rds-postgres-sg.id]
  ca_cert_identifier           = "rds-ca-2019"
  backup_window                = "00:00-00:30"
  db_subnet_group_name         = var.db_subnet_group.name # update name with private/public
  auto_minor_version_upgrade   = true
  performance_insights_enabled = true

  tags = {
    Name        = "${var.environment}-rds"
    Environment = "var.environment"
  }

}


resource "aws_db_instance" "db-pv" {
  allocated_storage            = 10
  max_allocated_storage        = 100
  engine                       = "postgres"
  engine_version               = "14.4"
  instance_class               = "db.t3.micro"
  name                         = "pv${var.environment}"
  identifier                   = "pv-${var.environment}"
  username                     = "main"
  password                     = random_password.db-pv-password.result
  skip_final_snapshot          = true
  publicly_accessible          = false
  vpc_security_group_ids       = [aws_security_group.rds-postgres-sg.id]
  ca_cert_identifier           = "rds-ca-2019"
  backup_window                = "00:00-00:30"
  db_subnet_group_name         = var.db_subnet_group.name # update name with private/public
  auto_minor_version_upgrade   = true
  performance_insights_enabled = true
  allow_major_version_upgrade = true

  tags = {
    Name        = "${var.environment}-rds"
    Environment = "var.environment"
  }

}

  resource "aws_db_instance" "db-pvsite" {
  allocated_storage            = 10
  max_allocated_storage        = 100
  engine                       = "postgres"
  engine_version               = "14.4"
  instance_class               = "db.t3.small"
  name                         = "pvsite${var.environment}"
  identifier                   = "pvsite-${var.environment}"
  username                     = "main"
  password                     = random_password.db-pvsite-password.result
  skip_final_snapshot          = true
  publicly_accessible          = false
  vpc_security_group_ids       = [aws_security_group.rds-postgres-sg.id]
  ca_cert_identifier           = "rds-ca-2019"
  backup_window                = "00:00-00:30"
  db_subnet_group_name         = var.db_subnet_group.name # update name with private/public
  auto_minor_version_upgrade   = true
  performance_insights_enabled = true

  tags = {
    Name        = "${var.environment}-rds"
    Environment = "var.environment"
  }

}
