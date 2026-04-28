# Installation Automatisée avec Ansible

## Prérequis

- Ansible installé sur la machine de contrôle
- Accès SSH aux serveurs cibles avec clés
- Sudo access sur les serveurs cibles

## Installation d'Ansible

Sur la machine de contrôle :

```bash
# Debian/Ubuntu
sudo apt install ansible

# Vérification
ansible --version
```

## Configuration

### 1. Configurer l'inventaire

```bash
cd ansible
cp inventory.example.ini inventory.ini
```

Éditer `inventory.ini` avec vos serveurs :

```ini
[veille]
server1.example.com ansible_user=your_user ansible_become=yes
server2.example.com ansible_user=your_user ansible_become=yes

[veille:vars]
ansible_python_interpreter=/usr/bin/python3
```

### 2. Configurer les variables

```bash
cp group_vars/veille.yml.example group_vars/veille.yml
```

Éditer `group_vars/veille.yml` avec vos variables :

```yaml
---
install_dir: /opt/veille-techno-cyber-interne
service_user: veille
service_group: veille
timezone: Europe/Paris
internal_domain: veille.local
```

## Lancement du playbook

### Installation complète

```bash
ansible-playbook -i inventory.ini playbook.yml
```

### Installation sélective

```bash
# Seulement l'installation de base
ansible-playbook -i inventory.ini playbook.yml --tags base

# Seulement Docker
ansible-playbook -i inventory.ini playbook.yml --tags docker

# Seulement la stack veille
ansible-playbook -i inventory.ini playbook.yml --tags veille_stack

# Seulement Nginx
ansible-playbook -i inventory.ini playbook.yml --tags nginx

# Seulement le durcissement
ansible-playbook -i inventory.ini playbook.yml --tags hardening
```

### Sur un serveur spécifique

```bash
ansible-playbook -i inventory.ini playbook.yml --limit server1.example.com
```

## Vérification

```bash
# Vérifier la connexion
ansible -i inventory.ini veille -m ping

# Vérifier l'état des containers
ansible -i inventory.ini veille -m shell -a "cd /opt/veille-techno-cyber-interne && docker compose ps" --become
```

## Rôles Ansible

### base
- Installation des paquets système
- Création de l'utilisateur veille
- Création de l'arborescence

### docker
- Installation de Docker
- Installation de Docker Compose plugin
- Activation de Docker

### veille_stack
- Copie des fichiers du projet
- Génération du .env
- Démarrage de la stack

### nginx
- Installation de Nginx
- Configuration des vhosts
- Activation des sites

### hardening
- Durcissement SSH
- Configuration UFW
- Règles de sécurité

## Personnalisation

### Ajouter des variables

Modifier `group_vars/veille.yml` pour ajouter vos propres variables.

### Ajouter des tâches

Modifier les fichiers `tasks/main.yml` dans chaque rôle pour ajouter des tâches personnalisées.

### Variables sensibles

Pour les secrets, utiliser Ansible Vault :

```bash
ansible-vault encrypt group_vars/veille_secrets.yml
ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass
```
