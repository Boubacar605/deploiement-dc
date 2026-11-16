# XeuySil — Déploiement (Livraison Continue)

Dépôt de déploiement de la plateforme **XeuySil** : mise en relation entre recruteurs et travailleurs journaliers au Sénégal.

## Présentation

Ce dépôt orchestre le déploiement de l'ensemble de la pile applicative via **Docker Compose**. Il récupère les images produites par les pipelines CI des dépôts `serveur-ic` et `client-ic`, puis déploie la stack complète derrière un proxy inverse Nginx.

## Architecture

```
                  ┌─────────┐
    Port 80 ─────►│  Nginx  │
                  └────┬────┘
                       │
          ┌────────────┼────────────┐
          │            │            │
    /api/* & /docs     │            /
          │            │            │
    ┌─────▼─────┐      │     ┌──────▼─────┐
    │  Serveur  │      │     │   Client   │
    │  (NestJS) │      │     │ (Expo Web) │
    │  :3000    │      │     │   :3000    │
    └─────┬─────┘      │     └────────────┘
          │            │
    ┌─────▼──────┐     │
    │ PostgreSQL │     │
    │  :5432     │     │
    └────────────┘     │
```

## Services déployés

| Service | Image | Rôle |
|---------|-------|------|
| **postgres** | PostgreSQL 16 Alpine | Base de données avec volume persistant |
| **serveur** | xeuysil/serveur | API NestJS (authentification, missions, candidatures, notifications, WhatsApp) |
| **client** | xeuysil/client | Interface web Expo (travailleurs, recruteurs, agents, administration) |
| **nginx** | Nginx Alpine | Proxy inverse — seul point d'accès (port 80) |

## Structure du dépôt

```
deploiement-dc/
├── docker-compose.yml          # Définition de la pile complète
├── .env.example                # Modèle de variables d'environnement
├── nginx/
│   ├── nginx.conf              # Configuration du proxy inverse
│   └── Dockerfile
├── scripts/
│   ├── verifier-sante.sh       # Vérification de santé des services
│   └── sauvegarder-bdd.sh      # Sauvegarde de la base de données
├── Jenkinsfile                 # Pipeline de livraison continue
└── README.md
```

## Déploiement

### Prérequis

- Docker (version 24 ou supérieure)
- Docker Compose (version 2 ou supérieure)
- Accès à Docker Hub pour récupérer les images

### Premier déploiement

```bash
# 1. Copier et remplir les variables d'environnement
cp .env.example .env
# Éditer .env avec les vraies valeurs (Supabase, WhatsApp, mot de passe PostgreSQL)

# 2. Lancer la pile
docker compose up -d

# 3. Vérifier que tout fonctionne
./scripts/verifier-sante.sh
```

### Mise à jour (rolling update)

```bash
# Récupérer les nouvelles images
docker compose pull serveur client

# Redéployer (seuls les services modifiés sont recréés)
docker compose up -d
```

### Pipeline Jenkins (CD)

Le pipeline Jenkins automatise le déploiement :

1. **Récupération des images** depuis Docker Hub
2. **Arrêt progressif** des anciens conteneurs
3. **Déploiement** avec `docker compose up -d`
4. **Vérification de santé** de chaque service
5. **Notification** du résultat

### Persistance des données

Le volume nommé `xeuysil_pgdata` assure la persistance des données PostgreSQL entre les redéploiements :

```bash
# Vérifier que le volume existe et contient des données
docker volume inspect xeuysil_pgdata

# Les données survivent à un redéploiement complet
docker compose down && docker compose up -d
# → Les données sont toujours présentes
```

### Vérification de santé

Chaque service expose un endpoint de santé vérifié automatiquement par Docker :

```bash
# Vérifier l'état de tous les services
docker compose ps

# Vérification manuelle via le script
./scripts/verifier-sante.sh
```

Les healthchecks configurés :
- **postgres** : `pg_isready` toutes les 10 secondes
- **serveur** : `GET /docs` toutes les 15 secondes
- **client** : `GET /health` toutes les 15 secondes

### Sauvegarde de la base de données

```bash
# Sauvegarde manuelle
./scripts/sauvegarder-bdd.sh

# Les sauvegardes sont stockées dans ./sauvegardes/
# Rétention automatique : 7 jours
```

## Variables d'environnement

Voir `.env.example` pour la liste complète. Les principales :

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | URL de connexion PostgreSQL (format Prisma) |
| `SUPABASE_URL` / `SUPABASE_SERVICE_ROLE_KEY` | Authentification Supabase |
| `WHATSAPP_ACCESS_TOKEN` | Jeton d'accès WhatsApp Business API |
| `DOCKER_REGISTRY` | Nom du registre Docker Hub |
| `IMAGE_TAG` | Tag des images à déployer |

## Équipe

| Membre | Responsabilité |
|--------|---------------|
| Boubacar NIANG | Déploiement et infrastructure |

## Licence

Projet universitaire — Master 2 SI-SR, UADB (2026-2027).
