#!/bin/bash
set -e

exec > /var/log/user-data.log 2>&1

echo "=== START JENKINS SETUP ==="

apt-get update -y
apt-get install -y docker.io git

systemctl enable docker
systemctl start docker

sleep 10

docker rm -f jenkins || true
docker volume create jenkins_home || true

# Crear carpeta para config
mkdir -p /opt/jenkins

# Crear config YAML
cat <<EOF > /opt/jenkins/jenkins.yaml
$(cat <<'INNER'
jenkins:
  systemMessage: "Jenkins automatizado con Terraform"
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: "admin"
          password: "admin"
  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false
INNER
)
EOF

# Plugins
cat <<EOF > /opt/jenkins/plugins.txt
git
workflow-aggregator
docker-workflow
configuration-as-code
EOF

docker run -d \
  --restart=always \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /opt/jenkins/jenkins.yaml:/var/jenkins_home/casc_configs/jenkins.yaml \
  -e CASC_JENKINS_CONFIG=/var/jenkins_home/casc_configs/jenkins.yaml \
  jenkins/jenkins:lts

echo "=== END JENKINS SETUP ==="