#!/usr/bin/env bash
# =============================================================================
# install/bootstrap.sh - Instala Ubuntu 22.04 no WSL
# =============================================================================

set -euo pipefail

# Carregar utilitários
source "$(dirname "$0")/../lib/utils.sh"

info "Verificando WSL..."

# Verificar se está no Windows
if ! command -v wsl.exe &>/dev/null; then
	error "WSL não encontrado. Este script deve ser executado no Windows (PowerShell/CMD)."
	exit 1
fi

# Verificar se já tem distribuição Ubuntu instalada
if wsl.exe --list --quiet | grep -qi ubuntu; then
	warn "Já existe uma distribuição Ubuntu instalada:"
	wsl.exe --list --verbose

	if ! confirm "Deseja continuar e instalar Ubuntu-22.04 mesmo assim?"; then
		info "Operação cancelada."
		exit 0
	fi
fi

info "Instalando Ubuntu 22.04 LTS no WSL..."

# Habilitar recursos necessários do Windows
info "Habilitando recursos do WSL..."
powershell.exe -Command "
  wsl --install --no-distribution
  dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
  dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
"

info "Definindo WSL2 como padrão..."
wsl.exe --set-default-version 2

info "Instalando Ubuntu 22.04..."
wsl.exe --install -d Ubuntu-22.04

ok "Ubuntu 22.04 instalado com sucesso!"
info "Reinicie o computador se solicitado."
info "Após reiniciar, execute 'wsl' para configurar o usuário."
