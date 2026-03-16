#!/bin/bash
# lib/utils.sh

# Definição de Arquivo de Log Global
LOG_FILE="${LOG_FILE:-/tmp/install-arch-$(date +%Y%m%d-%H%M%S).log}"

# Cores
BLUE='\e[34m'
GREEN='\e[32m'
YELLOW='\e[33m'
RED='\e[31m'
RESET='\e[0m'

# TUI (Charm Gum)
GUM_AVAILABLE=0
if command -v gum >/dev/null 2>&1; then
    GUM_AVAILABLE=1
fi
export GUM_AVAILABLE

# Função de Log Interna (Escreve no arquivo e na tela)
_log() {
    local level="$1"
    local color="$2"
    local msg="$3"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Escrita no Arquivo (Sem cores, com timestamp)
    echo "[$timestamp] [$level] $msg" >> "$LOG_FILE"

    # Escrita na Tela (Com cores ou TUI)
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        local gum_level="info"
        case "$level" in
            WARN) gum_level="warn" ;;
            FAIL) gum_level="error" ;;
            *) gum_level="info" ;;
        esac
        gum log --level "$gum_level" -- "[$level] $msg" >&2
    else
        printf "${color}[%s] %s${RESET}\n" "$level" "$msg" >&2
    fi
}

info() { _log "INFO" "$BLUE" "$*"; }
ok()   { _log "OK"   "$GREEN" "$*"; }
warn() { _log "WARN" "$YELLOW" "$*"; }
fail() { _log "FAIL" "$RED" "$*"; }
die() {
    fail "$*"
    exit 1
}

# --- Função de Verificação de Pacotes (Agnóstica/Arch) ---
# Verifica se está instalado antes de chamar o pacman (Economiza tempo/Performance)
ensure_package() {
    local pkg="$1"
    
    if pacman -Qi "$pkg" &>/dev/null; then
        info "Pacote '$pkg' já instalado. Pulando."
        return 0
    fi

    info "Instalando pacote: $pkg..."
    # Redireciona stdout para log, mostra apenas erros na tela
    if sudo pacman -S --noconfirm --needed "$pkg" >> "$LOG_FILE" 2>&1; then
        ok "Pacote '$pkg' instalado."
    else
        fail "Erro ao instalar '$pkg'. Verifique o log: $LOG_FILE"
        return 1
    fi
}

ensure_aur_package() {
    local pkg="$1"
    
    if yay -Qi "$pkg" &>/dev/null; then
        info "Pacote AUR '$pkg' já instalado. Pulando."
        return 0
    fi

    info "Instalando pacote AUR: $pkg..."
    if yay -S --noconfirm --needed "$pkg" >> "$LOG_FILE" 2>&1; then
        ok "Pacote AUR '$pkg' instalado."
    else
        fail "Erro ao instalar o pacote AUR '$pkg'. Verifique o log: $LOG_FILE"
        return 1
    fi
}

ensure_flatpak_package() {
    local pkg="$1"
    
    if flatpak info "$pkg" &>/dev/null; then
        info "Pacote Flatpak '$pkg' já instalado. Pulando."
        return 0
    fi

    info "Instalando pacote Flatpak: $pkg..."
    if flatpak install -y flathub "$pkg" >> "$LOG_FILE" 2>&1; then
        ok "Pacote Flatpak '$pkg' instalado."
    else
        fail "Erro ao instalar o pacote Flatpak '$pkg'. Verifique o log: $LOG_FILE"
        return 1
    fi
}

# Rotaciona arquivos de log, mantendo apenas os ultimos N logs
# Uso: rotate_log "caminho/do/log.log" [max_logs] [max_age_days]
rotate_log() {
    local log_path="${1:-${LOG_FILE}}"
    local max_logs="${2:-3}"
    local max_age_days="${3:-30}"

    if [[ ! -f "$log_path" ]]; then
        return 0
    fi

    local dir
    dir=$(dirname "$log_path")
    local base
    base=$(basename "$log_path")

    # Remove logs mais antigos que max_age_days
    if [[ "$max_age_days" -gt 0 ]]; then
        local cutoff
        cutoff=$(date -d "$max_age_days days ago" +%s 2>/dev/null || echo "0")
        for f in "$dir"/${base}.*; do
            if [[ -f "$f" ]]; then
                local file_time
                file_time=$(stat -c %Y "$f" 2>/dev/null || echo "0")
                if [[ "$file_time" -lt "$cutoff" ]]; then
                    rm -f "$f"
                fi
            fi
        done
    fi

    # Remove o mais antigo (ex: .3)
    rm -f "${log_path}.${max_logs}"

    # Desloca logs: .2 -> .3, .1 -> .2
    for ((i=max_logs-1; i>=1; i--)); do
        local old_idx=$i
        local new_idx=$((i+1))
        if [[ -f "${log_path}.${old_idx}" ]]; then
            mv "${log_path}.${old_idx}" "${log_path}.${new_idx}"
        fi
    done

    # Move log atual para .1
    mv "$log_path" "${log_path}.1"

    return 0
}
