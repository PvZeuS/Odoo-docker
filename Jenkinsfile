pipeline {
    agent any

    environment {
        DEV_HOST = "18.224.94.247"
        STAGING_HOST = "18.219.33.101"
        PROD_HOST = "3.144.231.64"
        TARGET_DIR = "/opt/odoo"
        REPO_URL = "https://github.com/PvZeuS/Odoo-docker.git"
    }

    stages {

        stage('Select Environment') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'develop') {
                        env.TARGET_HOST = DEV_HOST
                        env.ENV_NAME = "DEV"
                    } 
                    else if (env.BRANCH_NAME == 'staging') {
                        env.TARGET_HOST = STAGING_HOST
                        env.ENV_NAME = "STAGING"
                    } 
                    else if (env.BRANCH_NAME == 'master') {
                        env.TARGET_HOST = PROD_HOST
                        env.ENV_NAME = "PROD"
                    } 
                    else {
                        error "Branch no soportada: ${env.BRANCH_NAME}"
                    }

                    echo "Deploy a ${env.ENV_NAME} → ${env.TARGET_HOST}"
                }
            }
        }

        stage('Approval PROD') {
            when {
                branch 'master'
            }
            steps {
                input message: '¿Deploy a PRODUCCIÓN?', ok: 'Deploy'
            }
        }

        stage('Deploy') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-odoo-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {

                    sh """
                    ssh -o StrictHostKeyChecking=no -i \$SSH_KEY \$SSH_USER@\$TARGET_HOST '
                        set -e

                        echo "===== DEPLOY ${env.ENV_NAME} ====="

                        # 1. Preparar carpeta
                        sudo mkdir -p ${TARGET_DIR}
                        sudo chown -R \$USER:\$USER ${TARGET_DIR}
                        cd ${TARGET_DIR}

                        # 2. Código fuente
                        if [ -d .git ]; then
                            echo "Actualizando repo..."
                            git fetch origin
                            git reset --hard origin/${env.BRANCH_NAME}
                        else
                            echo "Clonando repo..."
                            sudo rm -rf ${TARGET_DIR}/*
                            git clone --depth 1 --branch ${env.BRANCH_NAME} ${REPO_URL} .
                        fi

                        # 3. Verificar docker compose
                        docker compose version

                        # 4. Deploy
                        echo "Levantando contenedores..."
                        docker compose -f docker-compose.prod.yml down || true
                        docker compose -f docker-compose.prod.yml up -d --build

                        # 5. Esperar servicio
                        echo "Esperando Odoo..."
                        sleep 20

                        # 6. Healthcheck REAL
                        curl -f http://localhost:8069 || (echo "Odoo no responde" && exit 1)

                        # 7. Limpieza
                        docker system prune -f

                        echo "===== DEPLOY OK ====="
                    '
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Deploy exitoso "
        }
        failure {
            echo "Deploy falló "
        }
    }
}