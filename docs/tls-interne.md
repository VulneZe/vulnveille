# TLS Interne

## Options

### 1. PKI Interne

Si votre organisation dispose d'une PKI interne :

1. Générer un certificat wildcard pour `*.veille.local`
2. Copier le certificat et la clé sur le serveur
3. Configurer Nginx avec le certificat

### 2. mkcert (pour tests)

mkcert permet de générer des certificats locaux de confiance.

```bash
# Installer mkcert
sudo apt install mkcert

# Installer le CA local
mkcert -install

# Générer le certificat
mkcert veille.local "*.veille.local" localhost 127.0.0.1

# Copier les certificats
sudo cp veille.local+1.pem /etc/ssl/certs/veille.local.crt
sudo cp veille.local+1-key.pem /etc/ssl/private/veille.local.key
sudo chmod 600 /etc/ssl/private/veille.local.key
```

### 3. Certificat d'entreprise

Si votre organisation a un certificat wildcard pour le domaine interne :

1. Obtenir le certificat wildcard
2. Copier le certificat et la clé sur le serveur
3. Configurer Nginx avec le certificat

## Configuration Nginx

Pour chaque service, ajouter la configuration TLS :

```nginx
listen 443 ssl http2;
ssl_certificate /etc/ssl/certs/veille.local.crt;
ssl_certificate_key /etc/ssl/private/veille.local.key;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers HIGH:!aNULL:!MD5;
ssl_prefer_server_ciphers on;
```

### Exemple complet

```nginx
server {
    listen 80;
    server_name freshrss.veille.local;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name freshrss.veille.local;

    ssl_certificate /etc/ssl/certs/veille.local.crt;
    ssl_certificate_key /etc/ssl/private/veille.local.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    location / {
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Let's Encrypt

⚠️ **Attention** : Let's Encrypt ne doit être utilisé que si les services sont publics.

Si les services sont internes uniquement, Let's Encrypt ne fonctionnera pas car le challenge HTTP ne sera pas accessible depuis Internet.

Si vous devez utiliser Let's Encrypt :

1. Exposer temporairement les ports 80/443 sur Internet
2. Utiliser certbot avec le challenge HTTP
3. Revenir à l'exposition interne
4. Renouveler automatiquement avec certbot

## Renouvellement

### Certificats auto-signés ou PKI interne

Renouveler manuellement avant expiration.

### Certificats d'entreprise

Suivre la procédure de renouvellement de votre organisation.

### Let's Encrypt

Certbot renouvelle automatiquement si configuré correctement.

## Vérification

```bash
# Vérifier le certificat
openssl x509 -in /etc/ssl/certs/veille.local.crt -text -noout

# Vérifier la configuration Nginx
sudo nginx -t

# Recharger Nginx
sudo systemctl reload nginx
```

## Déploiement du certificat sur les clients

### mkcert

Les clients doivent avoir le CA mkcert installé :

```bash
mkcert -install
```

### PKI interne

Les clients doivent avoir le CA de votre organisation installé.

### Certificat d'entreprise

Les clients doivent avoir le CA de votre organisation installé.

## Sécurité

- Utiliser TLS v1.2 minimum, v1.3 recommandé
- Désactiver TLS v1.0 et v1.1
- Utiliser des ciphers forts
- Activer HSTS
- Renouveler avant expiration
