#!/usr/bin/env bash
# =============================================================================
# lib/utils.sh - Biblioteca de utilitários compartilhada para scripts/ubuntu-wsl
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

# Instalar pacote APT (idempotente)
ensure_apt() {
	local pkg="$1"
	if dpkg -l "$pkg" &>/dev/null; then
		log_info "Pacote já instalado: $pkg"
		return 0
	fi
	log_info "Instalando: $pkg"
	sudo apt-get install -y "$pkg" && log_ok "$pkg instalado"
}

# Instalar múltiplos pacotes
install_list() {
	local pkgs=("$@")
	local ok=() missing=() failed=()

	for pkg in "${pkgs[@]}"; do
		log_info "Instalando: $pkg"
		set +e
		local out
		out="$(sudo apt-get install -y "$pkg" 2>&1)"
		local rc=$?
		set -e

		if [[ $rc -eq 0 ]]; then
			ok+=("$pkg")
			log_ok "$pkg instalado"
		elif grep -qiE "unable to locate package|not found" <<<"$out"; then
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

# Adicionar PPA (idempotente)
add_ppa() {
	local ppa="$1"
	if ! grep -q "^deb.*$ppa" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
		log_info "Adicionando PPA: $ppa"
		sudo add-apt-repository -y "ppa:$ppa"
		sudo apt-get update
	else
		log_info "PPA já adicionado: $ppa"
	fi
}

# Baixar e instalar .deb
download_install_deb() {
	local url="$1"
	local pkg_name="${2:-package}"
	local temp_dir
	temp_dir=$(mktemp -d)

	log_info "Baixando $pkg_name..."
	wget -q "$url" -O "$temp_dir/package.deb"

	log_info "Instalando $pkg_name..."
	sudo dpkg -i "$temp_dir/package.deb" || sudo apt-get install -f -y

	rm -rf "$temp_dir"
	log_ok "$pkg_name instalado"
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
export -f is_wsl has_command ensure_apt install_list
export -f backup_file check_root confirm add_ppa download_install_deb link_config
