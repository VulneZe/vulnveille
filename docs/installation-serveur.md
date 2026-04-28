# Installation Serveur

## Prérequis

- Debian 12 ou Ubuntu Server LTS
- Accès root ou sudo
- 4 Go RAM minimum (8 Go recommandé)
- 20 Go disque minimum (50 Go recommandé)
- Accès réseau interne, VPN ou VLAN admin

## Méthode 1 : Script install.sh

### Étapes

1. Cloner le projet sur le serveur :
```bash
git clone <repository-url> /tmp/veille-techno-cyber-interne
cd /tmp/veille-techno-cyber-interne
```

2. Lancer le script d'installation :
```bash
sudo ./install.sh
```

Le script :
- Vérifie l'OS
- Installe Docker si absent
- Crée l'utilisateur `veille`
- Déploie dans `/opt/veille-techno-cyber-interne`
- Génère des secrets forts automatiquement
- Démarre la stack
- Exécute les vérifications de santé

3. Vérifier les variables générées :
```bash
sudo cat /opt/veille-techno-cyber-interne/.env
```

4. Configurer le DNS interne pour :
- freshrss.veille.local
- n8n.veille.local
- changes.veille.local
- wallabag.veille.local

## Méthode 2 : Installation manuelle

### 1. Installer Docker

Voir `scripts/install-docker.sh` ou suivre la documentation officielle Docker.

### 2. Créer l'utilisateur veille

```bash
sudo useradd -r -s /bin/bash -d /opt/veille-techno-cyber-interne veille
```

### 3. Créer l'arborescence

```bash
sudo mkdir -p /opt/veille-techno-cyber-interne
sudo chown veille:veille /opt/veille-techno-cyber-interne
cd /opt/veille-techno-cyber-interne
```

### 4. Copier les fichiers

```bash
# Copier depuis votre machine locale
scp -r veille-techno-cyber-interne/* user@server:/opt/veille-techno-cyber-interne/
```

### 5. Générer le .env

```bash
sudo -u veille bash scripts/generate-env.sh
```

### 6. Démarrer

```bash
sudo -u veille docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## Configuration Nginx

### 1. Installer Nginx

```bash
sudo apt install nginx
```

### 2. Copier les configurations

```bash
sudo cp config/nginx/*.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/freshrss.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/n8n.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/changedetection.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/wallabag.conf /etc/nginx/sites-enabled/
```

### 3. Tester et recharger

```bash
sudo nginx -t
sudo systemctl reload nginx
```

Voir `docs/reverse-proxy-nginx.md` pour plus de détails.

## Configuration TLS

Voir `docs/tls-interne.md` pour les options de certificats internes.

## Configuration Firewall

Voir `docs/firewall.md` pour les règles UFW.

## Vérification

```bash
cd /opt/veille-techno-cyber-interne
sudo -u veille bash scripts/check-health.sh
sudo -u veille bash scripts/hardening-check.sh
```

## Sauvegardes automatiques

Ajouter une entrée crontab pour les sauvegardes quotidiennes :

```bash
sudo crontab -e -u veille
```

Ajouter :
```
0 2 * * * /opt/veille-techno-cyber-interne/scripts/backup.sh
```

## Mise à jour

```bash
cd /opt/veille-techno-cyber-interne
sudo -u veille bash scripts/update.sh
```
