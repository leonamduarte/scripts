#!/usr/bin/env bash
# =============================================================================
# utils/big-files.sh - Encontrar arquivos grandes
# =============================================================================

set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"

# Tamanho mínimo (padrão: 100MB)
SIZE="${1:-100M}"
DIR="${2:-.}"

echo "Procurando arquivos maiores que $SIZE em $DIR..."
echo "================================================"

find "$DIR" -type f -size +"$SIZE" -exec ls -lh {} \; 2>/dev/null | awk '{ print $NF ": " $5 }' | sort -k2 -rh | head -20
