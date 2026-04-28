# Scoring d'Impact

## Critères

### Technologie utilisée chez nous
- **Score** : +30
- **Condition** : La technologie est listée dans `config/watchlists/stack-watchlist.yml` avec `used_in_company: true`

### Technologie critique
- **Score** : +20
- **Condition** : La technologie est marquée `criticality: critical` ou `criticality: high` dans `stack-watchlist.yml`

### CVE critique
- **Score** : +20
- **Condition** : CVSS >= 9.0

### Exploitation active
- **Score** : +25
- **Condition** : Preuve d'exploitation (PoC) disponible, exploits publics, ou attaques en cours

### Présence CISA KEV
- **Score** : +25
- **Condition** : La CVE est dans le catalogue CISA KEV (Known Exploited Vulnerabilities)

### Exposition Internet probable
- **Score** : +15
- **Condition** : La technologie est typiquement exposée sur Internet (serveurs web, reverse proxy, etc.)

### Données sensibles potentiellement concernées
- **Score** : +15
- **Condition** : La technologie gère des données sensibles (base de données, authentification, etc.)

### Fin de support proche
- **Score** : +15
- **Condition** : Fin de support dans moins de 6 mois

### Breaking change éditeur
- **Score** : +10
- **Condition** : L'éditeur annonce un changement cassant ou une migration obligatoire

### Simple article de tendance
- **Score** : +3
- **Condition** : Article d'actualité sans impact direct sur la stack

## Niveaux

### 0 à 29 : Information
- **Action** : Lecture informative
- **Urgence** : Faible
- **Exemple** : Article de blog sur une nouvelle fonctionnalité

### 30 à 59 : À surveiller
- **Action** : Suivi régulier
- **Urgence** : Moyenne
- **Exemple** : CVE avec CVSS 7.0 pour une technologie non critique

### 60 à 79 : Action recommandée
- **Action** : Planifier une action
- **Urgence** : Haute
- **Exemple** : CVE critique pour une technologie utilisée

### 80 à 100+ : Alerte prioritaire
- **Action** : Action immédiate
- **Urgence** : Critique
- **Exemple** : CVE en exploitation active pour une technologie critique

## Exemples

### Exemple 1 : CVE critique exploitation active
- Technologie : Windows Server (utilisé, critique)
- CVSS : 9.8
- Exploitation active : Oui
- CISA KEV : Oui
- Score : 30 + 20 + 20 + 25 + 25 = 120
- Niveau : Alerte prioritaire

### Exemple 2 : CVE élevée technologie non critique
- Technologie : Tool open source (non utilisé)
- CVSS : 7.5
- Exploitation active : Non
- Score : 3
- Niveau : Information

### Exemple 3 : Fin de support proche
- Technologie : Windows Server 2012 (utilisé, critique)
- Fin de support : Dans 3 mois
- Score : 30 + 20 + 15 = 65
- Niveau : Action recommandée

### Exemple 4 : Breaking change
- Technologie : PostgreSQL (utilisé)
- Breaking change : Oui
- Score : 30 + 10 = 40
- Niveau : À surveiller

## Implémentation dans n8n

Le scoring est implémenté dans les workflows n8n via un Function node qui :

1. Lit les fichiers de watchlist
2. Analyse le contenu de l'article
3. Applique les critères de scoring
4. Calcule le score total
5. Détermine le niveau
6. Classe l'article selon le niveau

## Personnalisation

Vous pouvez personnaliser le scoring en :
- Ajustant les scores des critères
- Ajoutant de nouveaux critères
- Modifiant les seuils des niveaux
- Adaptant les critères à votre contexte
