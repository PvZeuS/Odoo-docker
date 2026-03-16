resource "aws_instance" "vpn_gateway" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = var.key_name

  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.vpn_sg.id]

  tags = {
    Name = "vpn-gateway"
  }
}