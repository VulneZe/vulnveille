#!/bin/bash
# Script d'initialisation du projet
# Crée la structure de base et les fichiers nécessaires

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

log_info "Initialisation du projet..."

# Création des dossiers data
mkdir -p "$SCRIPT_DIR/data/freshrss"
mkdir -p "$SCRIPT_DIR/data/n8n"
mkdir -p "$SCRIPT_DIR/data/changedetection"
mkdir -p "$SCRIPT_DIR/data/wallabag"
mkdir -p "$SCRIPT_DIR/data/postgres"
mkdir -p "$SCRIPT_DIR/data/backups"

# Création des fichiers .gitkeep
touch "$SCRIPT_DIR/data/freshrss/.gitkeep"
touch "$SCRIPT_DIR/data/n8n/.gitkeep"
touch "$SCRIPT_DIR/data/changedetection/.gitkeep"
touch "$SCRIPT_DIR/data/wallabag/.gitkeep"
touch "$SCRIPT_DIR/data/postgres/.gitkeep"
touch "$SCRIPT_DIR/data/backups/.gitkeep"

log_success "Structure du projet initialisée"
