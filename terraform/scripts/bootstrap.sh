#!/bin/bash
set -e

LOG_FILE="/var/log/bootstrap.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "==== START BOOTSTRAP ===="

# Update system (idempotente)
if [ ! -f /var/log/system-updated ]; then
  apt-get update -y
  apt-get upgrade -y
  touch /var/log/system-updated
fi

# Install Docker
if ! command -v docker &> /dev/null; then
  apt-get install -y docker.io
  systemctl enable docker
  systemctl start docker
fi

# Add ubuntu user to docker group
usermod -aG docker ubuntu || true

# Wait for Docker daemon
for i in {1..30}; do
  if docker info > /dev/null 2>&1; then
    echo "Docker ready"
    break
  fi
  sleep 2
done

# Create base directory
mkdir -p /opt/odoo

echo "==== BOOTSTRAP FINISHED ===="