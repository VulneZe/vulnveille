# Installation Locale

## Prérequis

- Docker Engine installé
- Docker Compose plugin installé
- 4 Go RAM minimum
- 20 Go disque minimum

## Étapes

### 1. Cloner le projet

```bash
git clone <repository-url>
cd veille-techno-cyber-interne
```

### 2. Générer le fichier .env

```bash
cp .env.example .env
# Éditer .env et ajuster les variables
```

### 3. (Optionnel) Test rapide avec ports exposés

```bash
cp docker-compose.override.yml.example docker-compose.override.yml
```

### 4. Démarrer

```bash
docker compose up -d
```

### 5. Accéder aux services

Si `docker-compose.override.yml` est utilisé :
- FreshRSS : http://localhost:8081
- n8n : http://localhost:5678
- changedetection.io : http://localhost:5000
- Wallabag : http://localhost:8082

Sinon, configurer le DNS interne ou modifier `/etc/hosts` :
```
127.0.0.1 freshrss.veille.local n8n.veille.local changes.veille.local wallabag.veille.local
```

## Configuration initiale

### FreshRSS

1. Accéder à http://localhost:8081 (ou freshrss.veille.local)
2. Créer le compte admin
3. Configurer le rafraîchissement automatique
4. Ajouter les flux RSS depuis `sources-veille.md`

### n8n

1. Accéder à http://localhost:5678 (ou n8n.veille.local)
2. S'authentifier avec les credentials du .env
3. Créer les credentials (FreshRSS API, SMTP, etc.)
4. Importer les workflows depuis `config/n8n/workflows-examples/`

### changedetection.io

1. Accéder à http://localhost:5000 (ou changes.veille.local)
2. Créer le compte admin
3. Ajouter les watchlists depuis `sources-veille.md`
4. Configurer la fréquence de surveillance

### Wallabag

1. Accéder à http://localhost:8082 (ou wallabag.veille.local)
2. Créer le compte admin
3. Configurer les options de sauvegarde
4. (Optionnel) Configurer l'import/export

## Arrêt

```bash
docker compose down
```

## Suppression

```bash
docker compose down -v
# Supprime également les volumes (données)
```

## Dépannage

### Containers ne démarrent pas

```bash
docker compose logs
docker compose ps
```

### Problème de permissions

```bash
sudo chown -R $USER:$USER data/
chmod -R 750 data/
```

### Ports déjà utilisés

Modifier les ports dans `docker-compose.override.yml` ou arrêter les services utilisant ces ports.
