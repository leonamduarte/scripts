#!/usr/bin/env bash
# =============================================================================
# wsl/mount-drives.sh - Montar discos Windows
# =============================================================================

set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"

if ! is_wsl; then
	error "Este script só funciona no WSL"
	exit 1
fi

info "Discos Windows disponíveis:"
echo "============================"

# Listar discos montados
ls -la /mnt/ 2>/dev/null || echo "Nenhum disco encontrado em /mnt/"

echo ""
info "Discos físicos detectados:"
powershell.exe -Command "Get-Disk | Select-Object Number, FriendlyName, Size" 2>/dev/null || echo "Não foi possível listar discos físicos"

echo ""
info "Letras de unidade montadas:"
ls /mnt/ | grep -E '^[a-z]$' | while read -r drive; do
	win_path=$(wslpath -w "/mnt/$drive" 2>/dev/null)
	echo "  /mnt/$drive -> $win_path"
done
