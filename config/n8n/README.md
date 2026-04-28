# n8n Workflows Examples

Ce dossier contient des exemples de workflows n8n pour la plateforme de veille techno-cyber.

## Workflows disponibles

- `digest-quotidien.md` : Workflow pour générer un digest quotidien des articles de veille
- `alerte-cve-critique.md` : Workflow pour les alertes de vulnérabilités critiques
- `surveillance-fin-support.md` : Workflow pour la surveillance des fins de support

## Importation dans n8n

1. Accéder à n8n : http://n8n.veille.local
2. Créer un nouveau workflow
3. Importer le workflow depuis le fichier JSON correspondant
4. Configurer les credentials (email, FreshRSS API, etc.)
5. Activer le workflow

## Configuration requise

- Credentials FreshRSS (API)
- Credentials email (SMTP)
- Credentials changedetection.io (API)
- Accès aux fichiers de watchlist YAML

## Personnalisation

Les workflows doivent être adaptés à votre environnement :
- Adresses email de destination
- Fréquences de déclenchement
- Sources de données spécifiques
- Règles de filtrage personnalisées
