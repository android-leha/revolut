

resource "aws_db_instance" "revolut_db" {
    allocated_storage    = 1
    storage_type         = "gp2"
    engine               = "mysql"
    engine_version       = "5.7"
    instance_class       = "db.t2.micro"
    name                 = "mydb"
    username             = "test"
    password             = "test"
    parameter_group_name = "default.mysql5.7"
}