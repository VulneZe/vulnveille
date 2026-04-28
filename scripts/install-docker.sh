#!/bin/bash
# Script d'installation de Docker et Docker Compose
# Détecte Debian ou Ubuntu et installe les paquets nécessaires

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

install_prerequisites() {
    log_info "Installation des prérequis..."
    apt-get update -qq
    apt-get install -y -qq curl git wget ca-certificates gnupg lsb-release
    log_success "Prérequis installés"
}

install_docker() {
    log_info "Vérification de l'installation de Docker..."
    
    if command -v docker &> /dev/null; then
        log_success "Docker est déjà installé : $(docker --version)"
        return
    fi
    
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
}

install_docker_compose() {
    log_info "Vérification de Docker Compose plugin..."
    
    if docker compose version &> /dev/null; then
        log_success "Docker Compose plugin installé : $(docker compose version)"
    else
        log_error "Docker Compose plugin n'est pas installé correctement"
        exit 1
    fi
}

enable_docker() {
    log_info "Activation du service Docker..."
    systemctl enable docker
    systemctl start docker
    log_success "Docker activé et démarré"
}

add_user_to_docker() {
    local user="${1:-veille}"
    
    if id "$user" &>/dev/null; then
        log_info "Ajout de l'utilisateur $user au groupe docker..."
        usermod -aG docker "$user"
        log_success "Utilisateur $user ajouté au groupe docker"
        log_warning "L'utilisateur $user doit se déconnecter et se reconnecter pour que les changements prennent effet"
    else
        log_warning "L'utilisateur $user n'existe pas"
    fi
}

verify_installation() {
    log_info "Vérification de l'installation..."
    
    if command -v docker &> /dev/null; then
        log_success "Docker : $(docker --version)"
    else
        log_error "Docker n'est pas installé"
        exit 1
    fi
    
    if docker compose version &> /dev/null; then
        log_success "Docker Compose : $(docker compose version)"
    else
        log_error "Docker Compose n'est pas installé"
        exit 1
    fi
    
    # Test de Docker
    if docker run --rm hello-world &> /dev/null; then
        log_success "Docker fonctionne correctement"
    else
        log_error "Docker ne fonctionne pas correctement"
        exit 1
    fi
}

# ============================================================================
# Main
# ============================================================================
main() {
    echo "=========================================================================="
    echo "  Installation de Docker et Docker Compose"
    echo "=========================================================================="
    echo ""
    
    check_root
    detect_os
    install_prerequisites
    install_docker
    install_docker_compose
    enable_docker
    
    # Ajout de l'utilisateur veille au groupe docker si spécifié
    if [[ -n "${1:-}" ]]; then
        add_user_to_docker "$1"
    fi
    
    verify_installation
    
    log_success "Installation de Docker terminée avec succès !"
    echo ""
}

main "$@"
