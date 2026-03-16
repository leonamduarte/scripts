#!/usr/bin/env bash
# =============================================================================
# system/clean.sh - Limpar sistema
# =============================================================================

set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"

info "Limpando sistema..."

# Limpar cache do dnf
sudo dnf clean all

# Remover pacotes órfãos
sudo dnf autoremove -y

# Limpar logs antigos (mais de 7 dias)
sudo find /var/log -type f -name "*.log" -mtime +7 -delete 2>/dev/null || true

ok "Sistema limpo!"
