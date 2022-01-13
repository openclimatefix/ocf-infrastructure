

resource "aws_db_instance" "DB-forecast" {
  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "13.4"
  instance_class       = "db.t3.micro"
  name                 = "forecast${var.environment}"
  identifier           = "forecast-${var.environment}"
  username             = "main"
  password             = "${random_password.DB-forecast-password.result}"
  skip_final_snapshot  = true # TODO
  publicly_accessible = false

  # todo vpc
  db_subnet_group_name = "${var.db_subnet_group.id}"

}