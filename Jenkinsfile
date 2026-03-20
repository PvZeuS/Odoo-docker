pipeline {
    agent any

    environment {
        DEV_HOST = "18.224.94.247"
        STAGING_HOST = "18.219.33.101"
        PROD_HOST = "3.144.231.64"
    }

    stages {

        stage('Select Environment') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'develop') {
                        env.TARGET_HOST = DEV_HOST
                        env.TARGET_DIR = "/opt/odoo-dev"
                        env.ENV_NAME = "DEV"
                    } 
                    else if (env.BRANCH_NAME == 'staging') {
                        env.TARGET_HOST = STAGING_HOST
                        env.TARGET_DIR = "/opt/odoo-staging"
                        env.ENV_NAME = "STAGING"
                    } 
                    else if (env.BRANCH_NAME == 'master') {
                        env.TARGET_HOST = PROD_HOST
                        env.TARGET_DIR = "/opt/odoo"
                        env.ENV_NAME = "PROD"
                    } 
                    else {
                        error "Branch no soportada: ${env.BRANCH_NAME}"
                    }

                    echo "${env.ENV_NAME} → ${env.TARGET_HOST}"
                }
            }
        }

        stage('Approval PROD') {
            when {
                branch 'master'
            }
            steps {
                input message: '¿Deploy a producción?', ok: 'Deploy'
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
                    ssh -o StrictHostKeyChecking=no -i \$SSH_KEY \$SSH_USER@\$TARGET_HOST "
                        set -e

                        echo 'DEPLOY ${env.ENV_NAME}'

                        mkdir -p ${env.TARGET_DIR}
                        cd ${env.TARGET_DIR}

                        if [ -d .git ]; then
                            echo 'Repo existe → actualizando'
                            git fetch origin
                            git reset --hard origin/${env.BRANCH_NAME}
                        else
                            echo 'Repo inválido → limpiando y clonando'
                            rm -rf ${env.TARGET_DIR}/*
                            git clone --depth 1 --branch ${env.BRANCH_NAME} https://github.com/PvZeuS/Odoo-docker.git .
                        fi

                        docker compose -f docker-compose.prod.yml down || true
                        docker compose -f docker-compose.prod.yml up -d --build

                        echo 'Esperando servicio...'
                        sleep 15

                        curl -f http://localhost:8069 || exit 1

                        docker system prune -f

                        echo 'DEPLOY OK'
                    "
                    """
                }
            }
        }
    }
}