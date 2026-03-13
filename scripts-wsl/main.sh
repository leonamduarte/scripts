#!/usr/bin/env bash
# =============================================================================
# main.sh - Dispatcher CLI para scripts-wsl
# Uso: ./main.sh <comando> <subcomando>
# =============================================================================

set -euo pipefail

# Diretório base
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Logging
info() { echo -e "${BLUE}[INFO]${NC} $*"; }
ok() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Menu de ajuda
show_help() {
	cat <<'EOF'
╔══════════════════════════════════════════════════════════════╗
║              bashln-scripts WSL Edition                      ║
╚══════════════════════════════════════════════════════════════╝

Uso: ./main.sh <comando> <subcomando>

INSTALAÇÃO:
  ./main.sh install bootstrap    Instalar Ubuntu 22.04 no WSL
  ./main.sh install base         Essenciais + update do sistema
  ./main.sh install shell        Fish + Starship prompt
  ./main.sh install cli-tools    ripgrep, fd, bat, eza, fzf, etc
  ./main.sh install terminal     Alacritty
  ./main.sh install dev-tools    git, gh, fnm, neovim, python
  ./main.sh install dotfiles     Clonar e configurar dotfiles

SISTEMA:
  ./main.sh system update        Atualizar pacotes
  ./main.sh system clean         Limpar cache e pacotes órfãos
  ./main.sh system ports         Listar portas abertas

UTILITÁRIOS:
  ./main.sh utils open-folder    Abrir pasta atual no Explorer
  ./main.sh utils vscode         Abrir VSCode no diretório atual
  ./main.sh utils big-files      Encontrar arquivos grandes

WSL:
  ./main.sh wsl clipboard        Configurar clipboard
  ./main.sh wsl mount-drives     Montar discos Windows

INSTALAÇÃO COMPLETA:
  ./main.sh install all          Executa todos os scripts de instalação

EXEMPLOS:
  ./main.sh install base
  ./main.sh system update
  ./main.sh utils open-folder

EOF
}

# Executar script
run_script() {
	local category="$1"
	local script="$2"
	local script_path="$SCRIPT_DIR/$category/$script.sh"

	if [[ ! -f "$script_path" ]]; then
		error "Script não encontrado: $script_path"
		exit 1
	fi

	info "Executando: $category/$script.sh"
	bash "$script_path"
}

# Instalação completa
install_all() {
	info "Iniciando instalação completa..."

	local scripts=(
		"install/base"
		"install/shell"
		"install/cli-tools"
		"install/terminal"
		"install/dev-tools"
		"install/dotfiles"
	)

	for script in "${scripts[@]}"; do
		local category="${script%/*}"
		local name="${script#*/}"

		info "================================"
		info "Instalando: $name"
		info "================================"

		if ! run_script "$category" "$name"; then
			error "Falha em: $script"
			exit 1
		fi
	done

	ok "Instalação completa finalizada!"
}

# Parser de comandos
main() {
	if [[ $# -lt 1 ]]; then
		show_help
		exit 0
	fi

	local command="$1"
	local subcommand="${2:-}"

	case "$command" in
	install)
		if [[ "$subcommand" == "all" ]]; then
			install_all
		elif [[ -n "$subcommand" ]]; then
			run_script "install" "$subcommand"
		else
			error "Especifique o subcomando: bootstrap, base, shell, cli-tools, terminal, dev-tools, dotfiles, ou all"
			exit 1
		fi
		;;
	system)
		if [[ -n "$subcommand" ]]; then
			run_script "system" "$subcommand"
		else
			error "Especifique: update, clean, ou ports"
			exit 1
		fi
		;;
	utils)
		if [[ -n "$subcommand" ]]; then
			run_script "utils" "$subcommand"
		else
			error "Especifique: open-folder, vscode, ou big-files"
			exit 1
		fi
		;;
	wsl)
		if [[ -n "$subcommand" ]]; then
			run_script "wsl" "$subcommand"
		else
			error "Especifique: clipboard ou mount-drives"
			exit 1
		fi
		;;
	help | --help | -h)
		show_help
		;;
	*)
		error "Comando desconhecido: $command"
		show_help
		exit 1
		;;
	esac
}

main "$@"
