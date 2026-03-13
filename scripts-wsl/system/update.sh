#!/usr/bin/env bash
# =============================================================================
# system/update.sh - Atualizar sistema
# =============================================================================

set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"

info "Atualizando sistema..."

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y
sudo apt-get autoclean

ok "Sistema atualizado!"
