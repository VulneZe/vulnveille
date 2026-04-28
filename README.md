# veille-techno-cyber-interne

Plateforme interne de veille technologique et cyber-sécurité, auto-hébergée, sécurisée et confidentielle.

## Objectif

Ce projet fournit une architecture complète pour déployer une plateforme de veille interne regroupant :
- **FreshRSS** : Agrégateur RSS pour suivre les flux d'information
- **n8n** : Automatisation des workflows de veille (digests, alertes)
- **changedetection.io** : Surveillance de pages web sans RSS
- **Wallabag** : Sauvegarde et annotation d'articles
- **PostgreSQL** : Base de données pour les services
- **Nginx** : Reverse proxy interne unifié

## Architecture générale

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

## Pourquoi Docker Compose

Docker Compose est **recommandé** pour cette stack car :

- **Isolation** : Chaque service est isolé dans son conteneur
- **Reproductibilité** : Même environnement en dev et prod
- **Mise à jour simple** : `docker compose pull && docker compose up -d`
- **Rollback facile** : Images versionnées, retour arrière possible
- **Pas de conflits de dépendances** : Chaque service a ses propres librairies
- **Déploiement unifié** : Un seul fichier déclare toute l'architecture
- **Sécurité** : Réseaux Docker dédiés, volumes explicites
- **Maintenance** : Moins de temps perdu sur les problèmes système

## Pourquoi éviter l'installation native sans Docker

L'installation sans Docker est **possible mais déconseillée** pour cette stack car :

- **Conflits de dépendances** : PHP versions, Python packages, librairies système
- **Maintenance complexe** : Mises à jour manuelles de chaque composant
- **Temps d'installation** : Plusieurs heures vs quelques minutes
- **Difficile à tester** : Environnement de prod difficile à reproduire en local
- **Pas d'isolation** : Un service compromis peut en affecter d'autres
- **Nettoyage complexe** : Fichiers éparpillés sur le système
- **Pas de rollback facile** : Mises à jour irréversibles

Voir `docs/docker-vs-installation-native.md` pour plus de détails.

## Prérequis

- **Test local** : Docker Engine + Docker Compose plugin
- **Serveur** : Debian 12 ou Ubuntu Server LTS
- **Accès** : Accès réseau interne, VPN ou VLAN admin
- **Ressources** : Minimum 4 Go RAM, 20 Go disque
- **DNS interne** : Configurer les noms veille.local (optionnel pour test local)

## Installation locale

1. Cloner le projet :
```bash
git clone <repository-url>
cd veille-techno-cyber-interne
```

2. Générer le fichier `.env` :
```bash
cp .env.example .env
# Éditer .env et ajuster les variables
```

3. Pour un test rapide avec ports exposés :
```bash
cp docker-compose.override.yml.example docker-compose.override.yml
```

4. Démarrer :
```bash
docker compose up -d
```

5. Accéder aux services :
- FreshRSS : http://localhost:8081
- n8n : http://localhost:5678
- changedetection.io : http://localhost:5000
- Wallabag : http://localhost:8082

## Installation serveur avec install.sh

Le script `install.sh` automatise l'installation complète sur un serveur Debian/Ubuntu.

```bash
# Cloner le projet
git clone <repository-url>
cd veille-techno-cyber-interne

# Lancer l'installation (nécessite sudo)
sudo ./install.sh
```

Le script :
- Vérifie l'OS (Debian/Ubuntu)
- Installe Docker si absent
- Crée un utilisateur système `veille`
- Déploie dans `/opt/veille-techno-cyber-interne`
- Génère des secrets forts automatiquement
- Démarre la stack
- Exécute les vérifications de santé

## Installation serveur avec Ansible

Alternative automatisée pour déploiements multi-serveurs.

