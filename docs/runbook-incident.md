# Runbook Incident

## Incident Types

### 1. Service indisponible

#### Symptômes
- Service inaccessible via Nginx
- Erreur 502 Bad Gateway
- Erreur 504 Gateway Timeout

#### Diagnostic
```bash
# Vérifier l'état des containers
sudo -u veille docker compose ps

# Vérifier les logs
sudo -u veille docker compose logs <service>

# Vérifier Nginx
sudo nginx -t
sudo systemctl status nginx
```

#### Résolution
```bash
# Redémarrer le service
sudo -u veille docker compose restart <service>

# Si problème persiste, recréer le container
sudo -u veille docker compose down
sudo -u veille docker compose up -d
```

### 2. Base de données inaccessible

#### Symptômes
- Erreurs de connexion PostgreSQL
- Services ne démarrent pas

#### Diagnostic
```bash
# Vérifier PostgreSQL
sudo -u veille docker compose logs postgres

# Vérifier que PostgreSQL n'est pas exposé
sudo netstat -tuln | grep 5432
```

#### Résolution
```bash
# Redémarrer PostgreSQL
sudo -u veille docker compose restart postgres

# Si problème de données, restaurer depuis sauvegarde
sudo -u veille bash scripts/restore.sh
```

### 3. Espace disque plein

#### Symptômes
- Containers ne démarrent pas
- Erreurs d'écriture
- Logs manquants

#### Diagnostic
```bash
# Vérifier l'espace disque
df -h

# Vérifier l'espace Docker
docker system df
```

#### Résolution
```bash
# Nettoyer les anciennes images
docker image prune -a

# Nettoyer les volumes non utilisés
docker volume prune

# Nettoyer les logs Docker
sudo journalctl --vacuum-time=7d

# Nettoyer les logs Nginx
sudo logrotate -f /etc/logrotate.conf
```

### 4. Performance dégradée

#### Symptômes
- Lenteur des services
- Timeouts
- Haute utilisation CPU/RAM

#### Diagnostic
```bash
# Vérifier CPU
top
htop

# Vérifier RAM
free -h

# Vérifier les containers
sudo -u veille docker compose ps
sudo -u veille docker stats
```

#### Résolution
```bash
# Redémarrer les services
sudo -u veille docker compose restart

# Augmenter les ressources du serveur
# (si possible)

# Optimiser les workflows n8n
# (réduire la fréquence, optimiser les nœuds)
```

### 5. Vulnérabilité critique détectée

#### Symptômes
- Alerte CVE critique reçue
- Technologie de la stack affectée

#### Diagnostic
```bash
# Vérifier la version du service affecté
sudo -u veille docker compose ps

# Lire l'advisory de la CVE
```

#### Résolution
```bash
# Sauvegarder
sudo -u veille bash scripts/backup.sh

# Mettre à jour le service
sudo -u veille docker compose pull <service>
sudo -u veille docker compose up -d <service>

# Vérifier la santé
sudo -u veille bash scripts/check-health.sh
```

### 6. Configuration corrompue

#### Symptômes
- Service ne démarre pas
- Erreurs de configuration

#### Diagnostic
```bash
# Vérifier la configuration
sudo -u veille docker compose config

# Vérifier les logs
sudo -u veille docker compose logs <service>
```

#### Résolution
```bash
# Restaurer depuis sauvegarde
sudo -u veille bash scripts/restore.sh

# Si problème de .env, régénérer
sudo -u veille bash scripts/generate-env.sh
```

### 7. Attaque en cours

#### Symptômes
- Trafic anormal
- Tentatives d'intrusion
- Comptes compromis

#### Diagnostic
```bash
# Vérifier les logs
sudo tail -f /var/log/auth.log
sudo tail -f /var/log/nginx/access.log

# Vérifier les connexions
sudo netstat -tuln
sudo ss -tuln
```

#### Résolution
```bash
# Bloquer l'IP attaquante
sudo ufw deny from <IP>

# Désactiver les services si nécessaire
sudo -u veille docker compose down

# Changer les mots de passe
# (modifier .env et redémarrer)

# Analyser l'incident
# (logs, forensique)
```

## Procédure générale

### 1. Identification
- Identifier le type d'incident
- Déterminer l'impact
- Noter le temps de début

### 2. Containment
- Limiter l'impact
- Isoler si nécessaire
- Préserver les logs

### 3. Diagnostic
- Collecter les informations
- Analyser les logs
- Identifier la cause racine

### 4. Résolution
- Appliquer la correction
- Vérifier le résultat
- Documenter

### 5. Récupération
- Restaurer les services
- Vérifier la santé
- Communiquer

### 6. Post-incident
- Analyse post-mortem
- Améliorer les processus
- Mettre à jour la documentation

## Communication

### Interne
- Informer l'équipe technique
- Communiquer l'état
- Estimer le temps de résolution

### Externe
- Si impact utilisateur, communiquer
- Expliquer la situation
- Donner une ETA

## Documentation

Documenter chaque incident :
- Date et heure
- Type d'incident
- Impact
- Cause racine
- Résolution
- Leçons apprises
- Actions préventives
