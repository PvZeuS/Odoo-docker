# AMI Ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# -------------------------
# SECURITY GROUP JENKINS
# -------------------------
resource "aws_security_group" "jenkins_sg" {
  name = "jenkins-sg-dev"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # puedes restringir luego
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------
# SECURITY GROUP ODOO
# -------------------------
resource "aws_security_group" "odoo_sg" {
  name = "odoo-sg-dev"

  ingress {
    from_port   = 8069
    to_port     = 8069
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------
# JENKINS
# -------------------------
module "jenkins" {
  source = "../../modules/ec2"

  name              = "jenkins-dev"
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "t3.micro"
  key_name          = var.key_name
  user_data = file("../../scripts/jenkins.sh")
  security_group_id = aws_security_group.jenkins_sg.id
}

# -------------------------
# MULTI CLIENTES DINÁMICOS
# -------------------------
variable "clients" {
  default = ["cliente1"]
}

module "clients" {
  for_each = toset(var.clients)

  source = "../../modules/ec2"

  name              = "odoo-${each.key}-dev"
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.instance_type
  key_name          = var.key_name
  user_data         = "../../scripts/bootstrap.sh"
  security_group_id = aws_security_group.odoo_sg.id
}

# -------------------------
# OUTPUTS
# -------------------------
output "jenkins_ip" {
  value = module.jenkins.public_ip
}

output "clients_ip" {
  value = {
    for k, v in module.clients : k => v.public_ip
  }
}