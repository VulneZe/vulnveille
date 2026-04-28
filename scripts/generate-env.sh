#!/bin/bash
# Script de génération du fichier .env depuis .env.example
# Génère des secrets forts avec openssl

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
ENV_EXAMPLE="$SCRIPT_DIR/.env.example"

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

generate_secret() {
    local length=${1:-32}
    openssl rand -base64 "$length" | tr -d "=+/" | cut -c1-"$length"
}

confirm_overwrite() {
    read -p "$1 (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 1
    fi
    return 0
}

generate_env() {
    if [[ ! -f "$ENV_EXAMPLE" ]]; then
        log_error "Fichier .env.example non trouvé : $ENV_EXAMPLE"
        exit 1
    fi
    
    if [[ -f "$ENV_FILE" ]]; then
        log_warning "Le fichier .env existe déjà"
        if ! confirm_overwrite "Voulez-vous l'écraser ?"; then
            log_info "Conservation du fichier .env existant"
            return
        fi
    fi
    
    log_info "Création du fichier .env depuis .env.example..."
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    
    # Génération des secrets forts
    log_info "Génération des secrets forts..."
    
    POSTGRES_PASSWORD=$(generate_secret 32)
    N8N_BASIC_AUTH_PASSWORD=$(generate_secret 32)
    N8N_ENCRYPTION_KEY=$(generate_secret 48)
    WALLABAG_SECRET=$(generate_secret 48)
    WALLABAG_DATABASE_PASSWORD=$(generate_secret 32)
    FRESHRSS_ADMIN_PASSWORD=$(generate_secret 32)
    
    # Remplacement des secrets dans .env
    sed -i "s/CHANGEZ_CECI_MOT_DE_PASSE_FORT_POSTGRES/$POSTGRES_PASSWORD/" "$ENV_FILE"
    sed -i "s/CHANGEZ_CECI_MOT_DE_PASSE_FORT_N8N/$N8N_BASIC_AUTH_PASSWORD/" "$ENV_FILE"
    sed -i "s/CHANGEZ_CECI_CLE_DE_CHIFFREMENT_N8N_MIN_32_CARACTERES/$N8N_ENCRYPTION_KEY/" "$ENV_FILE"
    sed -i "s/CHANGEZ_CECI_SECRET_WALLABAG_MIN_32_CARACTERES/$WALLABAG_SECRET/" "$ENV_FILE"
    sed -i "s/CHANGEZ_CECI_MOT_DE_PASSE_FORT_WALLABAG/$WALLABAG_DATABASE_PASSWORD/" "$ENV_FILE"
    sed -i "s/CHANGEZ_CECI_MOT_DE_PASSE_FORT_FRESHRSS/$FRESHRSS_ADMIN_PASSWORD/" "$ENV_FILE"
    
    chmod 600 "$ENV_FILE"
    
    log_success "Fichier .env généré avec des secrets forts"
}

display_important_variables() {
    log_warning "Variables importantes à vérifier/modifier :"
    echo ""
    echo "  - N8N_BASIC_AUTH_USER (actuellement: admin)"
    echo "  - INTERNAL_DOMAIN (actuellement: veille.local)"
    echo "  - FQDN des services (freshrss.veille.local, etc.)"
    echo "  - Configuration SMTP si nécessaire"
    echo ""
    log_warning "Conservez une copie sécurisée de ce fichier .env"
    echo ""
}

# ============================================================================
# Main
# ============================================================================
main() {
    echo "=========================================================================="
    echo "  Génération du fichier .env"
    echo "=========================================================================="
    echo ""
    
    generate_env
    display_important_variables
    
    log_success "Terminé !"
    echo ""
}

main "$@"
