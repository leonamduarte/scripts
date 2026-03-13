#!/usr/bin/env bash
# =============================================================================
# utils/open-folder.sh - Abrir pasta atual no Windows Explorer
# =============================================================================

set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"

if ! is_wsl; then
	error "Este script só funciona no WSL"
	exit 1
fi

# Converter caminho WSL para Windows
win_path=$(wslpath -w "${1:-.}")

info "Abrindo: $win_path"
explorer.exe "$win_path"

ok "Pasta aberta no Explorer!"
