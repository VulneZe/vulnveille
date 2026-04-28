# Reverse Proxy Nginx

## Pourquoi utiliser Nginx

- Point d'entrée unique pour tous les services
- Gestion centralisée des headers de sécurité
- Terminaison TLS
- Gestion des timeouts et limites
- Logs centralisés
- Facilité de maintenance

## Installation

```bash
sudo apt install nginx
```

## Configuration

### Copier les configurations

```bash
sudo cp config/nginx/*.conf /etc/nginx/sites-available/
```

### Activer les sites

```bash
sudo ln -s /etc/nginx/sites-available/freshrss.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/n8n.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/changedetection.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/wallabag.conf /etc/nginx/sites-enabled/
```

### Supprimer la configuration par défaut

```bash
sudo rm /etc/nginx/sites-enabled/default
```

### Tester la configuration

```bash
sudo nginx -t
```

### Recharger Nginx

```bash
sudo systemctl reload nginx
```

## Headers de sécurité

Les configurations incluent déjà les headers de sécurité suivants :

- `X-Frame-Options: DENY` : Protection contre le clickjacking
- `X-Content-Type-Options: nosniff` : Protection contre le MIME sniffing
- `X-XSS-Protection: 1; mode=block` : Protection XSS
- `Referrer-Policy: strict-origin-when-cross-origin` : Contrôle du referrer

### Ajouter Content-Security-Policy

Pour renforcer la sécurité, ajouter CSP dans chaque configuration :

```nginx
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';" always;
```

## Limites

### Taille des uploads

Les configurations incluent déjà des limites de taille :

- FreshRSS : 10M
- n8n : 100M
- changedetection.io : 10M
- Wallabag : 10M

Ajuster selon vos besoins.

## Timeouts

Les configurations incluent des timeouts raisonnables :

- FreshRSS : 60s
- n8n : 300s (workflows longs)
- changedetection.io : 60s
- Wallabag : 60s

Ajuster selon vos besoins.

## Logs

Les logs sont configurés dans `/var/log/nginx/` :

- freshrss_access.log
- freshrss_error.log
- n8n_access.log
- n8n_error.log
- changedetection_access.log
- changedetection_error.log
- wallabag_access.log
- wallabag_error.log

## TLS

Pour activer HTTPS, voir `docs/tls-interne.md`.

Ajouter dans chaque configuration :

```nginx
listen 443 ssl http2;
ssl_certificate /etc/ssl/certs/veille.local.crt;
ssl_certificate_key /etc/ssl/private/veille.local.key;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers HIGH:!aNULL:!MD5;
```

## Configuration exemple

### FreshRSS

```nginx
server {
    listen 80;
    server_name freshrss.veille.local;

    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    location / {
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    client_max_body_size 10M;
}
```

## Dépannage

### Erreur 502 Bad Gateway

Vérifier que le service backend est en cours d'exécution :

```bash
sudo -u veille docker compose ps
```

### Erreur 504 Gateway Timeout

Augmenter les timeouts dans la configuration Nginx.

### Logs d'erreur

```bash
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/freshrss_error.log
```
