#!/bin/bash
set -e

LOG="/var/log/odoo-bootstrap.log"
exec > >(tee -a $LOG) 2>&1

echo "==== START BOOTSTRAP ===="

export DEBIAN_FRONTEND=noninteractive

echo "Waiting for cloud-init..."
sleep 30

echo "Updating system..."
apt-get update -y
apt-get install -y ca-certificates curl gnupg git

echo "Installing Docker (official repo)..."

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Starting Docker..."
systemctl enable docker
systemctl start docker

echo "Adding ubuntu user to docker group..."
usermod -aG docker ubuntu

echo "Creating deploy directory..."
mkdir -p /opt/odoo
cd /opt/odoo

echo "Cloning repository..."
git clone https://github.com/PvZeuS/Odoo-docker.git .

echo "Starting containers..."
docker compose -f docker-compose.prod.yml up -d --build

echo "==== DEPLOY FINISHED ===="