# Ansible Installation

Ce dossier contient les playbooks Ansible pour l'installation automatisée de la plateforme de veille techno-cyber.

## Prérequis

- Ansible installé sur la machine de contrôle
- Accès SSH aux serveurs cibles avec clés
- Sudo access sur les serveurs cibles

## Installation

1. Configurer l'inventaire :
```bash
cp inventory.example.ini inventory.ini
# Éditer inventory.ini avec vos serveurs
```

2. Configurer les variables :
```bash
cp group_vars/veille.yml.example group_vars/veille.yml
# Éditer group_vars/veille.yml avec vos variables
```

3. Lancer le playbook :
```bash
ansible-playbook -i inventory.ini playbook.yml
```

## Rôles

- **base** : Installation des paquets système et création de l'utilisateur
- **docker** : Installation de Docker et Docker Compose
- **veille_stack** : Déploiement de la stack Docker Compose
- **nginx** : Configuration du reverse proxy Nginx
- **hardening** : Durcissement de sécurité
