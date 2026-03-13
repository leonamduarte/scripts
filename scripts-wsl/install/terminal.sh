#!/usr/bin/env bash
# =============================================================================
# install/terminal.sh - Alacritty terminal
# =============================================================================

set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"

check_root

info "Instalando Alacritty..."

# Alacritty via Snap (versão mais recente)
if ! has_command alacritty; then
	# Verificar se snapd está instalado
	if ! has_command snap; then
		sudo apt-get update
		sudo apt-get install -y snapd
	fi

	# Instalar via snap
	sudo snap install alacritty --classic
	ok "Alacritty instalado via snap"
else
	info "Alacritty já instalado"
fi

# Criar diretório de configuração
info "Criando diretório de configuração..."
mkdir -p ~/.config/alacritty

# Configuração básica (será sobrescrita pelos dotfiles depois)
if [[ ! -f ~/.config/alacritty/alacritty.toml ]]; then
	info "Criando configuração inicial..."
	cat >~/.config/alacritty/alacritty.toml <<'EOF'
[window]
decorations = "None"
startup_mode = "Windowed"
dynamic_title = true

[font]
normal = { family = "FiraCode Nerd Font", style = "Regular" }
size = 11.0

[colors]
primary = { background = "#1e1e2e", foreground = "#cdd6f4" }

[cursor]
style = { shape = "Beam", blinking = "On" }

[selection]
save_to_clipboard = true
EOF
	ok "Configuração inicial criada"
fi

ok "Alacritty configurado!"
info "Os temas e configurações completas serão aplicadas via dotfiles."
