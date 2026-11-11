# XeuySil — Déploiement (Livraison Continue)

Dépôt de déploiement de la plateforme **XeuySil** : mise en relation entre recruteurs et travailleurs journaliers au Sénégal.

## Présentation

Ce dépôt orchestre le déploiement de l'ensemble de la pile applicative via **Docker Compose**. Il récupère les images produites par les pipelines CI des dépôts `serveur-ic` et `client-ic`, puis déploie la stack complète.

## Services déployés

| Service | Image | Port | Rôle |
|---------|-------|------|------|
| **postgres** | PostgreSQL 16 | 5432 | Base de données (volume persistant) |
| **redis** | Redis 7 | 6379 | Cache et files de tâches |
| **identity** | xeuysil/identity | 3001 | Service identité |
| **mission** | xeuysil/mission | 3002 | Service missions |
| **matching** | xeuysil/matching | 3003 | Service mise en relation |
| **notification** | xeuysil/notification | 3004 | Service notifications |
| **admin-web** | xeuysil/admin-web | 3000 | Console d'administration |
| **nginx** | Nginx | 80 | Passerelle d'accès (proxy inverse) |

## Structure attendue

```
deploiement-dc/
├── docker-compose.yml      # Définition de la pile complète
├── .env.example            # Modèle de variables d'environnement
├── nginx/
│   ├── nginx.conf          # Configuration du proxy inverse
│   └── Dockerfile
├── scripts/
│   ├── verifier-sante.sh   # Vérification de santé des services
│   └── sauvegarder-bdd.sh  # Sauvegarde de la base de données
├── Jenkinsfile
└── README.md
```

## Flux de déploiement (à venir)

Le pipeline Jenkins de déploiement sera configuré après validation des pipelines CI :

1. Récupération des dernières images depuis Docker Hub
2. Arrêt progressif des anciens conteneurs
3. Déploiement avec `docker compose up -d`
4. Vérification de santé de chaque service (`/health`)
5. Notification du résultat (succès ou échec)

Le redéploiement se fait **sans interruption de service** (rolling update).

## Prérequis

- Docker (version 24 ou supérieure)
- Docker Compose (version 2 ou supérieure)
- Accès à Docker Hub pour récupérer les images

## Équipe

| Membre | Responsabilité |
|--------|---------------|
| Boubacar NIANG | Déploiement et infrastructure |

## Licence

Projet universitaire — Master 2 SI-SR, UADB (2026-2027).
