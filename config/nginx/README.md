# Configuration Nginx

Ce dossier contient les configurations Nginx pour le reverse proxy interne.

## Installation

Copier les fichiers de configuration dans Nginx :

```bash
sudo cp *.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/freshrss.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/n8n.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/changedetection.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/wallabag.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## TLS

Pour activer HTTPS, voir `docs/tls-interne.md`.

Ajouter les certificats dans chaque fichier de configuration :

```nginx
ssl_certificate /etc/ssl/certs/veille.local.crt;
ssl_certificate_key /etc/ssl/private/veille.local.key;
```

## Headers de sécurité

Les configurations incluent déjà les headers de sécurité de base.
