# Mise à jour

## Mise à jour de la stack

### Script de mise à jour

```bash
cd /opt/veille-techno-cyber-interne
make update
# ou
sudo -u veille bash scripts/update.sh
```

Le script :
- Crée une sauvegarde avant mise à jour
- Pull les nouvelles images Docker
- Redémarre la stack
- Propose de nettoyer les anciennes images
- Vérifie la santé après mise à jour

### Mise à jour manuelle

```bash
# Sauvegarde
sudo -u veille bash scripts/backup.sh

# Pull des nouvelles images
sudo -u veille docker compose pull

# Redémarrage
sudo -u veille docker compose up -d

# Nettoyage des anciennes images
docker image prune -f

# Vérification
sudo -u veille bash scripts/check-health.sh
```

## Mise à jour des services individuels

### FreshRSS

```bash
sudo -u veille docker compose pull freshrss
sudo -u veille docker compose up -d freshrss
```

### n8n

```bash
sudo -u veille docker compose pull n8n
sudo -u veille docker compose up -d n8n
```

### changedetection.io

```bash
sudo -u veille docker compose pull changedetection
sudo -u veille docker compose up -d changedetection
```

### Wallabag

```bash
sudo -u veille docker compose pull wallabag
sudo -u veille docker compose up -d wallabag
```

### PostgreSQL

```bash
sudo -u veille docker compose pull postgres
sudo -u veille docker compose up -d postgres
```

## Mise à jour du système

### Debian/Ubuntu

```bash
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
```

### Mises à jour automatiques

Configurer unattended-upgrades pour les mises à jour de sécurité automatiques.

## Mise à jour de Docker

```bash
# Vérifier la version actuelle
docker --version
docker compose version

# Mettre à jour
sudo apt update
sudo apt upgrade -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Rollback

### Rollback d'une image

```bash
# Lister les images
docker images

# Arrêter les containers
sudo -u veille docker compose down

# Modifier docker-compose.yml pour utiliser l'ancienne image
# image: service:old-version

# Redémarrer
sudo -u veille docker compose up -d
```

### Rollback depuis sauvegarde

```bash
sudo -u veille bash scripts/restore.sh
```

## Fréquence recommandée

- **Images Docker** : Mensuelle ou lors de CVE critiques
- **Système** : Mensuelle (automatique pour security)
- **Watchlists** : Mensuelle
- **Workflows n8n** : Mensuelle

## Surveillance des CVE

### Sources

- FreshRSS (flux CVE)
- changedetection.io (pages security advisories)
- Alertes n8n (workflow alerte-cve-critique)

### Procédure

1. Détecter une CVE critique
2. Vérifier si elle concerne la stack
3. Vérifier si un correctif est disponible
4. Sauvegarder
5. Appliquer la mise à jour
6. Vérifier la santé
7. Documenter

## Test de mise à jour

### Environnement de test

Tester les mises à jour sur un environnement de test avant production.

### Procédure

1. Cloner l'environnement de test
2. Appliquer la mise à jour
3. Vérifier le fonctionnement
4. Si OK, appliquer en production

## Documentation

Documenter chaque mise à jour :
- Date
- Version avant/après
- Problèmes rencontrés
- Solutions appliquées