```bash
# Configurer l'inventaire
cp ansible/inventory.example.ini ansible/inventory.ini
# Éditer ansible/inventory.ini avec vos serveurs

# Configurer les variables
cp ansible/group_vars/veille.yml.example ansible/group_vars/veille.yml
# Éditer ansible/group_vars/veille.yml

# Lancer le playbook
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

## Configuration du .env

Le fichier `.env` contient toutes les variables de configuration. Points importants :

- **TZ** : Fuseau horaire (Europe/Paris par défaut)
- **INTERNAL_DOMAIN** : Domaine interne (veille.local)
- **POSTGRES_PASSWORD** : Mot de passe PostgreSQL (généré automatiquement par install.sh)
- **N8N_ENCRYPTION_KEY** : Clé de chiffrement n8n (généré automatiquement)
- **FRESHRSS_ADMIN_PASSWORD** : Mot de passe admin FreshRSS (généré automatiquement)

Ne jamais versionner `.env`. Utiliser uniquement `.env.example`.

## Configuration DNS interne

En production, configurer votre DNS interne pour résoudre :

- `freshrss.veille.local` → IP du serveur
- `n8n.veille.local` → IP du serveur
- `changes.veille.local` → IP du serveur
- `wallabag.veille.local` → IP du serveur

Ajouter ces entrées dans votre fichier `/etc/hosts` local pour test :
```
<IP-SERVEUR> freshrss.veille.local n8n.veille.local changes.veille.local wallabag.veille.local
```

## Configuration Nginx

Nginx sert de reverse proxy interne. Les configurations sont dans `config/nginx/`.

Activer les sites :
```bash
sudo cp config/nginx/*.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/freshrss.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/n8n.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/changedetection.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/wallabag.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

Voir `docs/reverse-proxy-nginx.md` pour plus de détails.

## Configuration TLS interne

Pour HTTPS interne, plusieurs options :

1. **PKI interne** : Certificats signés par votre autorité interne
2. **mkcert** : Pour tests locaux (voir `docs/tls-interne.md`)
3. **Certificat d'entreprise** : Certificat wildcard pour veille.local

Ne pas utiliser Let's Encrypt si les services ne sont pas publics.

## Démarrage

```bash
# Démarrer la stack
make start
# ou
docker compose up -d

# Avec fichier production
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## Arrêt

```bash
# Arrêter la stack
make stop
# ou
docker compose down
```

## Logs

```bash
# Voir tous les logs
make logs
# ou
docker compose logs -f

# Logs d'un service spécifique
docker compose logs -f freshrss
docker compose logs -f n8n
```

## Sauvegardes

```bash
# Créer une sauvegarde
make backup
# ou
scripts/backup.sh
```

Les sauvegardes sont stockées dans `data/backups/` avec conservation des 7 dernières.

Voir `docs/sauvegarde-restauration.md` pour plus de détails.

## Restauration

```bash
# Restaurer depuis une sauvegarde
make restore
# ou
scripts/restore.sh
```

## Mise à jour

```bash
# Mettre à jour la stack
make update
# ou
scripts/update.sh
```

La commande :
- Pull les nouvelles images
- Redémarre les containers
- Propose de nettoyer les anciennes images
- Vérifie la santé après mise à jour

## Ajout de sources de veille

Voir `sources-veille.md` pour une liste structurée de sources recommandées.

### Dans FreshRSS

1. Se connecter à FreshRSS
2. Ajouter les flux RSS depuis `sources-veille.md`
3. Organiser par catégories

### Dans changedetection.io

1. Se connecter à changedetection.io
2. Ajouter les pages sans RSS depuis `sources-veille.md`
3. Configurer la fréquence de surveillance

## Ajout de pages sans RSS

Utiliser changedetection.io pour surveiller :
- Pages de lifecycle éditeurs
- Roadmaps
- Security advisories sans RSS
- Pages de changelog

## Création d'un digest dans n8n

Voir `config/n8n/workflows-examples/digest-quotidien.md` et `workflow-veille.md`.

Workflow typique :
1. Déclenchement chaque matin (cron)
2. Récupération des nouveaux articles FreshRSS (API)
3. Filtrage par mots-clés (voir `config/watchlists/keywords-critical.yml`)
4. Classification par catégorie
5. Scoring d'impact (voir `docs/scoring-impact.md`)
6. Génération d'un résumé
7. Envoi par email ou canal interne
8. Archivage

## Création d'une alerte vulnérabilité critique

Voir `config/n8n/workflows-examples/alerte-cve-critique.md` et `workflow-veille.md`.

Workflow typique :
1. Surveillance des flux CVE
2. Détection de mots-clés critiques
3. Vérification dans `config/watchlists/stack-watchlist.yml`
4. Priorisation si CVSS élevé, exploitation active, CISA KEV
5. Notification immédiate
6. Création optionnelle d'un ticket interne

## Passage en production

1. Configurer le DNS interne
2. Configurer Nginx reverse proxy
3. Configurer TLS interne
4. Utiliser `docker-compose.prod.yml`
5. Configurer le firewall (voir `docs/firewall.md`)
6. Exécuter le durcissement (voir `docs/securisation-linux.md`)
7. Lancer `make hardening-check`
8. Configurer les sauvegardes automatiques (cron)
9. Configurer la supervision

## Dépannage

### Containers ne démarrent pas

```bash
# Voir les logs
docker compose logs

# Vérifier l'état
docker compose ps

# Recréer les containers
docker compose down
docker compose up -d
```

### Problème de permissions

```bash
# Corriger les permissions sur data/
sudo chown -R veille:veille data/
sudo chmod -R 750 data/
```

### PostgreSQL inaccessible

Vérifier que PostgreSQL n'est pas exposé publiquement :
```bash
make health
# ou
scripts/check-health.sh
```

### Accès depuis le réseau

Vérifier :
- Firewall (UFW/nftables)
- Nginx configuration
- DNS interne
- VPN/VLAN admin

## Roadmap V1.5

- **OpenCVE** ou **Vulnerability-Lookup** pour la veille vulnérabilités avancée
- Intégration avec des sources CVE supplémentaires
- Scoring automatique des CVE
- Corrélation avec la stack interne

Voir `docs/vuln-watch.md` pour plus de détails.

## Sécurité

Voir `SECURITY.md` pour les principes de sécurité et recommandations.

## Documentation

- `docs/architecture.md` : Architecture détaillée
- `docs/docker-vs-installation-native.md` : Pourquoi Docker
- `docs/installation-locale.md` : Installation locale détaillée
- `docs/installation-serveur.md` : Installation serveur détaillée
- `docs/installation-automatisee.md` : Installation Ansible détaillée
- `docs/exploitation.md` : Exploitation au quotidien
- `docs/sauvegarde-restauration.md` : Sauvegardes et restauration
- `docs/securisation-linux.md` : Durcissement Linux
- `docs/reverse-proxy-nginx.md` : Configuration Nginx
- `docs/tls-interne.md` : TLS interne
- `docs/firewall.md` : Configuration firewall
- `docs/mise-a-jour.md` : Mise à jour détaillée
- `docs/supervision.md` : Supervision
- `docs/vuln-watch.md` : Veille vulnérabilités
- `docs/runbook-incident.md` : Runbook incident
- `docs/scoring-impact.md` : Scoring d'impact

## Licence

Ce projet est fourni tel quel pour un usage interne.
