#!/bin/bash
# Script de vérification de la santé de la stack
# Vérifie Docker, les containers, les ports et les healthchecks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

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
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "=========================================================================="
echo "  Vérification de la santé de la stack"
echo "=========================================================================="
echo ""

# Vérification de Docker
log_info "Vérification de Docker..."
if command -v docker &> /dev/null; then
    log_success "Docker est installé : $(docker --version)"
else
    log_error "Docker n'est pas installé"
    exit 1
fi

# Vérification de Docker Compose
log_info "Vérification de Docker Compose..."
if docker compose version &> /dev/null; then
    log_success "Docker Compose est installé : $(docker compose version)"
else
    log_error "Docker Compose n'est pas installé"
    exit 1
fi

# Vérification des containers
log_info "Vérification des containers..."
CONTAINERS=$(docker compose ps -q)
if [[ -z "$CONTAINERS" ]]; then
    log_error "Aucun container n'est en cours d'exécution"
    exit 1
fi

docker compose ps
echo ""

# Vérification de l'état des containers
log_info "Vérification de l'état des containers..."
FAILED=0
while IFS= read -r line; do
    CONTAINER_NAME=$(echo "$line" | awk '{print $1}')
    STATUS=$(echo "$line" | awk '{print $2}')
    
    if [[ "$STATUS" != "Up" ]]; then
        log_error "$CONTAINER_NAME : $STATUS"
        FAILED=1
    else
        log_success "$CONTAINER_NAME : $STATUS"
    fi
done < <(docker compose ps --format "table {{.Name}}\t{{.Status}}" | tail -n +2)

if [[ $FAILED -eq 1 ]]; then
    log_error "Certains containers ne sont pas en cours d'exécution"
    exit 1
fi

# Vérification des healthchecks
log_info "Vérification des healthchecks Docker..."
FAILED=0
while IFS= read -r line; do
    CONTAINER_NAME=$(echo "$line" | awk '{print $1}')
    HEALTH=$(echo "$line" | awk '{print $3}')
    
    if [[ "$HEALTH" == "unhealthy" ]]; then
        log_error "$CONTAINER_NAME : unhealthy"
        FAILED=1
    elif [[ "$HEALTH" == "starting" ]]; then
        log_warning "$CONTAINER_NAME : starting"
    elif [[ -n "$HEALTH" ]]; then
        log_success "$CONTAINER_NAME : $HEALTH"
    fi
done < <(docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Health}}" | tail -n +2)

# Vérification que PostgreSQL n'est pas exposé publiquement
log_info "Vérification de l'exposition PostgreSQL..."
if netstat -tuln 2>/dev/null | grep -q ":5432 "; then
    log_warning "PostgreSQL semble être exposé sur le port 5432"
    log_warning "Vérifiez que c'est uniquement sur 127.0.0.1"
else
    log_success "PostgreSQL n'est pas exposé publiquement"
fi

# Vérification des ports applicatifs
log_info "Vérification des ports applicatifs..."
if netstat -tuln 2>/dev/null | grep -q ":8081 "; then
    log_warning "FreshRSS (port 8081) est exposé"
else
    log_success "FreshRSS n'est pas exposé publiquement"
fi

if netstat -tuln 2>/dev/null | grep -q ":5678 "; then
    log_warning "n8n (port 5678) est exposé"
else
    log_success "n8n n'est pas exposé publiquement"
fi

if netstat -tuln 2>/dev/null | grep -q ":5000 "; then
    log_warning "changedetection.io (port 5000) est exposé"
else
    log_success "changedetection.io n'est pas exposé publiquement"
fi

if netstat -tuln 2>/dev/null | grep -q ":8082 "; then
    log_warning "Wallabag (port 8082) est exposé"
else
    log_success "Wallabag n'est pas exposé publiquement"
fi

# Vérification du fichier .env
log_info "Vérification du fichier .env..."
if [[ -f .env ]]; then
    if [[ $(stat -c %a .env 2>/dev/null || stat -f %A .env 2>/dev/null) == "600" ]]; then
        log_success "Fichier .env existe avec permissions correctes (600)"
    else
        log_warning "Fichier .env existe mais permissions incorrectes (devrait être 600)"
    fi
else
    log_error "Fichier .env non trouvé"
fi

echo ""
log_success "Vérification de la santé terminée"
echo ""
