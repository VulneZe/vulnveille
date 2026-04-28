#!/bin/bash
# Script d'installation automatique de la plateforme de veille techno-cyber
# Ce script installe Docker, configure l'environnement et déploie la stack
# Nécessite : sudo ou root
# OS supportés : Debian 12, Ubuntu Server LTS

set -euo pipefail

# ============================================================================
# Variables
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/opt/veille-techno-cyber-interne"
SERVICE_USER="veille"
PROJECT_NAME="veille-techno-cyber-interne"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# Fonctions utilitaires
# ============================================================================
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Ce script doit être exécuté avec sudo ou en tant que root"
        exit 1
    fi
}

detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
    else
        log_error "Impossible de détecter l'OS"
        exit 1
    fi

    if [[ "$OS" != "debian" && "$OS" != "ubuntu" ]]; then
        log_error "OS non supporté : $OS. Seuls Debian et Ubuntu sont supportés."
        exit 1
    fi

    log_info "OS détecté : $OS $OS_VERSION"
}

install_dependencies() {
    log_info "Installation des dépendances système..."
    apt-get update -qq
    apt-get install -y -qq curl git wget ca-certificates gnupg lsb-release
    log_success "Dépendances installées"
}

install_docker() {
    log_info "Vérification de l'installation de Docker..."
    
    if command -v docker &> /dev/null; then
        log_success "Docker est déjà installé : $(docker --version)"
    else
        log_info "Installation de Docker..."
        
        # Ajout de la clé GPG Docker
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/${OS}/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg
        
        # Ajout du repository Docker
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${OS} \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
          tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        apt-get update -qq
        apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        log_success "Docker installé : $(docker --version)"
    fi

    # Vérification de Docker Compose
    if docker compose version &> /dev/null; then
        log_success "Docker Compose plugin installé : $(docker compose version)"
    else
        log_error "Docker Compose plugin n'est pas installé correctement"
        exit 1
    fi

    # Activation de Docker
    systemctl enable docker
    systemctl start docker
    log_success "Docker activé et démarré"
}

create_service_user() {
    log_info "Création de l'utilisateur système $SERVICE_USER..."
    
    if id "$SERVICE_USER" &>/dev/null; then
        log_warning "L'utilisateur $SERVICE_USER existe déjà"
    else
        useradd -r -s /bin/bash -d "$INSTALL_DIR" "$SERVICE_USER"
        log_success "Utilisateur $SERVICE_USER créé"
    fi
}

