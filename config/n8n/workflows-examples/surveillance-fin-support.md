# Workflow : Surveillance Fin de Support

## Objectif

Surveiller les pages de lifecycle des éditeurs pour détecter les fins de support et générer des alertes avant les échéances critiques.

## Déclenchement

- **Type** : Polling
- **Fréquence** : Quotidien à 6h00
- **Sources** : changedetection.io (watchlists lifecycle)

## Étapes du workflow

### 1. Déclenchement (Cron)
- Node : Schedule Trigger
- Configuration : Tous les jours à 6h00

### 2. Récupération changedetection.io
- Node : HTTP Request
- Méthode : GET
- URL : API changedetection.io
- Authentication : API Key
- Filtre : Watchlists "lifecycle", "end of support", "EOL"
- Sortie : Liste des changements détectés

### 3. Filtrage par mots-clés business impact
- Node : Function
- Logique : Vérifier si le changement contient des mots-clés de `config/watchlists/keywords-business-impact.yml`
- Mots-clés :
  - end of support
  - end of life
  - deprecated
  - migration required
  - EOL
  - EOS

### 4. Vérification dans stack-watchlist
- Node : Function
- Logique : Vérifier si la technologie est dans `config/watchlists/stack-watchlist.yml`
- Si oui : Marquer comme pertinent
- Récupérer la criticité de la technologie

### 5. Extraction de la date d'échéance
- Node : Function
- Logique : Extraire la date de fin de support depuis le contenu
- Formats supportés :
  - YYYY-MM-DD
  - Month YYYY
  - Quarter YYYY
- Si pas de date : Marquer comme "à vérifier manuellement"

### 6. Calcul du délai
- Node : Function
- Logique : Calculer le nombre de jours/jours/mois avant l'échéance
- Aujourd'hui vs date d'échéance

### 7. Scoring d'urgence
- Node : Function
- Logique : Calculer un score d'urgence :
  - Échéance < 30 jours : +50
  - Échéance < 90 jours : +30
  - Échéance < 180 jours : +15
  - Échéance < 365 jours : +5
  - Technologie critique : +20
  - Technologie utilisée chez nous : +30
- Niveaux :
  - 0-29 : Information
  - 30-59 : À planifier
  - 60-79 : Action requise
  - 80-100+ : Urgent

### 8. Déduplication
- Node : Function
- Logique : Vérifier si cette fin de support a déjà été alertée
- Stockage : Base de données ou fichier JSON
- Si déjà alerté : Mettre à jour si le délai a changé significativement

### 9. Génération de l'alerte
- Node : Function
- Logique : Générer un message d'alerte structuré :
  - Technologie
  - Éditeur
  - Date de fin de support
  - Délai restant
  - Criticité
  - Actions recommandées
  - Liens vers les informations officielles

### 10. Envoi de l'alerte (si urgence)
- Node : Send Email
- Condition : Score >= 60
- Configuration :
  - SMTP credentials
  - Destinataires : Liste infrastructure@company.com
  - Sujet : `[Fin Support] {{ technologie }} - Échéance {{ date }}`
  - Corps : Alert formatée

### 11. Ajout au digest hebdomadaire
- Node : Function
- Logique : Ajouter les fins de support (score < 60) à une liste pour le digest hebdomadaire
- Stockage : Fichier JSON ou base de données

### 12. Archivage
- Node : Function
- Logique : Enregistrer l'alerte dans un fichier JSON ou base de données
- But : Éviter les doublons et historique

## Configuration requise

- Credentials changedetection.io (API)
- Credentials SMTP (email)
- Accès aux fichiers de watchlist

## Personnalisation

- Adapter les seuils de scoring
- Modifier la fréquence de polling
- Ajouter d'autres canaux de notification
- Personnaliser le template d'alerte
- Ajouter des règles de déduplication plus avancées

## Exemple d'alerte

```
Subject: [Fin Support] Windows Server 2012 - Échéance 2024-10-10

## Détails

**Technologie** : Windows Server 2012
**Éditeur** : Microsoft
**Date de fin de support** : 2024-10-10
**Délai restant** : 240 jours
**Criticité** : Critique
**Score d'urgence** : 75

## Impact

Windows Server 2012 atteindra sa fin de support le 10 octobre 2024. Après cette date, plus aucune mise à jour de sécurité ne sera publiée.

## Actions recommandées

1. Planifier la migration vers Windows Server 2019 ou 2022
2. Inventorier les serveurs Windows Server 2012
3. Évaluer la compatibilité des applications
4. Prévoir le budget de migration
5. Communiquer avec les métiers concernés

## Liens

- Microsoft Lifecycle : https://learn.microsoft.com/...
- Guide de migration : https://...

## Statut

- Inventaire : En cours
- Migration planifiée : Non
- Ticket : INFRA-5678
```
