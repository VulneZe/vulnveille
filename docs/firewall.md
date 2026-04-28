# Firewall

## Règles de base

### Politique par défaut

Bloquer tout par défaut, autoriser uniquement les flux nécessaires.

## UFW (Uncomplicated Firewall)

### Installation

```bash
sudo apt install ufw
```

### Configuration de base

```bash
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

### Règles pour test local

```bash
# Autoriser tout en local (déconseillé en prod)
sudo ufw allow from 192.168.1.0/24
sudo ufw allow from 10.0.0.0/8
```

### Règles pour serveur interne

```bash
# Autoriser uniquement IP admin
sudo ufw allow from 192.168.1.100 to any port 22
sudo ufw allow from 192.168.1.100 to any port 80
sudo ufw allow from 192.168.1.100 to any port 443

# Autoriser réseau interne
sudo ufw allow from 192.168.1.0/24 to any port 80
sudo ufw allow from 192.168.1.0/24 to any port 443
```

### Bloquer Internet entrant

```bash
# UFW bloque déjà par défaut
# Vérifier avec :
sudo ufw status verbose
```

### Autoriser flux sortants nécessaires

```bash
# UFW autorise déjà par défaut
# Pour restreindre :
sudo ufw default deny outgoing
sudo ufw allow out 53   # DNS
sudo ufw allow out 80   # HTTP
sudo ufw allow out 443  # HTTPS
sudo ufw allow out 123  # NTP
```

### Limiter SSH

```bash
# Limiter les tentatives de connexion SSH
sudo ufw limit 22/tcp
```

## nftables

### Installation

```bash
sudo apt install nftables
```

### Configuration de base

Créer `/etc/nftables.conf` :

```nft
#!/usr/sbin/nft -f
flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        # Accepter les connexions établies
        ct state established,related accept

        # Accepter loopback
        iif lo accept

        # Accepter SSH
        tcp dport 22 accept

        # Accepter HTTP et HTTPS
        tcp dport {80, 443} accept

        # Accepter ICMP
        icmp type echo-request accept
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
```

Activer :

```bash
sudo nft -f /etc/nftables.conf
sudo systemctl enable nftables
```

## Règles recommandées

### Pour serveur interne

```bash
# Autoriser SSH depuis IP admin
sudo ufw allow from 192.168.1.100 to any port 22

# Autoriser HTTP/HTTPS depuis réseau interne
sudo ufw allow from 192.168.1.0/24 to any port 80
sudo ufw allow from 192.168.1.0/24 to any port 443

# Bloquer tout le reste
sudo ufw default deny incoming
```

### Pour serveur avec VPN

```bash
# Autoriser SSH depuis VPN
sudo ufw allow from 10.8.0.0/24 to any port 22

# Autoriser HTTP/HTTPS depuis VPN
sudo ufw allow from 10.8.0.0/24 to any port 80
sudo ufw allow from 10.8.0.0/24 to any port 443
```

## Vérification

```bash
# UFW
sudo ufw status verbose

# nftables
sudo nft list ruleset
```

## Logs

```bash
# Activer les logs UFW
sudo ufw logging on

# Voir les logs
sudo tail -f /var/log/ufw.log
```

## Références

- [UFW Documentation](https://help.ubuntu.com/community/UFW)
- [nftables Documentation](https://wiki.nftables.org/)
