#!/bin/bash
# Script de désinstallation de la plateforme de veille techno-cyber
# Ce script arrête les containers et propose de supprimer les données
# Nécessite : sudo ou root

set -euo pipefail

# ============================================================================
# Variables
# ============================================================================
INSTALL_DIR="/opt/veille-techno-cyber-interne"
SERVICE_USER="veille"

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

confirm() {
    read -p "$1 (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Opération annulée"
        exit 0
    fi
}

stop_containers() {
    log_info "Arrêt des containers..."
    
    if [[ -d "$INSTALL_DIR" ]]; then
        cd "$INSTALL_DIR"
        if docker compose down &> /dev/null; then
            log_success "Containers arrêtés"
        else
            log_warning "Impossible d'arrêter les containers (peut-être déjà arrêtés)"
        fi
    else
        log_warning "Répertoire d'installation non trouvé : $INSTALL_DIR"
    fi
}

remove_data() {
    log_warning "ATTENTION : Cette action va supprimer TOUTES les données"
    log_warning "Les données incluent :"
    log_warning "  - Base de données PostgreSQL"
    log_warning "  - Configuration FreshRSS"
    log_warning "  - Workflows n8n"
    log_warning "  - Données changedetection.io"
    log_warning "  - Articles Wallabag"
    log_warning "  - Sauvegardes"
    echo ""
    
    confirm "Êtes-vous ABSOLUMENT certain de vouloir supprimer les données ?"
    
    confirm "Dernière chance : Confirmer la suppression des données dans $INSTALL_DIR/data ?"
    
    log_info "Suppression des données..."
    rm -rf "$INSTALL_DIR/data"
    log_success "Données supprimées"
}

remove_installation() {
    log_info "Suppression de l'installation..."
    
    confirm "Supprimer le répertoire d'installation $INSTALL_DIR ?"
    
    rm -rf "$INSTALL_DIR"
    log_success "Installation supprimée"
}

remove_user() {
    log_info "Suppression de l'utilisateur système $SERVICE_USER..."
    
    if id "$SERVICE_USER" &>/dev/null; then
        confirm "Supprimer l'utilisateur système $SERVICE_USER ?"
        userdel "$SERVICE_USER"
        log_success "Utilisateur $SERVICE_USER supprimé"
    else
        log_warning "L'utilisateur $SERVICE_USER n'existe pas"
    fi
}

remove_docker() {
    log_info "Désinstallation de Docker..."
    
    confirm "Voulez-vous désinstaller Docker ? (non recommandé si utilisé par d'autres services)"
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        apt-get remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        rm -rf /var/lib/docker
        rm -rf /etc/docker
        log_success "Docker désinstallé"
    else
        log_info "Docker conservé"
    fi
}

# ============================================================================
# Main
# ============================================================================
main() {
    echo "=========================================================================="
    echo "  Désinstallation de la plateforme de veille techno-cyber"
    echo "=========================================================================="
    echo ""
    
    check_root
    
    if [[ ! -d "$INSTALL_DIR" ]]; then
        log_error "Installation non trouvée : $INSTALL_DIR"
        exit 1
    fi
    
    log_warning "Ce script va désinstaller la plateforme de veille techno-cyber"
    echo ""
    
    # Arrêt des containers
    stop_containers
    echo ""
    
    # Suppression des données
    confirm "Voulez-vous supprimer les données ? (recommandé : non pour conserver une sauvegarde)"
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        remove_data
    else
        log_info "Données conservées dans $INSTALL_DIR/data"
        log_info "Vous pouvez les supprimer manuellement plus tard si nécessaire"
    fi
    echo ""
    
    # Suppression de l'installation
    remove_installation
    echo ""
    
    # Suppression de l'utilisateur
    remove_user
    echo ""
    
    # Désinstallation de Docker (optionnel)
    remove_docker
    echo ""
    
    log_success "Désinstallation terminée"
    echo ""
}

main "$@"
