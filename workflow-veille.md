# Workflows de Veille

Ce document décrit les workflows de veille à implémenter dans n8n pour automatiser la plateforme.

## Workflow 1 : Digest Quotidien

### Objectif
Générer un digest quotidien des articles de veille, filtrés par pertinence et classés par catégorie.

### Déclenchement
- **Type** : Cron
- **Fréquence** : Tous les matins à 8h00
- **Expression** : `0 8 * * *`

### Étapes
1. Récupération des nouveaux articles FreshRSS
2. Filtrage par mots-clés (keywords-critical.yml)
3. Classification par catégorie
4. Scoring d'impact (scoring-impact.md)
5. Vérification dans stack-watchlist.yml
6. Génération d'un résumé
7. Envoi par email ou canal interne
8. Archivage des éléments importants dans Wallabag

### Sortie
Email structuré avec sections :
- Alertes prioritaires (score 80+)
- Actions recommandées (score 60-79)
- À surveiller (score 30-59)
- Information (score 0-29)

### Documentation détaillée
Voir `config/n8n/workflows-examples/digest-quotidien.md`

---

## Workflow 2 : Alerte Vulnérabilité Critique

### Objectif
Détecter les CVE critiques et envoyer une alerte immédiate si elles concernent des technologies de la stack interne.

### Déclenchement
- **Type** : Polling
- **Fréquence** : Toutes les 15 minutes
- **Sources** : FreshRSS (flux CVE), changedetection.io (pages security advisories)

### Étapes
1. Récupération des flux CVE
2. Récupération changedetection.io
3. Fusion des sources
4. Filtrage par mots-clés critiques (keywords-critical.yml)
5. Vérification dans stack-watchlist.yml
6. Vérification CISA KEV
7. Vérification CVSS
8. Calcul du score de priorité
9. Déduplication
10. Génération de l'alerte
11. Envoi de l'alerte immédiate (email)
12. Notification Slack/Teams (optionnel)
13. Création de ticket (optionnel)
14. Archivage

### Sortie
Alerte email prioritaire avec :
- Détails de la CVE
- Technologies concernées
- Score CVSS
- Exploitation active
- Actions recommandées
- Liens

### Documentation détaillée
Voir `config/n8n/workflows-examples/alerte-cve-critique.md`

---

## Workflow 3 : Surveillance Fin de Support

### Objectif
Surveiller les pages lifecycle des éditeurs pour détecter les fins de support et générer des alertes avant les échéances critiques.

### Déclenchement
- **Type** : Polling
- **Fréquence** : Quotidien à 6h00
- **Sources** : changedetection.io (watchlists lifecycle)

### Étapes
1. Récupération changedetection.io
2. Filtrage par mots-clés business impact (keywords-business-impact.yml)
3. Vérification dans stack-watchlist.yml
4. Extraction de la date d'échéance
5. Calcul du délai
6. Scoring d'urgence
7. Déduplication
8. Génération de l'alerte
9. Envoi de l'alerte (si urgence)
10. Ajout au digest hebdomadaire
11. Archivage

### Sortie
Alerte email avec :
- Technologie
- Date de fin de support
- Délai restant
- Criticité
- Actions recommandées

### Documentation détaillée
Voir `config/n8n/workflows-examples/surveillance-fin-support.md`

---

## Workflow 4 : Veille Éditeur

### Objectif
Surveiller les release notes, changelogs et security advisories des éditeurs pour détecter les breaking changes et les impacts possibles.

### Déclenchement
- **Type** : Polling
- **Fréquence** : Quotidien
- **Sources** : FreshRSS (flux éditeurs), changedetection.io (pages release notes)

### Étapes
1. Récupération des flux éditeurs
2. Récupération changedetection.io
3. Fusion des sources
4. Filtrage par éditeur (vendors-watchlist.yml)
5. Détection des breaking changes
6. Détection des security advisories
7. Classification par éditeur
8. Scoring d'impact
9. Génération d'un résumé par éditeur
10. Envoi par email ou canal interne
11. Archivage

### Sortie
Email structuré par éditeur avec :
- Nouvelles versions
- Breaking changes
- Security advisories
- Actions recommandées

---

## Workflow 5 : Veille Opportunités Technologiques

### Objectif
Identifier les outils open source intéressants et évaluer leur pertinence pour l'organisation.

### Déclenchement
- **Type** : Polling
- **Fréquence** : Hebdomadaire
- **Sources** : FreshRSS (flux open source, GitHub Trending)

### Étapes
1. Récupération des flux open source
2. Filtrage par catégories d'intérêt
3. Analyse de la maturité (stars, commits, issues)
4. Évaluation de la sécurité (security advisories)
5. Vérification de la compatibilité
6. Scoring d'intérêt
7. Génération d'une fiche courte
8. Envoi par email ou canal interne
9. Archivage

### Sortie
Fiche outil avec :
- Nom et description
- Catégorie
- Maturité
- Sécurité
- Compatibilité
- Score d'intérêt
- Lien

---

## Configuration Commune

### Credentials n8n
- FreshRSS API (Basic Auth)
- SMTP (Email)
- changedetection.io API
- Wallabag API
- Slack/Teams Webhook (optionnel)
- API gestion de tickets (optionnel)

### Fichiers de configuration
- `config/watchlists/stack-watchlist.yml`
- `config/watchlists/vendors-watchlist.yml`
- `config/watchlists/keywords-critical.yml`
- `config/watchlists/keywords-business-impact.yml`

### Scoring
Voir `docs/scoring-impact.md` pour les règles de scoring.

---

## Implémentation

### Étapes
1. Créer les workflows dans n8n
2. Configurer les credentials
3. Tester chaque workflow individuellement
4. Activer les workflows
5. Surveiller les exécutions
6. Ajuster les règles de filtrage

### Monitoring
- Vérifier les logs d'exécution n8n
- Surveiller les erreurs
- Ajuster les fréquences si nécessaire
- Mettre à jour les watchlists régulièrement

---

## Maintenance

### Mise à jour des watchlists
- Mettre à jour `stack-watchlist.yml` quand de nouvelles technologies sont adoptées
- Mettre à jour `vendors-watchlist.yml` quand de nouveaux éditeurs sont suivis
- Ajuster `keywords-critical.yml` et `keywords-business-impact.yml` selon les besoins

### Mise à jour des workflows
- Revoir les workflows mensuellement
- Ajuster les règles de scoring
- Ajouter de nouvelles sources si nécessaire
- Optimiser les performances

### Documentation
- Documenter les changements de workflows
- Garder un historique des versions
- Partager les bonnes pratiques
