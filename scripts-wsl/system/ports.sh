#!/usr/bin/env bash
# =============================================================================
# system/ports.sh - Listar portas abertas
# =============================================================================

set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"

echo "Portas abertas:"
echo "==============="

if has_command ss; then
	ss -tuln | grep LISTEN
elif has_command netstat; then
	netstat -tuln | grep LISTEN
else
	info "Instalando net-tools..."
	sudo apt-get install -y net-tools
	netstat -tuln | grep LISTEN
fi
