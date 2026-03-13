#!/usr/bin/env bash
# =============================================================================
# install/base.sh - Pacotes essenciais e atualização do sistema
# =============================================================================

set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"

check_root

info "Atualizando sistema..."
sudo apt-get update
sudo apt-get upgrade -y

info "Instalando pacotes essenciais..."

install_list \
	curl \
	wget \
	git \
	build-essential \
	unzip \
	software-properties-common \
	apt-transport-https \
	ca-certificates \
	gnupg \
	lsb-release

ok "Base instalada com sucesso!"
