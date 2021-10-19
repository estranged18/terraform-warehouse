# ___________________________________RDS DB___________________________________
resource "aws_db_instance" "wrs_db" {
  allocated_storage      = 10
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  name                   = "${var.RDS_DB_NAME}"
  username               = "${var.RDS_USER}"
  password               = "${var.RDS_PASSWORD}"
  port                   = "${var.RDS_PORT}"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name        = "terraform-wrs-db"
    Environment = "${var.environment_tag}"
  }
}

resource "aws_db_subnet_group" "db_group" {
  name       = "db_group"
  subnet_ids = [aws_subnet.wrs_private_subnet1.id, aws_subnet.wrs_private_subnet2.id, aws_subnet.wrs_public_subnet.id]

  tags = {
    Name = "terraform-rds-subnet-group"
  } 
}