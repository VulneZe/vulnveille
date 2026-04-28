# Supervision

## Healthchecks Docker

Les services ont des healthchecks configurés :

```bash
# Vérifier l'état des healthchecks
sudo -u veille docker compose ps
```

## Script de vérification

```bash
cd /opt/veille-techno-cyber-interne
make health
# ou
sudo -u veille bash scripts/check-health.sh
```

Le script vérifie :
- Docker répond
- Containers sont up
- Ports
- Healthchecks Docker
- PostgreSQL n'est pas exposé publiquement

## Supervision des ressources

### CPU

```bash
top
htop
```

### RAM

```bash
free -h
```

### Disque

```bash
df -h
docker system df
```

### Réseau

```bash
netstat -tuln
iftop
```

## Logs

### Logs Docker

```bash
sudo -u veille docker compose logs -f
```

### Logs Nginx

```bash
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Logs système

```bash
sudo journalctl -f
```

## Outils de supervision

### Prometheus + Grafana

Installer Prometheus et Grafana pour superviser :

- CPU
- RAM
- Disque
- Réseau
- État des services
- Healthchecks

### Netdata

Netdata est une solution de supervision légère :

```bash
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
```

### Uptime Kuma

Uptime Kuma pour surveiller la disponibilité des services :

```bash
docker run -d --restart=always -p 3001:3001 -v uptime-kuma:/app/data louislam/uptime-kuma:1
```

## Alertes

### n8n

Les workflows n8n peuvent envoyer des alertes :
- Email
- Slack
- Teams
- Webhook

### Uptime Kuma

Uptime Kuma peut envoyer des alertes :
- Email
- Telegram
- Slack
- Webhook

## Documentation

Documenter :
- Les seuils d'alerte
- Les procédures d'intervention
- Les contacts d'urgence