create_directory_structure() {
    log_info "Création de l'arborescence dans $INSTALL_DIR..."
    
    mkdir -p "$INSTALL_DIR"
    cp -r "$SCRIPT_DIR"/* "$INSTALL_DIR/"
    
    # Création des dossiers data
    mkdir -p "$INSTALL_DIR/data/freshrss"
    mkdir -p "$INSTALL_DIR/data/n8n"
    mkdir -p "$INSTALL_DIR/data/changedetection"
    mkdir -p "$INSTALL_DIR/data/wallabag"
    mkdir -p "$INSTALL_DIR/data/postgres"
    mkdir -p "$INSTALL_DIR/data/backups"
    
    # Permissions
    chown -R "$SERVICE_USER:$SERVICE_USER" "$INSTALL_DIR"
    chmod -R 750 "$INSTALL_DIR/data"
    
    log_success "Arborescence créée avec les permissions correctes"
}

generate_env() {
    log_info "Génération du fichier .env..."
    
    if [[ -f "$INSTALL_DIR/.env" ]]; then
        log_warning "Le fichier .env existe déjà, conservation de l'existant"
    else
        cp "$INSTALL_DIR/.env.example" "$INSTALL_DIR/.env"
        
        # Génération des secrets forts
        POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
        N8N_BASIC_AUTH_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
        N8N_ENCRYPTION_KEY=$(openssl rand -base64 48 | tr -d "=+/" | cut -c1-48)
        WALLABAG_SECRET=$(openssl rand -base64 48 | tr -d "=+/" | cut -c1-48)
        WALLABAG_DATABASE_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
        FRESHRSS_ADMIN_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
        
        # Remplacement des secrets dans .env
        sed -i "s/CHANGEZ_CECI_MOT_DE_PASSE_FORT_POSTGRES/$POSTGRES_PASSWORD/" "$INSTALL_DIR/.env"
        sed -i "s/CHANGEZ_CECI_MOT_DE_PASSE_FORT_N8N/$N8N_BASIC_AUTH_PASSWORD/" "$INSTALL_DIR/.env"
        sed -i "s/CHANGEZ_CECI_CLE_DE_CHIFFREMENT_N8N_MIN_32_CARACTERES/$N8N_ENCRYPTION_KEY/" "$INSTALL_DIR/.env"
        sed -i "s/CHANGEZ_CECI_SECRET_WALLABAG_MIN_32_CARACTERES/$WALLABAG_SECRET/" "$INSTALL_DIR/.env"
        sed -i "s/CHANGEZ_CECI_MOT_DE_PASSE_FORT_WALLABAG/$WALLABAG_DATABASE_PASSWORD/" "$INSTALL_DIR/.env"
        sed -i "s/CHANGEZ_CECI_MOT_DE_PASSE_FORT_FRESHRSS/$FRESHRSS_ADMIN_PASSWORD/" "$INSTALL_DIR/.env"
        
        chmod 600 "$INSTALL_DIR/.env"
        chown "$SERVICE_USER:$SERVICE_USER" "$INSTALL_DIR/.env"
        
        log_success "Fichier .env généré avec des secrets forts"
    fi
}

display_manual_config() {
    log_warning "Variables à vérifier/modifier manuellement dans $INSTALL_DIR/.env :"
    echo ""
    echo "  - N8N_BASIC_AUTH_USER (actuellement: admin)"
    echo "  - INTERNAL_DOMAIN (actuellement: veille.local)"
    echo "  - FQDN des services (freshrss.veille.local, etc.)"
    echo "  - Configuration SMTP si nécessaire"
    echo ""
}

start_stack() {
    log_info "Démarrage de la stack Docker Compose..."
    
    cd "$INSTALL_DIR"
    sudo -u "$SERVICE_USER" docker compose up -d
    
    log_success "Stack démarrée"
}

check_health() {
    log_info "Vérification de la santé de la stack..."
    
    if [[ -f "$INSTALL_DIR/scripts/check-health.sh" ]]; then
        cd "$INSTALL_DIR"
        sudo -u "$SERVICE_USER" bash scripts/check-health.sh
    else
        log_warning "Script check-health.sh non trouvé"
    fi
}

display_urls() {
    log_info "URLs internes à configurer dans le DNS :"
    echo ""
    echo "  - http://freshrss.veille.local"
    echo "  - http://n8n.veille.local"
    echo "  - http://changes.veille.local"
    echo "  - http://wallabag.veille.local"
    echo ""
    log_warning "Pour un test local, ajoutez ces entrées dans /etc/hosts :"
    echo "  127.0.0.1 freshrss.veille.local n8n.veille.local changes.veille.local wallabag.veille.local"
    echo ""
}

display_security_warning() {
    log_warning "IMPORTANT : Rappels de sécurité"
    echo ""
    echo "  - Les services NE DOIVENT PAS être exposés sur Internet"
    echo "  - Utilisez un VPN ou un VLAN admin pour l'accès"
    echo "  - Configurez le firewall (voir docs/firewall.md)"
    echo "  - Configurez Nginx reverse proxy (voir docs/reverse-proxy-nginx.md)"
    echo "  - Configurez TLS interne (voir docs/tls-interne.md)"
    echo "  - Exécutez le durcissement : make hardening-check"
    echo "  - Sauvegardez le fichier .env dans un endroit sécurisé"
    echo ""
}

# ============================================================================
# Main
# ============================================================================
main() {
    echo "=========================================================================="
    echo "  Installation de la plateforme de veille techno-cyber"
    echo "=========================================================================="
    echo ""
    
    check_root
    detect_os
    install_dependencies
    install_docker
    create_service_user
    create_directory_structure
    generate_env
    display_manual_config
    start_stack
    check_health
    display_urls
    display_security_warning
    
    log_success "Installation terminée avec succès !"
    echo ""
    echo "Prochaines étapes :"
    echo "  1. Vérifiez/modifiez $INSTALL_DIR/.env"
    echo "  2. Configurez le DNS interne"
    echo "  3. Configurez Nginx reverse proxy"
    echo "  4. Exécutez : cd $INSTALL_DIR && make hardening-check"
    echo ""
}

main "$@"
