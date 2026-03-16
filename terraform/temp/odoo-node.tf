resource "aws_instance" "odoo_node" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id = aws_subnet.private_subnet.id

  tags = {
    Name = "odoo-node-1"
  }
}