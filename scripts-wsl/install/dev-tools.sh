#!/usr/bin/env bash
# =============================================================================
# install/dev-tools.sh - Git, GitHub CLI, fnm, Python, pipx, Neovim
# =============================================================================

set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"

check_root

info "Instalando ferramentas de desenvolvimento..."

# Garantir que snapd está instalado
info "Verificando snapd..."
if ! has_command snap; then
	sudo apt-get update
	sudo apt-get install -y snapd
	ok "snapd instalado"
fi

# Git (geralmente já vem, mas garantir)
info "Git..."
ensure_apt git

# GitHub CLI
info "GitHub CLI..."
if ! has_command gh; then
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
	sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
	sudo apt-get update
	sudo apt-get install -y gh
	ok "GitHub CLI instalado"
fi

# fnm (Fast Node Manager)
info "fnm (Node.js version manager)..."
if ! has_command fnm; then
	curl -fsSL https://fnm.vercel.app/install | bash

	# Adicionar ao PATH do Fish
	mkdir -p ~/.config/fish/conf.d
	cat >~/.config/fish/conf.d/fnm.fish <<'EOF'
# fnm
set FNM_PATH "$HOME/.local/share/fnm"
if test -d "$FNM_PATH"
  set PATH "$FNM_PATH" $PATH
  fnm env | source
end
EOF

	ok "fnm instalado"
fi

# Python 3 e pip
info "Python..."
ensure_apt python3
ensure_apt python3-pip
ensure_apt python3-venv

# pipx
info "pipx..."
if ! has_command pipx; then
	sudo apt-get install -y pipx
	pipx ensurepath
	ok "pipx instalado"
fi

# Neovim - múltiplos métodos (snap, appimage, apt)
info "Neovim..."
if ! has_command nvim; then
	# Método 1: Tentar snap
	if has_command snap; then
		info "Instalando Neovim via snap..."
		if sudo snap install nvim --classic 2>/dev/null; then
			ok "Neovim instalado via snap"
		else
			info "Snap falhou, tentando AppImage..."
			# Método 2: AppImage
			if wget -q "https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.appimage" -O /tmp/nvim.appimage; then
				if chmod +x /tmp/nvim.appimage; then
					if cd /tmp; then
						if ./nvim.appimage --appimage-extract >/dev/null 2>&1; then
							if sudo mv squashfs-root /opt/nvim; then
								if sudo ln -sf /opt/nvim/usr/bin/nvim /usr/local/bin/nvim; then
									cd - || true
									ok "Neovim instalado via AppImage"
								else
									log_error "Falha ao criar symlink do Neovim"
									exit 1
								fi
							else
								log_error "Falha ao mover diretório extraído"
								exit 1
							fi
						else
							log_error "Falha ao extrair AppImage do Neovim"
							exit 1
						fi
					else
						log_error "Falha ao mudar para /tmp"
						exit 1
					fi
				else
					log_error "Falha ao tornar AppImage executável"
					exit 1
				fi
			else
				log_error "Falha ao baixar Neovim AppImage"
				exit 1
			fi
		fi
	else
		# Método 3: APT (versão do repositório)
		info "Instalando Neovim via apt..."
		ensure_apt neovim
	fi
else
	info "Neovim já instalado"
fi

# Criar diretório de configuração do Neovim
mkdir -p ~/.config/nvim

# Instalar Node LTS via fnm
info "Instalando Node.js LTS..."
if has_command fnm; then
	export PATH="$HOME/.local/share/fnm:$PATH"
	eval "$(fnm env)"
	fnm install --lts
	fnm use lts-latest
	ok "Node.js LTS instalado"
fi

ok "Ferramentas de desenvolvimento instaladas!"
