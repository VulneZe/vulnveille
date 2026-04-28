# Security Policy

## Principes de sécurité

Ce projet est conçu pour être une plateforme de veille **interne, confidentielle et sécurisée**. Les principes suivants doivent être respectés :

1. **Pas d'exposition Internet** : Les services ne doivent jamais être exposés sur Internet sans durcissement complémentaire
2. **Accès restreint** : Accès uniquement depuis le réseau interne, VLAN admin ou VPN
3. **Confidentialité** : Les données de veille sont sensibles et doivent être protégées
4. **Moindre privilège** : Utiliser des comptes non-root, permissions minimales
5. **Defense in depth** : Couches de sécurité : réseau, application, données

## Exposition réseau

### Interdit

- Exposer les ports applicatifs directement sur Internet
- Exposer PostgreSQL sur Internet ou sur le réseau interne
- Utiliser des mots de passe faibles
- Désactiver l'authentification

### Autorisé

- Exposer via Nginx reverse proxy interne uniquement
- Accès depuis réseau interne, VLAN admin ou VPN
- Utiliser TLS interne pour chiffrer les communications
- Limiter les IP autorisées dans le firewall

### Ports par défaut

- FreshRSS : 8081 (interne uniquement)
- n8n : 5678 (interne uniquement)
- changedetection.io : 5000 (interne uniquement)
- Wallabag : 8082 (interne uniquement)
- PostgreSQL : 5432 (réseau Docker uniquement, pas d'exposition)
- Nginx : 80, 443 (interne uniquement)

## Gestion des secrets

### Règles

- **Jamais** de secrets en dur dans les fichiers versionnés
- **Jamais** de secrets dans docker-compose.yml
- Tous les secrets dans `.env`
- `.env` jamais versionné (dans .gitignore)
- Générer des secrets forts (min 32 caractères, aléatoires)
- Rotationner les secrets régulièrement
- Sauvegarder `.env` séparément avec avertissement sécurité

### Secrets générés automatiquement

Le script `install.sh` génère automatiquement :
- `POSTGRES_PASSWORD` : Mot de passe PostgreSQL
- `N8N_BASIC_AUTH_PASSWORD` : Mot de passe basic auth n8n
- `N8N_ENCRYPTION_KEY` : Clé de chiffrement n8n
- `WALLABAG_SECRET` : Secret Wallabag
- `FRESHRSS_ADMIN_PASSWORD` : Mot de passe admin FreshRSS

### Secrets à configurer manuellement

- `N8N_BASIC_AUTH_USER` : Utilisateur basic auth n8n
- `POSTGRES_USER` : Utilisateur PostgreSQL
- `POSTGRES_DB_N8N` : Base de données n8n
- `POSTGRES_DB_WALLABAG` : Base de données Wallabag
- `WALLABAG_DATABASE_USER` : Utilisateur Wallabag
- `WALLABAG_DATABASE_PASSWORD` : Mot de passe Wallabag
- `WALLABAG_DATABASE_NAME` : Base de données Wallabag
- `FRESHRSS_ADMIN_USER` : Utilisateur admin FreshRSS

## Durcissement Docker

### Options appliquées

- `restart: unless-stopped` : Redémarrage automatique
- `security_opt: no-new-privileges:true` : Pas de nouveaux privilèges
- Réseaux Docker dédiés (`veille_net`)
- Volumes explicites pour la persistance
- Healthchecks quand disponibles
- Utilisateur non-root dans les containers quand possible
- Read-only filesystem pour les containers quand possible

### Réseaux

- Réseau dédié `veille_net` pour les services
- PostgreSQL uniquement sur `veille_net`
- Pas d'exposition de ports PostgreSQL
- Isolation entre services et hôte

### Volumes

- Volumes sous `./data/` avec permissions 750
- Propriétaire : utilisateur `veille`
- Pas de volumes bind sur des chemins système sensibles

## Durcissement Linux

### Utilisateur

- Création d'un utilisateur système `veille` dédié
- Pas d'accès root pour l'administration quotidienne
- SSH avec clés uniquement
- Désactivation du login root SSH

### Firewall

- UFW ou nftables activé
- Autoriser uniquement les flux nécessaires
- Bloquer Internet entrant
- Autoriser les flux sortants pour mises à jour et veille
- Limiter les IP admin autorisées

Voir `docs/firewall.md` pour les règles détaillées.

### Mises à jour

- Mises à jour automatiques de sécurité configurées
- Mises à jour régulières des packages système
- Mises à jour des images Docker via `make update`

### SSH

- Clés SSH uniquement (pas de password)
- Port SSH non standard (recommandé)
- `PermitRootLogin no`
- `PasswordAuthentication no`

### Audit

- Logs centralisés
- Surveillance des accès
- Alertes sur les activités suspectes

## Sauvegardes

### Fréquence

- Quotidienne recommandée
- Automatisée via cron
- Conservation des 7 dernières sauvegardes

### Contenu

- Volumes applicatifs
- Fichiers de configuration
- `.env` (sauvegardé séparément avec avertissement)

### Stockage

- Local dans `data/backups/`
- Export vers un stockage externe recommandé
- Chiffrement des sauvegardes externes recommandé

### Test

- Tester régulièrement la restauration
- Documenter la procédure de restauration
- Vérifier l'intégrité des sauvegardes

Voir `docs/sauvegarde-restauration.md` pour plus de détails.

## Logs

### Centralisation

- Logs Docker accessibles via `docker compose logs`
- Logs Nginx dans `/var/log/nginx/`
- Logs système dans `/var/log/`

### Rétention

- Configurer la rétention des logs
- Rotation des logs (logrotate)
- Export vers un système de centralisation recommandé

### Surveillance

- Surveiller les erreurs dans les logs
- Alertes sur les anomalies
- Analyse des tentatives d'intrusion

## Mises à jour

### Fréquence

- Images Docker : mensuelle ou lors de CVE critiques
- Packages système : automatique (security)
- Vérifier régulièrement les CVE des composants

### Procédure

1. Lire les notes de mise à jour
2. Tester en environnement de test
3. Sauvegarder avant mise à jour
4. Appliquer la mise à jour
5. Vérifier la santé
6. Conserver l'ancienne image pour rollback

### CVE

- Surveiller les CVE des composants :
  - FreshRSS
  - n8n
  - changedetection.io
  - Wallabag
  - PostgreSQL
  - Nginx
  - Docker
- Prioriser les CVE critiques
- Appliquer les correctifs rapidement

## Gestion des accès

### Authentification

- FreshRSS : Authentification par défaut + option 2FA
- n8n : Basic auth + option OAuth
- changedetection.io : Authentification par défaut
- Wallabag : Authentification par défaut

### Autorisation

- Créer des comptes utilisateurs individuels
- Pas de comptes partagés
- Révoquer les accès des utilisateurs partants
- Réviser régulièrement les accès

### Audit

- Logger les connexions
- Logger les actions sensibles
- Réviser régulièrement les logs d'accès

## Recommandations reverse proxy

### Nginx

- Utiliser Nginx comme point d'entrée unique
- Ne pas exposer les ports applicatifs directement
- Configurer les headers de sécurité :
  - `X-Frame-Options: DENY`
  - `X-Content-Type-Options: nosniff`
  - `X-XSS-Protection: 1; mode=block`
  - `Referrer-Policy: strict-origin-when-cross-origin`
  - `Content-Security-Policy` (à configurer selon besoins)
- Limiter la taille des uploads
- Configurer des timeouts raisonnables

Voir `docs/reverse-proxy-nginx.md` pour plus de détails.

## Recommandations HTTPS interne

### Certificats

- Utiliser une PKI interne si disponible
- Utiliser mkcert pour les tests
- Ne pas utiliser Let's Encrypt si les services ne sont pas publics
- Renouveler les certificats avant expiration

### Configuration

- Forcer HTTPS en production
- Désactiver TLS v1.0 et v1.1
- Utiliser TLS v1.2 minimum, v1.3 recommandé
- Configurer des ciphers forts

Voir `docs/tls-interne.md` pour plus de détails.

## Recommandations firewall

### Règles de base

- Bloquer tout par défaut
- Autoriser uniquement les flux nécessaires
- Limiter les IP autorisées pour l'administration
- Bloquer Internet entrant
- Autoriser les flux sortants pour mises à jour et veille

### Exemples

Voir `docs/firewall.md` pour les règles UFW détaillées.

## Interdiction de publier sur Internet

⚠️ **IMPORTANT** : Ce projet n'est pas conçu pour être exposé sur Internet sans durcissement complémentaire.

Si exposition Internet nécessaire :
- Forcer HTTPS avec certificat valide
- Configurer WAF (Web Application Firewall)
- Limiter les taux (rate limiting)
- Activer 2FA partout
- Configurer des règles firewall strictes
- Surveiller les logs en temps réel
- Effectuer un audit de sécurité
- Considérer l'utilisation d'un VPN d'entreprise

## Signalement de vulnérabilités

Si vous découvrez une vulnérabilité dans ce projet :
- Ne pas la rendre publique immédiatement
- La signaler de manière responsable
- Attendre la correction avant divulgation

## Références

- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [CIS Ubuntu Linux Benchmark](https://www.cisecurity.org/benchmark/ubuntu_linux)
- [ANSSI - Recommandations de sécurité](https://www.ssi.gouv.fr/guide/recommandations-de-securite-relatives-a-un-systeme-dexploitation-linux/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
