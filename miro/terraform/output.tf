

output "inventory" {
  value = templatefile("templates/inventory.ini", {
    jump = aws_instance.lb.public_ip
    lb = aws_instance.lb.private_dns
    app = aws_instance.app[*].private_dns
    db = aws_instance.db.private_dns
  })
}

output "run_script" {
  value = templatefile("templates/run.sh", {
    jump = aws_instance.lb.public_ip
  })
}