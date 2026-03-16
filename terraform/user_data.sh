#!/bin/bash

apt update
apt install -y docker.io docker-compose git

systemctl enable docker
systemctl start docker

mkdir -p /opt/odoo
cd /opt/odoo

git clone https://github.com/TU_USUARIO/Odoo-docker.git .

docker compose -f docker-compose.prod.yml up -d