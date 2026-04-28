#!/bin/bash
# Script de vérification du durcissement de sécurité
# Vérifie la configuration système et Docker

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

echo "=========================================================================="
echo "  Vérification du durcissement de sécurité"
echo "=========================================================================="
echo ""

# Vérification SSH root
log_info "Vérification de la configuration SSH..."
if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config 2>/dev/null; then
    log_success "Login root SSH désactivé"
elif grep -q "^PermitRootLogin.*no" /etc/ssh/sshd_config 2>/dev/null; then
    log_success "Login root SSH désactivé"
else
    log_warning "Login root SSH可能 activé (vérifiez /etc/ssh/sshd_config)"
fi

if grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config 2>/dev/null; then
    log_success "Authentification par mot de passe SSH désactivée"
else
    log_warning "Authentification par mot de passe SSH可能 activée"
fi

# Vérification firewall
log_info "Vérification du firewall..."
if command -v ufw &> /dev/null; then
    if ufw status | grep -q "Status: active"; then
        log_success "UFW est actif"
    else
        log_error "UFW n'est pas actif"
    fi
elif command -v nft &> /dev/null; then
    if nft list ruleset 2>/dev/null | grep -q .; then
        log_success "nftables a des règles configurées"
    else
        log_warning "nftables installé mais pas de règles configurées"
    fi
else
    log_warning "Aucun firewall détecté (UFW ou nftables)"
fi

# Vérification Docker
log_info "Vérification de Docker..."
if command -v docker &> /dev/null; then
    log_success "Docker est installé"
else
    log_error "Docker n'est pas installé"
fi

# Vérification utilisateur non-root
log_info "Vérification de l'utilisateur actuel..."
if [[ $EUID -eq 0 ]]; then
    log_warning "Exécuté en tant que root (normal pour ce script)"
else
    log_success "Exécuté en tant qu'utilisateur non-root"
fi

# Vérification permissions du dossier
INSTALL_DIR="/opt/veille-techno-cyber-interne"
if [[ -d "$INSTALL_DIR" ]]; then
    log_info "Vérification des permissions de $INSTALL_DIR..."
    OWNER=$(stat -c %U "$INSTALL_DIR" 2>/dev/null || stat -f %Su "$INSTALL_DIR" 2>/dev/null)
    PERMS=$(stat -c %a "$INSTALL_DIR" 2>/dev/null || stat -f %A "$INSTALL_DIR" 2>/dev/null)
    
    if [[ "$OWNER" == "veille" ]]; then
        log_success "Propriétaire correct : veille"
    else
        log_warning "Propriétaire incorrect : $OWNER (devrait être veille)"
    fi
    
    if [[ "$PERMS" == "750" ]]; then
        log_success "Permissions correctes : 750"
    else
        log_warning "Permissions incorrectes : $PERMS (devraient être 750)"
    fi
else
    log_warning "Répertoire d'installation non trouvé : $INSTALL_DIR"
fi

# Vérification exposition réseau
log_info "Vérification de l'exposition réseau..."
if netstat -tuln 2>/dev/null | grep -q "0.0.0.0:5432"; then
    log_error "PostgreSQL exposé sur 0.0.0.0:5432 (DANGER !)"
elif netstat -tuln 2>/dev/null | grep -q "127.0.0.1:5432"; then
    log_success "PostgreSQL exposé uniquement sur localhost"
else
    log_success "PostgreSQL non exposé"
fi

# Vérification présence du .env
if [[ -f "$INSTALL_DIR/.env" ]]; then
    log_info "Vérification du fichier .env..."
    log_success "Fichier .env existe"
    
    PERMS=$(stat -c %a "$INSTALL_DIR/.env" 2>/dev/null || stat -f %A "$INSTALL_DIR/.env" 2>/dev/null)
    if [[ "$PERMS" == "600" ]]; then
        log_success "Permissions .env correctes : 600"
    else
        log_error "Permissions .env incorrectes : $PERMS (devraient être 600)"
    fi
else
    log_warning "Fichier .env non trouvé"
fi

# Vérification absence de secrets dans Git
if [[ -d "$INSTALL_DIR/.git" ]]; then
    log_info "Vérification de l'absence de secrets dans Git..."
    if git -C "$INSTALL_DIR" log --all --full-history -- .env 2>/dev/null | grep -q .; then
        log_error "Le fichier .env a été commité dans Git (DANGER !)"
    else
        log_success "Aucun secret détecté dans Git"
    fi
fi

# Vérification services accessibles
log_info "Vérification de l'accessibilité des services..."
if netstat -tuln 2>/dev/null | grep -q "0.0.0.0:80"; then
    log_warning "Port 80 exposé sur 0.0.0.0 (vérifiez que c'est intentionnel)"
elif netstat -tuln 2>/dev/null | grep -q "127.0.0.1:80"; then
    log_success "Port 80 exposé uniquement sur localhost"
fi

if netstat -tuln 2>/dev/null | grep -q "0.0.0.0:443"; then
    log_warning "Port 443 exposé sur 0.0.0.0 (vérifiez que c'est intentionnel)"
elif netstat -tuln 2>/dev/null | grep -q "127.0.0.1:443"; then
    log_success "Port 443 exposé uniquement sur localhost"
fi

echo ""
log_info "Vérification terminée"
echo ""
log_warning "Pour un durcissement complet, consultez :"
echo "  - docs/securisation-linux.md"
echo "  - docs/firewall.md"
echo "  - docs/reverse-proxy-nginx.md"
echo "  - docs/tls-interne.md"
echo ""
