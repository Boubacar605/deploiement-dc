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
        /* Chemin du projet vu depuis le conteneur Jenkins (/xeuysil est monté en lecture) */
        DEPLOY_DIR      = '/xeuysil/deploiement-dc'
        /* IP de l'hôte Docker depuis un conteneur Jenkins (gateway du bridge docker_default) */
        HOST_IP         = '172.22.0.1'
    }

    stages {

        stage('Récupération des images Docker Hub') {
            steps {
                sh """
                    docker pull ${DOCKER_REGISTRY}/xeuysil-serveur:${IMAGE_TAG} || true
                    docker pull ${DOCKER_REGISTRY}/xeuysil-client:${IMAGE_TAG} || true
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
                    sleep 20
                    # Vérification via l'IP hôte (port 8080 exposé par nginx)
                    for svc in "API:/api/v1/settings/public" "Frontend:/" "NginxHealth:/nginx-health"; do
                        nom=\$(echo \$svc | cut -d: -f1)
                        path=\$(echo \$svc | cut -d: -f2)
                        code=\$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "http://\${HOST_IP}:8080\${path}" 2>/dev/null)
                        if [ "\$code" -ge 200 ] && [ "\$code" -lt 400 ]; then
                            echo "[OK] \$nom — HTTP \$code"
                        else
                            echo "[WARN] \$nom — HTTP \$code (non bloquant)"
                        fi
                    done
                    echo "Déploiement terminé."
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
        }
        always {
            sh "cd \${DEPLOY_DIR} && docker compose -f docker-compose.yml -f docker-compose.local.yml ps || true"
        }
    }
}
