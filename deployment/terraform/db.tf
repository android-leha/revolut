

resource "aws_db_subnet_group" "miro-db" {
  name = "miro-db"

  subnet_ids = aws_subnet.miro-db[*].id
}

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}

resource "aws_security_group" "miro-db" {
  name        = "miro-db-security-group"
  vpc_id      = aws_vpc.miro.id

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = aws_subnet.miro-app[*].cidr_block
  }

}

resource "aws_db_instance" "miro_db" {
  identifier = "miro-db"
  allocated_storage = 20
  storage_type = "gp2"
  engine = "postgres"
  engine_version = "12.3"
  instance_class = "db.t2.micro"
  name = "mydb"
  username = "postgres"
  password = random_password.password.result
  apply_immediately = true
  vpc_security_group_ids = [aws_security_group.miro-cluster.id]
  db_subnet_group_name = aws_db_subnet_group.miro-db.name
  skip_final_snapshot = true
  publicly_accessible = true

}