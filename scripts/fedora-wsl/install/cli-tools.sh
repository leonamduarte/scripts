#!/usr/bin/env bash
# =============================================================================
# install/cli-tools.sh - Ferramentas CLI modernas
# =============================================================================

set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"

check_root

info "Instalando ferramentas CLI..."

# Pacotes disponíveis no Fedora
install_list \
	ripgrep \
	fd-find \
	bat \
	zoxide \
	fzf \
	jq \
	btop \
	tmux

# Garantir alias consistente para fd
if has_command fdfind && ! has_command fd; then
	FD_PATH="$(command -v fdfind 2>/dev/null)"
	if [[ -n "$FD_PATH" ]]; then
		info "Criando symlink fd -> fdfind"
		sudo ln -sf "$FD_PATH" /usr/local/bin/fd
	fi
fi

# eza - tentar pacote nativo, senão fallback binário
info "Instalando eza..."
if ! has_command eza; then
	if sudo dnf install -y eza 2>/dev/null; then
		ok "eza instalado via dnf"
	else
		eza_version="0.18.0"
		arch="$(uname -m)"
		eza_arch="${arch}-unknown-linux-gnu"

		if wget -q "https://github.com/eza-community/eza/releases/download/v${eza_version}/eza_${eza_arch}.tar.gz" -O /tmp/eza.tar.gz; then
			if sudo tar -xzf /tmp/eza.tar.gz -C /usr/local/bin; then
				rm /tmp/eza.tar.gz
				ok "eza instalado"
			else
				log_error "Falha ao extrair eza"
				exit 1
			fi
		else
			log_error "Falha ao baixar eza"
			exit 1
		fi
	fi
fi

# yazi - file manager TUI
info "Instalando yazi..."
if ! has_command yazi; then
	yazi_version="0.3.0"
	arch="$(uname -m)"
	yazi_arch="${arch}-unknown-linux-gnu"

	if wget -q "https://github.com/sxyazi/yazi/releases/download/v${yazi_version}/yazi-${yazi_arch}.zip" -O /tmp/yazi.zip; then
		if unzip -q /tmp/yazi.zip -d /tmp/yazi; then
			if sudo mv /tmp/yazi/yazi /usr/local/bin/ && sudo mv /tmp/yazi/ya /usr/local/bin/; then
				rm -rf /tmp/yazi /tmp/yazi.zip
				ok "yazi instalado"
			else
				log_error "Falha ao mover binários do yazi"
				exit 1
			fi
		else
			log_error "Falha ao extrair yazi"
			exit 1
		fi
	else
		log_error "Falha ao baixar yazi"
		exit 1
	fi
fi

# lazygit - TUI para git
info "Instalando lazygit..."
if ! has_command lazygit; then
	lazygit_version="0.43.1"
	arch="$(uname -m)"

	if wget -q "https://github.com/jesseduffield/lazygit/releases/download/v${lazygit_version}/lazygit_${lazygit_version}_Linux_${arch}.tar.gz" -O /tmp/lazygit.tar.gz; then
		if sudo tar -xzf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit; then
			rm /tmp/lazygit.tar.gz
			ok "lazygit instalado"
		else
			log_error "Falha ao extrair lazygit"
			exit 1
		fi
	else
		log_error "Falha ao baixar lazygit"
		exit 1
	fi
fi

ok "Todas as ferramentas CLI instaladas!"
