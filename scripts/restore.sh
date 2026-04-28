#!/bin/bash
# Script de restauration depuis une sauvegarde

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

BACKUP_DIR="./data/backups"

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

confirm() {
    read -p "$1 (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 1
    fi
    return 0
}

# Liste des sauvegardes disponibles
log_info "Sauvegardes disponibles :"
ls -lh "$BACKUP_DIR"/veille_backup_*_data.tar.gz 2>/dev/null || {
    log_error "Aucune sauvegarde trouvée dans $BACKUP_DIR"
    exit 1
}
echo ""

# Sélection de la sauvegarde
read -p "Entrez le nom de la sauvegarde à restaurer (ex: veille_backup_20240101_120000) : " BACKUP_NAME

if [[ ! -f "$BACKUP_DIR/${BACKUP_NAME}_data.tar.gz" ]]; then
    log_error "Sauvegarde non trouvée : $BACKUP_DIR/${BACKUP_NAME}_data.tar.gz"
    exit 1
fi

# Confirmation
log_warning "Cette action va remplacer les données actuelles"
confirm "Êtes-vous certain de vouloir continuer ?" || exit 0

# Arrêt des containers
log_info "Arrêt des containers..."
docker compose down

# Restauration des données
log_info "Restauration des volumes applicatifs..."
tar -xzf "$BACKUP_DIR/${BACKUP_NAME}_data.tar.gz" -C ./

# Restauration de la configuration
if [[ -f "$BACKUP_DIR/${BACKUP_NAME}_config.tar.gz" ]]; then
    log_info "Restauration des fichiers de configuration..."
    tar -xzf "$BACKUP_DIR/${BACKUP_NAME}_config.tar.gz" -C ./
fi

# Restauration du .env
if [[ -f "$BACKUP_DIR/${BACKUP_NAME}_env" ]]; then
    log_warning "Restauration du fichier .env (contient des secrets)"
    confirm "Voulez-vous restaurer le fichier .env ?" || {
        log_info "Fichier .env non restauré"
    }
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp "$BACKUP_DIR/${BACKUP_NAME}_env" .env
        chmod 600 .env
    fi
fi

# Redémarrage des containers
log_info "Redémarrage des containers..."
docker compose up -d

# Attente du démarrage
log_info "Attente du démarrage des services..."
sleep 10

# Vérification de la santé
log_info "Vérification de la santé de la stack..."
if [[ -f scripts/check-health.sh ]]; then
    bash scripts/check-health.sh
fi

log_success "Restauration terminée !"
