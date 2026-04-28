# Architecture

## Vue d'ensemble

La plateforme de veille techno-cyber est basée sur une architecture Docker Compose avec les services suivants :

- **FreshRSS** : Agrégateur RSS
- **n8n** : Automatisation des workflows
- **changedetection.io** : Surveillance de pages web
- **Wallabag** : Sauvegarde et annotation d'articles
- **PostgreSQL** : Base de données partagée
- **Nginx** : Reverse proxy interne

## Diagramme

```
┌─────────────────────────────────────────────────────────────┐
│                    Réseau interne / VPN                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Nginx (127.0.0.1:80/443)                 │
│  freshrss.veille.local | n8n.veille.local                   │
│  changes.veille.local | wallabag.veille.local              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Docker Compose (veille_net)                │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │FreshRSS  │ │   n8n    │ │changedet.│ │ Wallabag │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
│       └──────────────────────────────────────────┘         │
│                        │                                    │
│                        ▼                                    │
│                   ┌──────────┐                              │
│                   │PostgreSQL│                              │
│                   └──────────┘                              │
└─────────────────────────────────────────────────────────────┘
```

## Services

### FreshRSS
- **Image** : freshrss/freshrss:latest
- **Port interne** : 80
- **Port exposé** : 8081 (dev) / 127.0.0.1:8081 (prod)
- **Volume** : ./data/freshrss
- **Base de données** : PostgreSQL
- **Rôle** : Agrégation des flux RSS

### n8n
- **Image** : n8nio/n8n:latest
- **Port interne** : 5678
- **Port exposé** : 5678 (dev) / 127.0.0.1:5678 (prod)
- **Volume** : ./data/n8n
- **Base de données** : PostgreSQL
- **Rôle** : Automatisation des workflows de veille

### changedetection.io
- **Image** : ghcr.io/dgtlmoon/changedetection.io:latest
- **Port interne** : 5000
- **Port exposé** : 5000 (dev) / 127.0.0.1:5000 (prod)
- **Volume** : ./data/changedetection
- **Rôle** : Surveillance de pages sans RSS

### Wallabag
- **Image** : wallabag/wallabag:latest
- **Port interne** : 80
- **Port exposé** : 8082 (dev) / 127.0.0.1:8082 (prod)
- **Volume** : ./data/wallabag
- **Base de données** : PostgreSQL
- **Rôle** : Sauvegarde et annotation d'articles

### PostgreSQL
- **Image** : postgres:16-alpine
- **Port interne** : 5432
- **Port exposé** : Aucun (réseau Docker uniquement)
- **Volume** : ./data/postgres
- **Rôle** : Base de données partagée

### Nginx
- **Installation** : Sur l'hôte (via apt)
- **Ports** : 80, 443
- **Configuration** : /etc/nginx/sites-available/
- **Rôle** : Reverse proxy interne

## Réseaux

### veille_net
- **Type** : bridge
- **Utilisation** : Communication entre les services Docker
- **Isolation** : Les services ne sont accessibles que via ce réseau

## Volumes

### data/freshrss
- Données FreshRSS (configuration, extensions, cache)

### data/n8n
- Workflows n8n, credentials, exécutions

### data/changedetection
- Watchlists, historique des changements

### data/wallabag
- Articles sauvegardés, configuration utilisateur

### data/postgres
- Données PostgreSQL (bases de données n8n, wallabag)

### data/backups
- Sauvegardes automatisées

## Sécurité

### Isolation
- Réseau Docker dédié
- PostgreSQL non exposé
- Services applicatifs exposés uniquement sur localhost en production

### Durcissement Docker
- `restart: unless-stopped`
- `security_opt: no-new-privileges:true`
- Healthchecks
- Volumes explicites

### Durcissement Linux
- Utilisateur dédié `veille`
- Firewall (UFW/nftables)
- SSH durci
- Mises à jour automatiques

## Flux de données

1. **Sources externes** → FreshRSS / changedetection.io
2. **FreshRSS / changedetection.io** → n8n (via API)
3. **n8n** → Traitement et filtrage
4. **n8n** → Email / Slack / Teams
5. **n8n** → Wallabag (archivage)
6. **Tous les services** → PostgreSQL

## Scalabilité

### Horizontale
- n8n peut être scalé (mode queue)
- PostgreSQL peut être remplacé par un cluster

### Verticale
- Augmentation des ressources CPU/RAM
- Optimisation des workflows n8n

## Maintenance

### Mises à jour
- `docker compose pull`
- `docker compose up -d`
- Sauvegardes avant mise à jour

### Sauvegardes
- Automatisées via `scripts/backup.sh`
- Conservation des 7 dernières
- Export vers stockage externe recommandé

### Monitoring
- Healthchecks Docker
- Logs centralisés
- Supervision recommandée
