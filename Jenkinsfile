pipeline {
    agent any

    parameters {
        string(name: 'DOCKER_REGISTRY', defaultValue: 'xeuysil', description: 'Registre Docker Hub')
        string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Tag des images à déployer')
    }

    environment {
        DOCKER_REGISTRY = "${params.DOCKER_REGISTRY}"
        IMAGE_TAG = "${params.IMAGE_TAG}"
    }

    stages {
        stage('Récupération des images') {
            steps {
                sh '''
                    docker compose pull serveur client
                '''
            }
        }

        stage('Arrêt progressif') {
            steps {
                sh '''
                    docker compose down --timeout 30 || true
                '''
            }
        }

        stage('Déploiement') {
            steps {
                sh '''
                    docker compose up -d --build --remove-orphans
                '''
            }
        }

        stage('Vérification de santé') {
            steps {
                sh '''
                    chmod +x scripts/verifier-sante.sh
                    ./scripts/verifier-sante.sh
                '''
            }
        }
    }

    post {
        success {
            echo 'Déploiement réussi. La pile XeuySil est opérationnelle.'
        }
        failure {
            echo 'Échec du déploiement. Vérifiez les journaux des conteneurs.'
            sh 'docker compose logs --tail=50'
        }
        always {
            sh 'docker compose ps'
        }
    }
}
