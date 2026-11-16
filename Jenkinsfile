/* Pipeline de livraison continue — XeuySil (Docker Compose) */
pipeline {
    agent any

    parameters {
        string(name: 'DOCKER_REGISTRY', defaultValue: 'boubacar605', description: 'Registre Docker Hub')
        string(name: 'IMAGE_TAG',       defaultValue: 'latest',      description: 'Tag des images à déployer')
    }

    environment {
        DOCKER_REGISTRY = "${params.DOCKER_REGISTRY}"
        IMAGE_TAG       = "${params.IMAGE_TAG}"
        DEPLOY_DIR      = '/home/niang/Documents/Master-2/DevOps/Xeuysil_Project/deploiement-dc'
    }

    stages {

        stage('Récupération des images') {
            steps {
                sh """
                    cd \${DEPLOY_DIR}
                    docker compose pull serveur client || true
                """
            }
        }

        stage('Déploiement') {
            steps {
                sh """
                    cd \${DEPLOY_DIR}
                    docker compose -f docker-compose.yml -f docker-compose.local.yml up -d --remove-orphans
                """
            }
        }

        stage('Vérification de santé') {
            steps {
                sh """
                    sleep 15
                    cd \${DEPLOY_DIR}
                    chmod +x scripts/verifier-sante.sh
                    ./scripts/verifier-sante.sh
                """
            }
        }
    }

    post {
        success {
            echo 'Déploiement réussi. La pile XeuySil est opérationnelle.'
        }
        failure {
            echo 'Échec du déploiement.'
            sh "docker compose -f \${DEPLOY_DIR}/docker-compose.yml ps || true"
        }
        always {
            sh "docker compose -f \${DEPLOY_DIR}/docker-compose.yml ps || true"
        }
    }
}
