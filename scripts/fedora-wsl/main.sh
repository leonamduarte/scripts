#!/usr/bin/env bash
# =============================================================================
# main.sh - Dispatcher CLI para fedora-wsl
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

# Sequência canônica de instalação (usada por all, show_steps e dry-run)
readonly -a INSTALL_STEPS=(
	"install/base"
	"install/shell"
	"install/cli-tools"
	"install/terminal"
	"install/dev-tools"
	"install/dotfiles"
)

# Menu de ajuda
show_help() {
	cat <<'EOF'
╔══════════════════════════════════════════════════════════════╗
║           bashln-scripts Fedora WSL Edition                  ║
╚══════════════════════════════════════════════════════════════╝

Uso: ./main.sh <comando> <subcomando>

INSTALAÇÃO:
  ./main.sh install base         Essenciais + update do sistema
  ./main.sh install shell        Fish + Starship prompt
  ./main.sh install cli-tools    ripgrep, fd, bat, eza, fzf, etc
  ./main.sh install terminal     Alacritty
  ./main.sh install dev-tools    git, gh, fnm, neovim, python
  ./main.sh install dotfiles     Clonar e configurar dotfiles
  ./main.sh install bootstrap    [WSL] Instalar Fedora Linux no WSL
  ./main.sh install all          Executar sequência completa
  ./main.sh install list         Listar sequência de instalação
  ./main.sh install dry-run      Mostrar o que seria executado

SISTEMA:
  ./main.sh system update        Atualizar pacotes
  ./main.sh system clean         Limpar cache e pacotes órfãos
  ./main.sh system ports         Listar portas abertas

UTILITÁRIOS:
  ./main.sh utils big-files      Encontrar arquivos grandes
  ./main.sh utils open-folder    [WSL] Abrir pasta atual no Explorer
  ./main.sh utils vscode         [WSL] Abrir VSCode no diretório atual

WSL:
  ./main.sh wsl clipboard        [WSL] Configurar clipboard (clip.exe)
  ./main.sh wsl mount-drives     [WSL] Listar discos Windows montados

EXEMPLOS:
  ./main.sh install base
  ./main.sh system update
  ./main.sh install dry-run

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

# Listar sequência de instalação
show_steps() {
	info "Sequência de instalação:"
	local i=1
	for step in "${INSTALL_STEPS[@]}"; do
		printf "  %d. %s\n" "$i" "$step"
		i=$((i + 1))
	done
}

# Dry-run: mostrar o que seria executado sem executar
install_dry_run() {
	info "[dry-run] Sequência que seria executada:"
	for step in "${INSTALL_STEPS[@]}"; do
		local script_path="$SCRIPT_DIR/$step.sh"
		if [[ -f "$script_path" ]]; then
			printf "  %-30s %s\n" "$step.sh" "[ok]"
		else
			printf "  %-30s %s\n" "$step.sh" "[não encontrado]"
		fi
	done
}

# Instalação completa
install_all() {
	info "Iniciando instalação completa..."

	for script in "${INSTALL_STEPS[@]}"; do
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
		case "$subcommand" in
		all) install_all ;;
		list) show_steps ;;
		dry-run) install_dry_run ;;
		"")
			error "Especifique: base, shell, cli-tools, terminal, dev-tools, dotfiles, bootstrap, all, list, dry-run"
			exit 1
			;;
		*) run_script "install" "$subcommand" ;;
		esac
		;;
	system)
		case "$subcommand" in
		"") error "Especifique: update, clean, ou ports"; exit 1 ;;
		*) run_script "system" "$subcommand" ;;
		esac
		;;
	utils)
		case "$subcommand" in
		"") error "Especifique: open-folder, vscode, ou big-files"; exit 1 ;;
		*) run_script "utils" "$subcommand" ;;
		esac
		;;
	wsl)
		case "$subcommand" in
		"") error "Especifique: clipboard ou mount-drives"; exit 1 ;;
		*) run_script "wsl" "$subcommand" ;;
		esac
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
