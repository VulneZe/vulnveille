# Workflow : Digest Quotidien

## Objectif

Générer un digest quotidien des articles de veille technologique et cyber-sécurité, filtrés par pertinence et classés par catégorie.

## Déclenchement

- **Type** : Cron
- **Fréquence** : Tous les matins à 8h00
- **Expression** : `0 8 * * *`

## Étapes du workflow

### 1. Déclenchement (Cron)
- Node : Schedule Trigger
- Configuration : Cron tous les jours à 8h00

### 2. Récupération des articles FreshRSS
- Node : HTTP Request
- Méthode : GET
- URL : `http://freshrss.veille.local/api/greader.php/api/reader/api/0/stream/contents/feed/`
- Authentication : Basic Auth (credentials FreshRSS)
- Headers :
  - `Accept: application/json`
- Sortie : Liste des articles

### 3. Filtrage par mots-clés critiques
- Node : Function
- Logique : Vérifier si le titre ou le contenu contient des mots-clés de `config/watchlists/keywords-critical.yml`
- Si mot-clé critique trouvé : Marquer comme priorité haute
- Sinon : Continuer

### 4. Classification par catégorie
- Node : Function
- Logique : Classifier les articles selon des catégories prédéfinies :
  - Vulnérabilités
  - Éditeurs
  - Cloud
  - DevSecOps
  - Réglementaire
  - Actualité générale
- Basé sur les tags FreshRSS ou analyse de contenu

### 5. Scoring d'impact
- Node : Function
- Logique : Calculer un score d'impact selon `docs/scoring-impact.md`
- Critères :
  - Technologie utilisée chez nous : +30
  - Technologie critique : +20
  - CVE critique : +20
  - Exploitation active : +25
  - Présence CISA KEV : +25
  - Exposition Internet probable : +15
  - Données sensibles potentiellement concernées : +15
  - Fin de support proche : +15
  - Breaking change éditeur : +10
  - Simple article de tendance : +3
- Niveaux :
  - 0-29 : information
  - 30-59 : à surveiller
  - 60-79 : action recommandée
  - 80-100+ : alerte prioritaire

### 6. Vérification dans stack-watchlist
- Node : Function
- Logique : Vérifier si l'article mentionne une technologie de `config/watchlists/stack-watchlist.yml`
- Si oui : Augmenter le score de +20
- Si technologie marquée "criticality: critical" : Augmenter de +10 supplémentaires

### 7. Génération du résumé
- Node : Function
- Logique : Générer un résumé structuré :
  - Titre de l'article
  - Source
  - Date
  - Catégorie
  - Score d'impact
  - Résumé (si disponible)
  - Lien vers l'article

### 8. Formatage du digest
- Node : Function
- Logique : Formater le digest en HTML ou Markdown :
  - Section alertes prioritaires (score 80+)
  - Section actions recommandées (score 60-79)
  - Section à surveiller (score 30-59)
  - Section information (score 0-29)

### 9. Envoi par email
- Node : Send Email
- Configuration :
  - SMTP credentials
  - Destinataires : Liste de diffusion veille
  - Sujet : `[Veille] Digest Quotidien - {{ date }}`
  - Corps : Digest formaté
  - Pièce jointe : Optionnel (CSV des articles)

### 10. Archivage
- Node : HTTP Request
- Méthode : POST
- URL : API Wallabag
- Action : Sauvegarder les articles avec score 60+ dans Wallabag
- Tags : `veille`, `digest`, `prioritaire`

### 11. Notification n8n (optionnel)
- Node : Slack ou Teams
- Envoi d'une notification sur un canal dédié
- Message : "Digest quotidien envoyé - X articles prioritaires"

## Configuration requise

- Credentials FreshRSS (API)
- Credentials SMTP (email)
- Credentials Wallabag (API)
- Accès aux fichiers de watchlist (via Function node avec lecture de fichier)

## Personnalisation

- Adapter les catégories à vos besoins
- Ajuster les seuils de scoring
- Modifier la fréquence du cron
- Ajouter d'autres canaux de notification (Slack, Teams, Mattermost)
- Personnaliser le template du digest

## Exemple de sortie

```
Subject: [Veille] Digest Quotidien - 2024-01-15

## Alertes Prioritaires (Score 80+)

### CVE-2024-1234 - RCE dans Windows Server
- Score : 95
- Source : Microsoft Security Blog
- Exploitation active : Oui
- Présence CISA KEV : Oui
- Lien : https://...

## Actions Recommandées (Score 60-79)

### Fin de support Windows Server 2012
- Score : 65
- Source : Microsoft Lifecycle
- Échéance : 2024-10-10
- Lien : https://...

## À Surveiller (Score 30-59)

### Nouvelle fonctionnalité Kubernetes 1.29
- Score : 35
- Source : Kubernetes Blog
- Lien : https://...
```
