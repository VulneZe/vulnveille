# Sécurisation Linux

## Prérequis

- Debian 12 ou Ubuntu Server LTS recommandé
- Accès root ou sudo

## Utilisateur

### Créer un utilisateur non-root

```bash
# L'utilisateur veille est créé par install.sh
# Pour d'autres utilisateurs :
sudo adduser admin
sudo usermod -aG sudo admin
```

### SSH avec clés

```bash
# Sur la machine locale
ssh-keygen -t ed25519

# Copier la clé publique sur le serveur
ssh-copy-id admin@server
```

### Désactiver le login root SSH

```bash
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart ssh
```

### Désactiver l'authentification par mot de passe SSH

```bash
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh
```

## Firewall

### UFW (Uncomplicated Firewall)

```bash
# Installer UFW
sudo apt install ufw

# Politique par défaut
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Autoriser SSH
sudo ufw allow 22/tcp

# Autoriser HTTP et HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Activer UFW
sudo ufw enable

# Vérifier
sudo ufw status verbose
```

### Limiter les IP autorisées

```bash
# Autoriser uniquement des IP spécifiques
sudo ufw allow from 192.168.1.0/24 to any port 22
sudo ufw allow from 192.168.1.0/24 to any port 80
sudo ufw allow from 192.168.1.0/24 to any port 443
```

Voir `docs/firewall.md` pour plus de détails.

## Mises à jour automatiques

### Unattended Upgrades

```bash
# Installer
sudo apt install unattended-upgrades

# Configurer
sudo dpkg-reconfigure -plow unattended-upgrades
```

### Configuration manuelle

Éditer `/etc/apt/apt.conf.d/50unattended-upgrades` :

```
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
```

## Logs

### Centralisation des logs

Configurer l'envoi des logs vers un système centralisé (rsyslog, Graylog, ELK).

### Rotation des logs

```bash
# Installer logrotate
sudo apt install logrotate
```

Configurer `/etc/logrotate.d/docker` :

```
/var/lib/docker/containers/*/*.log {
    rotate 7
    daily
    compress
    missingok
    delaycompress
    copytruncate
}
```

## Permissions

### Permissions sur les dossiers data

```bash
sudo chown -R veille:veille /opt/veille-techno-cyber-interne/data/
sudo chmod -R 750 /opt/veille-techno-cyber-interne/data/
```

### Permissions sur .env

```bash
sudo chmod 600 /opt/veille-techno-cyber-interne/.env
```

## Séparation réseau

### VLAN admin

Placer le serveur dans un VLAN admin dédié avec accès restreint.

### VPN

Accéder au serveur uniquement via VPN d'entreprise.

## Fail2ban (optionnel)

```bash
# Installer
sudo apt install fail2ban

# Configurer
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

## Audit

### Auditd

```bash
# Installer
sudo apt install auditd

# Configurer
sudo auditctl -w /opt/veille-techno-cyber-interne/.env -p wa -k veille_env
```

## Vérification

### Script de vérification

```bash
cd /opt/veille-techno-cyber-interne
make hardening-check
# ou
sudo bash scripts/hardening-check.sh
```

## Références

- [CIS Ubuntu Linux Benchmark](https://www.cisecurity.org/benchmark/ubuntu_linux)
- [ANSSI - Recommandations de sécurité](https://www.ssi.gouv.fr/guide/recommandations-de-securite-relatives-a-un-systeme-dexploitation-linux/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
