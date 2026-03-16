#!/usr/bin/env bash
# =============================================================================
# install/base.sh - Pacotes essenciais e atualização do sistema
# =============================================================================

set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"

check_root

info "Atualizando sistema..."
sudo dnf upgrade --refresh -y

info "Instalando pacotes essenciais..."

install_list \
	curl \
	wget \
	git \
	gcc \
	gcc-c++ \
	make \
	unzip \
	ca-certificates \
	gnupg2 \
	dnf-plugins-core \
	util-linux-user \
	procps-ng

ok "Base instalada com sucesso!"
