#!/usr/bin/env bash
# =============================================================================
# system/update.sh - Atualizar sistema
# =============================================================================

set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"

info "Atualizando sistema..."

sudo dnf upgrade --refresh -y
sudo dnf autoremove -y
sudo dnf clean all

ok "Sistema atualizado!"
