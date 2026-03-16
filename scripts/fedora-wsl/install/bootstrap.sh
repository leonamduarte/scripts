#!/usr/bin/env bash
# =============================================================================
# install/bootstrap.sh - Instala Fedora Linux no WSL
# =============================================================================

set -euo pipefail

# Carregar utilitários
source "$(dirname "$0")/../lib/utils.sh"

get_fedora_distro() {
	local distro
	distro="$(wsl.exe --list --online 2>/dev/null | tr -d '\r' | grep -oE 'FedoraLinux-[0-9]+' | sort -V | tail -n1)"
	if [[ -z "$distro" ]]; then
		distro="FedoraLinux"
	fi
	echo "$distro"
}

info "Verificando WSL..."

# Verificar se está no Windows
if ! command -v wsl.exe &>/dev/null; then
	error "WSL não encontrado. Este script deve ser executado no Windows (PowerShell/CMD)."
	exit 1
fi

fedora_distro="$(get_fedora_distro)"

# Verificar se já tem distribuição Fedora instalada
if wsl.exe --list --quiet | tr -d '\r' | grep -qi "Fedora"; then
	warn "Já existe uma distribuição Fedora instalada:"
	wsl.exe --list --verbose

	if ! confirm "Deseja continuar e instalar ${fedora_distro} mesmo assim?"; then
		info "Operação cancelada."
		exit 0
	fi
fi

info "Instalando ${fedora_distro} no WSL..."

# Habilitar recursos necessários do Windows
info "Habilitando recursos do WSL..."
powershell.exe -Command "
  wsl --install --no-distribution
  dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
  dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
"

info "Definindo WSL2 como padrão..."
wsl.exe --set-default-version 2

info "Instalando ${fedora_distro}..."
wsl.exe --install -d "$fedora_distro"

ok "${fedora_distro} instalado com sucesso!"
info "Reinicie o computador se solicitado."
info "Após reiniciar, execute 'wsl' para configurar o usuário."
