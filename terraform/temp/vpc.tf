resource "aws_vpc" "odoo_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "odoo-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.odoo_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "vpn-public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.odoo_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "odoo-private-subnet"
  }
}