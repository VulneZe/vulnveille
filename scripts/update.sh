#!/bin/bash
# Script de mise à jour de la stack Docker Compose

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

# Couleurs
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

# Sauvegarde avant mise à jour
log_info "Création d'une sauvegarde avant mise à jour..."
bash scripts/backup.sh

# Pull des nouvelles images
log_info "Récupération des nouvelles images Docker..."
docker compose pull

# Redémarrage de la stack
log_info "Redémarrage de la stack avec les nouvelles images..."
docker compose up -d

# Proposition de nettoyage
log_warning "Voulez-vous nettoyer les anciennes images Docker ? (libère de l'espace disque)"
read -p "Nettoyer les anciennes images ? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Nettoyage des anciennes images..."
    docker image prune -f
    log_success "Nettoyage terminé"
fi

# Vérification de la santé
log_info "Vérification de la santé de la stack..."
if [[ -f scripts/check-health.sh ]]; then
    bash scripts/check-health.sh
fi

log_success "Mise à jour terminée !"
