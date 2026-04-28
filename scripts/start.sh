#!/bin/bash
# Script de démarrage de la stack Docker Compose

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

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

# Vérification de .env
if [[ ! -f .env ]]; then
    log_info "Fichier .env non trouvé, génération depuis .env.example..."
    bash scripts/generate-env.sh
fi

# Détection du mode
if [[ "${1:-}" == "prod" ]]; then
    log_info "Démarrage en mode production..."
    docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
else
    log_info "Démarrage en mode développement..."
    docker compose up -d
fi

log_success "Stack démarrée"

# Affichage des URLs
echo ""
log_info "Services accessibles :"
if [[ -f docker-compose.override.yml ]]; then
    echo "  - FreshRSS : http://localhost:8081"
    echo "  - n8n : http://localhost:5678"
    echo "  - changedetection.io : http://localhost:5000"
    echo "  - Wallabag : http://localhost:8082"
else
    echo "  - freshrss.veille.local"
    echo "  - n8n.veille.local"
    echo "  - changes.veille.local"
    echo "  - wallabag.veille.local"
fi
echo ""
