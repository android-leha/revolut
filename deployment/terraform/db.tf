resource "aws_db_subnet_group" "revolut-db" {
  name = "revolut-db"
  subnet_ids = aws_subnet.revolut[*].id

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "revolut_db" {
  identifier = "revolut-db"
  allocated_storage = 20
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  name = "mydb"
  username = "test"
  password = "12345678"
  parameter_group_name = "default.mysql5.7"
  apply_immediately = true
  vpc_security_group_ids = [aws_security_group.revolut-cluster.id]
  db_subnet_group_name = aws_db_subnet_group.revolut-db.name
  skip_final_snapshot = true
  publicly_accessible = true

}