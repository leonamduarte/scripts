# blueprint-sync - Análise do Repositório scripts-wsl

## Estrutura Atual Identificada

### Comandos Disponíveis no TUI:

| Menu | Itens | Script |
|------|-------|--------|
| INSTALAÇÃO | 📦 Bootstrap Ubuntu WSL | `wsl --install` |
| | 🚀 Instalação Completa | `install/*.sh` (todos) |
| | Base | `install/base.sh` |
| | Shell (Fish) | `install/shell.sh` |
| | CLI Tools | `install/cli-tools.sh` |
| | Dev Tools | `install/dev-tools.sh` |
| | Dotfiles | `install/dotfiles.sh` |
| SISTEMA | 🔄 Atualizar Sistema | `system/update.sh` |
| | 🧹 Limpar Sistema | `system/clean.sh` |
| | 📡 Listar Portas | `system/ports.sh` |
| UTILITÁRIOS | 📂 Abrir Explorer | `explorer.exe` |
| | 📝 Abrir VSCode | `code .` |
| | 🔍 Verificar Distros | Listar WSL |

### Estrutura de Instalação (install/):

1. **base.sh** - Pacotes essenciais (curl, wget, git, build-essential)
2. **shell.sh** - Fish + Starship + Fisher
3. **cli-tools.sh** - ripgrep, fd, bat, eza, fzf, zoxide, jq, btop, tmux, lazygit, yazi
4. **terminal.sh** - Alacritty via snap
5. **dev-tools.sh** - Git, GitHub CLI, fnm, Python, pipx, Neovim (3 métodos)
6. **dotfiles.sh** - Clona dotfiles do repo bashln/dotfiles

---

## Recomendações

### Prioridade Alta:
1. **Corrigir executável Linux** - Recompilar `wsl-bootstrap` com todas as correções
2. **Testar fluxo completo** - Executar `Instalação Completa` no WSL

### Prioridade Média:
3. **Adicionar testes** - Testar scripts shell com shellcheck
4. **Melhorar progresso** - Mostrar porcentagem real na TUI

### Prioridade Baixa:
5. **Documentar WSL setup** - Instruções para habilitar systemd se necessário
6. **Adicionar suporte a zsh** - Além de Fish

---

## Status dos Arquivos

| Arquivo | Status |
|---------|--------|
| `analysis.md` | ✅ Criado |
| `blueprints.md` | ⚠️ Precisa atualizar |
| `README.md` | ✅ Atualizado |
| `install/dev-tools.sh` | ✅ Corrigido (múltiplos métodos) |
| `lib/utils.sh` | ✅ Corrigido (stderr) |
| `bootstrap-go/commands.go` | ✅ Corrigido (canal, path) |
| `wsl-bootstrap` | ⚠️ Precisa recompilar |
