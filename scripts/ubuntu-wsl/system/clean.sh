#!/usr/bin/env bash
# =============================================================================
# system/clean.sh - Limpar sistema
# =============================================================================

set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"

info "Limpando sistema..."

# Limpar cache do apt
sudo apt-get clean
sudo apt-get autoclean

# Remover pacotes órfãos
sudo apt-get autoremove -y

# Limpar cache antigo
sudo apt-get purge -y $(dpkg -l | grep '^rc' | awk '{print $2}') 2>/dev/null || true

# Limpar logs antigos (mais de 7 dias)
sudo find /var/log -type f -name "*.log" -mtime +7 -delete 2>/dev/null || true

ok "Sistema limpo!"
