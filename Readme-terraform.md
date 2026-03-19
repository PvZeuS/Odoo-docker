Z📄 README – Infraestructura Odoo con Terraform en AWS
📌 Descripción

Este proyecto implementa la infraestructura base en AWS para desplegar Odoo utilizando Terraform.

El objetivo es crear una instancia EC2 completamente preparada para CI/CD, donde:

Terraform gestiona la infraestructura

La instancia se configura automáticamente con user_data

Jenkins realizará el despliegue de la aplicación (fuera de este módulo)

🏗 Arquitectura
Terraform
   ↓
AWS EC2 (Ubuntu 22.04)
   ↓
user_data.sh
   ↓
Docker instalado
   ↓
/opt/odoo listo
⚙️ Prerrequisitos

Antes de ejecutar Terraform, necesitas:

Cuenta en AWS

AWS CLI v2 instalado

Terraform instalado

Llave SSH (.pem)

🔐 Configuración de AWS CLI
1. Instalar AWS CLI v2

En Linux:

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

Verificar:

aws --version
👤 Creación de usuario IAM

Para usar Terraform necesitas credenciales de AWS.

⚠️ Nota importante

El usuario IAM se crea en:

👉 Consola AWS
→ IAM
→ Users

(Si no recuerdas dónde lo creaste, está ahí)

Pasos:

Ir a IAM → Users

Click en Create User

Nombre: terraform-user

Habilitar:

✔ Access key (programmatic access)
Permisos

Para pruebas puedes usar:

AdministratorAccess

⚠️ En producción se recomienda permisos más restrictivos.

Obtener credenciales

Después de crear el usuario:

Access Key ID
Secret Access Key
🔑 Configurar AWS CLI

Ejecutar:

aws configure

Ingresar:

AWS Access Key ID: XXXXX
AWS Secret Access Key: XXXXX
Region: us-east-1 (o tu región)
Output format: json

Esto crea:

~/.aws/credentials
📦 Estructura del proyecto
terraform/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── user_data.sh
🚀 Configuración de Terraform
1. Inicializar
terraform init
2. Planificar
terraform plan
3. Aplicar
terraform apply
🖥 Recursos creados

EC2 (Ubuntu 22.04)

Security Group:

SSH (22)

Odoo (8069)

📤 Outputs

Terraform expone:

output "public_ip" {
  value = aws_instance.test_ec2.public_ip
}

Obtener IP:

terraform output public_ip
⚙️ user_data.sh

Este script se ejecuta automáticamente al crear la instancia.

Funcionalidad:

Actualiza el sistema

Instala Docker y Docker Compose

Habilita el servicio Docker

Crea directorio /opt/odoo

Ejemplo:
#!/bin/bash

apt update -y
apt install -y docker.io docker-compose git

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

mkdir -p /opt/odoo
🔐 Acceso a la instancia
ssh -i tu-key.pem ubuntu@<PUBLIC_IP>
🧪 Verificación

Dentro de la EC2:

docker --version
ls /opt/odoo
🧼 Limpieza

Para eliminar la infraestructura:

terraform destroy
⚠️ Consideraciones

No se despliega Odoo automáticamente (lo hará Jenkins)

No se configura dominio ni SSL

Uso orientado a entornos internos o VPN

📈 Próximos pasos

Integrar Jenkins para CI/CD

Automatizar despliegue de contenedores

Separar entornos (dev / staging / prod)

Integrar análisis de código (SonarQube)

🧠 Buenas prácticas

No hardcodear credenciales

Usar IAM con permisos mínimos

Separar infraestructura de aplicación

Mantener Terraform como fuente única de verdad