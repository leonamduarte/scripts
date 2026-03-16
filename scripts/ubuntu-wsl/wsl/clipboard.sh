#!/usr/bin/env bash
# =============================================================================
# wsl/clipboard.sh - Configurar clipboard WSL
# =============================================================================

set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"

if ! is_wsl; then
	error "Este script só funciona no WSL"
	exit 1
fi

info "Configurando clipboard..."

# O clipboard bidirecional já funciona no WSL2 moderno
# Este script é mais para garantir/configurar aliases úteis

# Criar aliases úteis no Fish
mkdir -p ~/.config/fish/functions

# Função para copiar para clipboard
cat >~/.config/fish/functions/clip.fish <<'EOF'
function clip
  cat $argv | clip.exe
end
EOF

# Função para colar do clipboard
cat >~/.config/fish/functions/paste.fish <<'EOF'
function paste
  powershell.exe -command "Get-Clipboard"
end
EOF

ok "Clipboard configurado!"
info "Use: clip arquivo.txt | copia conteúdo"
info "Use: paste | cola conteúdo do Windows"
