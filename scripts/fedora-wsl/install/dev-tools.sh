#!/usr/bin/env bash
# =============================================================================
# install/dev-tools.sh - Git, GitHub CLI, fnm, Python, pipx, Neovim
# =============================================================================

set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"

check_root

info "Instalando ferramentas de desenvolvimento..."

# Git (geralmente já vem, mas garantir)
info "Git..."
ensure_dnf git

# GitHub CLI
info "GitHub CLI..."
if ! has_command gh; then
	ensure_dnf gh
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
ensure_dnf python3
ensure_dnf python3-pip

# pipx
info "pipx..."
if ! has_command pipx; then
	ensure_dnf pipx
	pipx ensurepath
	ok "pipx instalado"
fi

# Neovim - pacote nativo, com fallback AppImage
info "Neovim..."
if ! has_command nvim; then
	if sudo dnf install -y neovim 2>/dev/null; then
		ok "Neovim instalado via dnf"
	else
		info "DNF não encontrou Neovim, tentando AppImage..."
		if wget -q "https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.appimage" -O /tmp/nvim.appimage; then
			if chmod +x /tmp/nvim.appimage; then
				if cd /tmp; then
					if ./nvim.appimage --appimage-extract >/dev/null 2>&1; then
						if sudo rm -rf /opt/nvim && sudo mv squashfs-root /opt/nvim; then
							if sudo ln -sf /opt/nvim/usr/bin/nvim /usr/local/bin/nvim; then
								cd - >/dev/null || true
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
