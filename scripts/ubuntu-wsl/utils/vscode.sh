#!/usr/bin/env bash
# =============================================================================
# utils/vscode.sh - Abrir VSCode no diretório atual
# =============================================================================

set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"

if ! is_wsl; then
	error "Este script só funciona no WSL"
	exit 1
fi

# Diretório atual ou argumento
dir="${1:-.}"
win_path=$(wslpath -w "$dir")

info "Abrindo VSCode em: $win_path"
code "$win_path"

ok "VSCode aberto!"
