#!/bin/bash
# Script de sauvegarde de la stack
# Sauvegarde les volumes applicatifs et la configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

BACKUP_DIR="./data/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="veille_backup_${DATE}"
RETENTION=7  # Nombre de sauvegardes à conserver

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Création du répertoire de sauvegarde
mkdir -p "$BACKUP_DIR"

log_info "Création de la sauvegarde $BACKUP_NAME..."

# Sauvegarde des volumes applicatifs
log_info "Sauvegarde des volumes applicatifs..."
tar -czf "$BACKUP_DIR/${BACKUP_NAME}_data.tar.gz" \
    ./data/freshrss \
    ./data/n8n \
    ./data/changedetection \
    ./data/wallabag \
    ./data/postgres 2>/dev/null || true

# Sauvegarde des fichiers de configuration
log_info "Sauvegarde des fichiers de configuration..."
tar -czf "$BACKUP_DIR/${BACKUP_NAME}_config.tar.gz" \
    ./docker-compose.yml \
    ./docker-compose.prod.yml \
    ./config 2>/dev/null || true

# Sauvegarde du .env (avec avertissement)
log_info "Sauvegarde du fichier .env (contient des secrets)..."
if [[ -f .env ]]; then
    cp .env "$BACKUP_DIR/${BACKUP_NAME}_env"
    chmod 600 "$BACKUP_DIR/${BACKUP_NAME}_env"
    log_warning "Le fichier .env contient des secrets, conservez-le en sécurité"
fi

log_success "Sauvegarde créée dans $BACKUP_DIR/"

# Nettoyage des anciennes sauvegardes
log_info "Nettoyage des anciennes sauvegardes (conservation des $RETENTION dernières)..."
ls -t "$BACKUP_DIR"/veille_backup_*_data.tar.gz 2>/dev/null | tail -n +$((RETENTION + 1)) | xargs -r rm
ls -t "$BACKUP_DIR"/veille_backup_*_config.tar.gz 2>/dev/null | tail -n +$((RETENTION + 1)) | xargs -r rm
ls -t "$BACKUP_DIR"/veille_backup_*_env 2>/dev/null | tail -n +$((RETENTION + 1)) | xargs -r rm

log_success "Sauvegarde terminée"
