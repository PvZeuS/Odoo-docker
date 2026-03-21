#!/bin/bash
set -e

LOG_FILE="/var/log/bootstrap.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "==== START BOOTSTRAP ===="

# -------------------------
# Update system (once)
# -------------------------
if [ ! -f /var/log/system-updated ]; then
  apt-get update -y
  apt-get upgrade -y
  touch /var/log/system-updated
fi

# -------------------------
# Install base packages
# -------------------------
apt-get install -y ca-certificates curl gnupg lsb-release git

# -------------------------
# Install Docker (official)
# -------------------------
if ! command -v docker &> /dev/null; then
  echo "Installing Docker CE..."

  install -m 0755 -d /etc/apt/keyrings

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu jammy stable" \
  > /etc/apt/sources.list.d/docker.list

  apt-get update -y

  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# -------------------------
# Start Docker properly
# -------------------------
systemctl daemon-reexec || true
systemctl enable docker
systemctl start docker

# -------------------------
# Wait until Docker is ready
# -------------------------
echo "Waiting for Docker..."
for i in {1..30}; do
  if docker info > /dev/null 2>&1; then
    echo "Docker is ready"
    break
  fi
  sleep 2
done

# -------------------------
# Permissions
# -------------------------
usermod -aG docker ubuntu || true

# sudo sin password (CI/CD)
if ! grep -q "ubuntu ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
  echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# -------------------------
# App directory
# -------------------------
mkdir -p /opt/odoo
chown -R ubuntu:ubuntu /opt/odoo

echo "==== BOOTSTRAP FINISHED ===="