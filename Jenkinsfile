pipeline {
    agent any

    environment {
        DEV_HOST = "IP_DEV"
        STAGING_HOST = "IP_STAGING"
        PROD_HOST = "3.142.219.110"
    }

    stages {

        stage('Select Environment') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'develop') {
                        env.TARGET_HOST = DEV_HOST
                        env.TARGET_DIR = "/opt/odoo-dev"
                    } 
                    else if (env.BRANCH_NAME == 'staging') {
                        env.TARGET_HOST = STAGING_HOST
                        env.TARGET_DIR = "/opt/odoo-staging"
                    } 
                    else if (env.BRANCH_NAME == 'main') {
                        env.TARGET_HOST = PROD_HOST
                        env.TARGET_DIR = "/opt/odoo"
                    } 
                    else {
                        error "Branch no soportada: ${env.BRANCH_NAME}"
                    }

                    echo "Deployando a ${env.TARGET_HOST} en ${env.TARGET_DIR}"
                }
            }
        }

        stage('Deploy Odoo') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-odoo-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {

                    sh '''
                    ssh -o StrictHostKeyChecking=no -i $SSH_KEY $SSH_USER@$TARGET_HOST << EOF

                    set -e

                    echo " DEPLOY EN ${TARGET_DIR}"

                    mkdir -p ${TARGET_DIR}
                    cd ${TARGET_DIR}

                    if [ ! -d ".git" ]; then
                        echo "Clonando repo..."
                        git clone https://github.com/PvZeuS/Odoo-docker.git .
                    else
                        echo "Actualizando repo..."
                        git fetch origin
                        git reset --hard origin/${BRANCH_NAME}
                    fi

                    echo "Docker deploy..."
                    docker compose -f docker-compose.prod.yml down || true
                    docker compose -f docker-compose.prod.yml up -d --build

                    docker system prune -f

                    echo "DEPLOY FINALIZADO"

                    EOF
                    '''
                }
            }
        }
    }
}