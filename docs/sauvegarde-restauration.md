# Sauvegarde et Restauration

## Sauvegarde

### Script de sauvegarde

Le script `scripts/backup.sh` automatise la sauvegarde de la stack.

```bash
cd /opt/veille-techno-cyber-interne
make backup
# ou
sudo -u veille bash scripts/backup.sh
```

### Ce qui est sauvegardé

- Volumes applicatifs (FreshRSS, n8n, changedetection, Wallabag, PostgreSQL)
- Fichiers de configuration (docker-compose.yml, config/)
- Fichier .env (séparément avec avertissement sécurité)

### Fréquence recommandée

- Quotidienne pour la production
- Hebdomadaire pour le développement

### Sauvegarde automatique

Configurer un cron :

```bash
sudo crontab -e -u veille
```

Ajouter :
```
0 2 * * * /opt/veille-techno-cyber-interne/scripts/backup.sh
```

### Stockage des sauvegardes

Les sauvegardes sont stockées dans `data/backups/` avec conservation des 7 dernières par défaut.

### Export vers stockage externe

```bash
# Copier vers un serveur de sauvegarde
scp /opt/veille-techno-cyber-interne/data/backups/* user@backup-server:/backups/

# Ou utiliser rsync
rsync -avz /opt/veille-techno-cyber-interne/data/backups/ user@backup-server:/backups/
```

### Chiffrement des sauvegardes externes

Pour les sauvegardes externes, chiffrer les archives :

```bash
gpg --encrypt --recipient your@email.com veille_backup_20240101_120000_data.tar.gz
```

## Restauration

### Script de restauration

```bash
cd /opt/veille-techno-cyber-interne
make restore
# ou
sudo -u veille bash scripts/restore.sh
```

### Étapes de restauration

1. Le script liste les sauvegardes disponibles
2. Sélectionner la sauvegarde à restaurer
3. Confirmation de la restauration
4. Arrêt des containers
5. Restauration des données
6. Redémarrage des containers
7. Vérification de la santé

### Restauration manuelle

```bash
# Arrêter les containers
sudo -u veille docker compose down

# Restaurer les données
tar -xzf data/backups/veille_backup_20240101_120000_data.tar.gz -C ./

# Restaurer la configuration
tar -xzf data/backups/veille_backup_20240101_120000_config.tar.gz -C ./

# Restaurer le .env (avec précaution)
cp data/backups/veille_backup_20240101_120000_env .env
chmod 600 .env

# Redémarrer
sudo -u veille docker compose up -d
```

### Restauration sur un nouveau serveur

1. Installer Docker et Docker Compose
2. Copier les fichiers du projet
3. Restaurer les sauvegardes
4. Démarrer la stack

## Test de restauration

Tester régulièrement la restauration pour s'assurer que les sauvegardes sont fonctionnelles :

```bash
# Sur un environnement de test
sudo -u veille bash scripts/restore.sh
```

## Stratégie de sauvegarde

### 3-2-1 Rule

- 3 copies des données
- 2 types de stockage différents
- 1 copie hors site

### Exemple

1. **Locale** : data/backups/ (7 jours)
2. **Réseau** : Serveur de sauvegarde interne (30 jours)
3. **Hors site** : Cloud ou stockage externe (90 jours)

## Intégrité des sauvegardes

### Vérification

```bash
# Vérifier l'intégrité des archives
tar -tzf data/backups/veille_backup_20240101_120000_data.tar.gz
```

### Test

Restaurer régulièrement sur un environnement de test.

## Documentation

Documenter :
- La procédure de sauvegarde
- La procédure de restauration
- L'emplacement des sauvegardes
- Les credentials de chiffrement
