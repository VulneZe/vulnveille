# Veille Vulnérabilités

## Pourquoi intégrer la veille vulnérabilités

La veille vulnérabilités est essentielle pour :
- Détecter les CVE critiques affectant votre stack
- Prioriser les correctifs
- Réduire le risque d'exploitation
- Maintenir la conformité réglementaire

## Sources recommandées

### CISA KEV (Known Exploited Vulnerabilities)
- **URL** : https://www.cisa.gov/known-exploited-vulnerabilities-catalog
- **Description** : Catalogue des vulnérabilités exploitées activement
- **Fréquence** : Quotidienne
- **Importance** : Critique

### CERT-FR
- **RSS** : https://www.cert.ssi.gouv.fr/feed/
- **Description** : Alertes et avis de sécurité du CERT-FR
- **Fréquence** : Quotidienne
- **Importance** : Critique pour la France

### NVD (National Vulnerability Database)
- **RSS** : https://nvd.nist.gov/vuln/data-feeds
- **Description** : Base de données nationale des vulnérabilités (USA)
- **Fréquence** : Quotidienne
- **Importance** : Haute

### OSV.dev
- **RSS** : https://osv.dev/feed.xml
- **Description** : Open Source Vulnerabilities
- **Fréquence** : Quotidienne
- **Importance** : Haute pour open source

### GitHub Security Advisories
- **RSS** : https://github.com/advisories/feed
- **Description** : Advisories de sécurité GitHub
- **Fréquence** : Quotidienne
- **Importance** : Haute pour GitHub

### Advisories éditeurs
- Microsoft Security Response Center
- Cisco Security Advisories
- Fortinet PSIRT
- Palo Alto Security Advisories
- VMware/Broadcom Security Advisories

## Différence entre CVSS, KEV et exploitation active

### CVSS (Common Vulnerability Scoring System)
- Score de 0 à 10
- Mesure la gravité technique
- Ne mesure pas l'exploitation réelle
- CVSS 9.0+ = critique

### KEV (Known Exploited Vulnerabilities)
- Liste CISA des vulnérabilités exploitées activement
- Preuve d'exploitation dans la nature
- Priorité maximale pour correction

### Exploitation active
- Preuve d'exploitation (PoC) disponible
- Exploits publics
- Attaques en cours
- Priorité élevée pour correction

## Logique de scoring

Voir `docs/scoring-impact.md` pour les règles de scoring détaillées.

### Critères

- Technologie utilisée chez nous : +30
- Technologie critique : +20
- CVE critique (CVSS 9+) : +20
- Exploitation active : +25
- Présence CISA KEV : +25
- Exposition Internet probable : +15
- Données sensibles potentiellement concernées : +15
- Fin de support proche : +15
- Breaking change éditeur : +10
- Simple article de tendance : +3

### Niveaux

- 0 à 29 : information
- 30 à 59 : à surveiller
- 60 à 79 : action recommandée
- 80 à 100+ : alerte prioritaire

## Comment éviter le bruit

### Filtrage par stack-watchlist

Utiliser `config/watchlists/stack-watchlist.yml` pour filtrer uniquement les technologies utilisées.

### Filtrage par criticité

Ignorer les CVE avec CVSS < 7.0 pour les technologies non critiques.

### Filtrage par éditeur

Prioriser les éditeurs critiques (Microsoft, Cisco, Fortinet, etc.).

### Déduplication

Éviter les doublons en utilisant l'ID CVE unique.

## Comment relier une CVE à la stack interne

### Vérification automatique

Le workflow n8n vérifie automatiquement si la CVE mentionne une technologie de `stack-watchlist.yml`.

### Vérification manuelle

1. Lire l'advisory de la CVE
2. Identifier les produits affectés
3. Comparer avec `stack-watchlist.yml`
4. Vérifier si la version est utilisée
5. Évaluer l'exposition

## Intégration OpenCVE ou Vulnerability-Lookup (V1.5)

### OpenCVE

OpenCVE est une plateforme de veille vulnérabilités open source.

**Avantages** :
- Agrégation de multiples sources
- Filtrage par produits
- API pour intégration
- Notifications personnalisées

**Inconvénients** :
- Installation complexe
- Ressources importantes

### Vulnerability-Lookup

Vulnerability-Lookup est une alternative plus légère.

**Avantages** :
- Installation simple
- Ressources réduites
- API REST
- Intégration facile

**Inconvénients** :
- Moins de fonctionnalités
- Communauté plus petite

### Choix

Pour V1.5, recommandation : Vulnerability-Lookup pour sa simplicité d'intégration.

## Workflow d'alerte CVE

Voir `config/n8n/workflows-examples/alerte-cve-critique.md` pour le workflow détaillé.

### Étapes

1. Récupération des flux CVE
2. Filtrage par mots-clés critiques
3. Vérification dans stack-watchlist
4. Vérification CISA KEV
5. Vérification CVSS
6. Calcul du score de priorité
7. Déduplication
8. Génération de l'alerte
9. Envoi de l'alerte immédiate
10. Création de ticket (optionnel)
11. Archivage

## Documentation

Documenter :
- Les CVE traitées
- Les correctifs appliqués
- Les décisions de priorité
- Les leçons apprises
