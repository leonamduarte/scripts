#!/usr/bin/env bash
# =============================================================================
# lib/utils.sh - Biblioteca de utilitários compartilhada para scripts/fedora-wsl
# =============================================================================

set -euo pipefail

# Cores ANSI
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging (usa stderr para não interferir com a TUI)
log_info() { echo -e "${BLUE}[INFO]${NC} $*" >&2; }
log_ok() { echo -e "${GREEN}[OK]${NC} $*" >&2; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*" >&2; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# info() alias para compatibilidade
info() { log_info "$@"; }

# Verificar se está rodando no WSL
is_wsl() {
	[[ -f /proc/version ]] && grep -qi microsoft /proc/version
}

# Verificar se comando existe
has_command() {
	command -v "$1" &>/dev/null
}

# Verificar se um pacote RPM está instalado
has_package() {
	rpm -q "$1" &>/dev/null
}

# Atualizar metadados do DNF uma vez por processo
refresh_dnf_cache() {
	if [[ "${DNF_CACHE_REFRESHED:-0}" -eq 0 ]]; then
		log_info "Atualizando metadados do DNF..."
		sudo dnf makecache -y
		export DNF_CACHE_REFRESHED=1
	fi
}

# Instalar pacote DNF (idempotente)
ensure_dnf() {
	local pkg="$1"
	if has_package "$pkg"; then
		log_info "Pacote já instalado: $pkg"
		return 0
	fi
	refresh_dnf_cache
	log_info "Instalando: $pkg"
	sudo dnf install -y "$pkg" && log_ok "$pkg instalado"
}

# Instalar múltiplos pacotes
install_list() {
	local pkgs=("$@")
	local ok=() missing=() failed=()

	refresh_dnf_cache

	for pkg in "${pkgs[@]}"; do
		log_info "Instalando: $pkg"
		set +e
		local out
		out="$(sudo dnf install -y "$pkg" 2>&1)"
		local rc=$?
		set -e

		if [[ $rc -eq 0 ]]; then
			ok+=("$pkg")
			log_ok "$pkg instalado"
		elif grep -qiE "no match for argument|unable to find a match|not found" <<<"$out"; then
			missing+=("$pkg")
			log_warn "Pacote não encontrado: $pkg"
		else
			failed+=("$pkg")
			log_error "Falha ao instalar: $pkg"
		fi
	done

	# Resumo
	echo
	log_info "===== RESUMO ====="
	echo "✅ Instalados: ${#ok[@]}"
	if [[ ${#ok[@]} -gt 0 ]]; then
		printf '   - %s\n' "${ok[@]}"
	fi
	echo "⚠️  Não encontrados: ${#missing[@]}"
	if [[ ${#missing[@]} -gt 0 ]]; then
		printf '   - %s\n' "${missing[@]}"
	fi
	echo "❌ Falhas: ${#failed[@]}"
	if [[ ${#failed[@]} -gt 0 ]]; then
		printf '   - %s\n' "${failed[@]}"
		return 1
	fi
	return 0
}

# Backup de arquivo
backup_file() {
	local file="$1"
	if [[ -f "$file" ]]; then
		local backup
		backup="${file}.backup.$(date +%Y%m%d-%H%M%S)"
		cp "$file" "$backup"
		log_info "Backup criado: $backup"
	fi
}

# Verificar se é root
check_root() {
	if [[ $EUID -eq 0 ]]; then
		log_error "Não execute como root/sudo"
		exit 1
	fi
}

# Perguntar confirmação
confirm() {
	local msg="${1:-Continuar?}"
	read -rp "$msg [y/N]: " response
	[[ "$response" =~ ^[Yy]$ ]]
}

# Criar symlink seguro
link_config() {
	local source="$1"
	local target="$2"

	if [[ -L "$target" ]]; then
		rm "$target"
	elif [[ -e "$target" ]]; then
		backup_file "$target"
		rm -rf "$target"
	fi

	ln -s "$source" "$target"
	log_ok "Link criado: $target -> $source"
}

# Exportar funções para serem usadas por outros scripts
export -f log_info log_ok log_warn log_error
export -f is_wsl has_command has_package refresh_dnf_cache ensure_dnf install_list
export -f backup_file check_root confirm link_config
