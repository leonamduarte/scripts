# Análise do Repositório scripts-wsl

## Overview

O repositório `scripts-wsl` contém uma suite de automação para configuração de ambientes de desenvolvimento no WSL (Windows Subsystem for Linux) com Ubuntu 22.04 LTS. O projeto evoluiu de scripts shell simples para uma aplicação TUI em Go (Bubble Tea) que fornece uma interface interativa para gerenciar a instalação de ferramentas de desenvolvimento.

**Objetivo principal:** Criar um ambiente de desenvolvimento completo e produtivo no WSL com:
- Shell: Fish + Starship
- Terminal: Alacritty
- Editor: Neovim
- Ferramentas CLI: ripgrep, fd, bat, eza, fzf, zoxide, lazygit, yazi
- Dev tools: git, GitHub CLI, fnm (Node), Python, pipx

**Tecnologias principais:**
- Go + Bubble Tea (TUI)
- Bash (scripts de instalação)
- WSL/Ubuntu 22.04

---

## Estrutura

```
scripts-wsl/
├── wsl-bootstrap                   # Executável Go (Linux)
├── main.sh                         # Dispatcher CLI legacy
├── bootstrap.go/                   # Código fonte Go
│   ├── main.go                     # Entry point
│   ├── model.go                    # Estado e menus
│   ├── views.go                    # Renderização TUI
│   ├── commands.go                 # Comandos WSL
│   ├── go.mod                      # Dependências
│   └── Makefile
├── install/                        # Scripts de instalação
│   ├── base.sh                     # Pacotes essenciais
│   ├── shell.sh                    # Fish + Starship
│   ├── cli-tools.sh                # ripgrep, fd, bat, etc
│   ├── terminal.sh                 # Alacritty (snap)
│   ├── dev-tools.sh                # git, gh, fnm, neovim
│   ├── dotfiles.sh                 # Clonar dotfiles
│   └── bootstrap.ps1               # PowerShell (Windows)
├── system/                         # Scripts de sistema
│   ├── update.sh                   # Atualizar pacotes
│   ├── clean.sh                    # Limpar sistema
│   └── ports.sh                    # Listar portas
├── utils/                          # Utilitários
│   ├── open-folder.sh              # Abrir Explorer
│   ├── vscode.sh                   # Abrir VSCode
│   └── big-files.sh                # Encontrar arquivos grandes
├── wsl/                            # Integração WSL
│   ├── clipboard.sh                # Configurar clipboard
│   └── mount-drives.sh             # Montar discos
├── lib/                            # Bibliotecas
│   └── utils.sh                    # Funções compartilhadas
└── README.md                       # Documentação principal
```

---

## Hotspots

### 1. **Sistema de Logs no TUI** (commands.go)
**Local:** `bootstrap-go/commands.go` (200-250)
**Problema:** O sistema de logs usa `stderr` para mensagens de infocional
**Estado:** Corrigido
**Solução:** `log_info() { echo ... >&2 }` envia logs para stderr, evitando interferência na TUI

### 2. **Goroutine Leak em runScriptWithLogs** (commands.go)
**Local:** `bootstrap-go/commands.go` (235-245)
**Problema:** Canal era fechado antes de enviar mensagens finais
**Estado:** Corrigido
**Solução:** Reordenado `close(logChan)` para após envio de mensagens de sucesso/falha

### 3. **Neovim com Múltiplos Métodos de Instalação** (dev-tools.sh)
**Local:** `install/dev-tools.sh` (70-90)
**Problema:** Snap não está disponível em todos os ambientes WSL
**Estado:** Corrigido
**Solução:** Fallback para AppImage e APT quando snap falhar

---

## Riscos

### 1. **WSL requeire reinicialização**
**Problema:** Após instalar `snapd`, o WSL pode precisar reiniciar para funcionar corretamente
**Mitigação:** Documentar no README ou usar AppImage como fallback

### 2. **Caminhos relativos no Go**
**Problema:** `go run .` funciona diferente de executável compilado
**Mitigação:** `getWorkingDir()` detecta se está em `bootstrap-go/` e ajusta caminho

### 3. **dependências de systemd**
**Problema:** Snap requer systemd, que pode não estar habilitado no WSL
**Mitigação:** Usar múltiplos métodos de instalação do Neovim

---

## Invariantes

### 1. **Estrutura de Scripts**
Todos os scripts de instalação seguem padrão:
- `#!/usr/bin/env bash`
- `set -euo pipefail`
- Source `lib/utils.sh`
- Usar funções `info()`, `ok()`, `log_warn()`, `log_error()`

### 2. **Sistema de Logging**
Todas as mensagens de log usam stderr (`>&2`):
- `[INFO]` - Informação
- `[OK]` - Sucesso
- `[WARN]` - Aviso
- `[ERROR]` - Erro

### 3. **TUI com Canais de Logs**
O TUI usa canais (channels) para comunicação:
- `logChan chan string` - Buffer de logs
- WaitGroup para sincronização
- Tick messages para atualização em tempo real

### 4. **Múltiplos Métodos para Neovim**
O script dev-tools.sh usa múltiplos métodos:
1. Snap (preferido)
2. AppImage (fallback)
3. APT (último recurso)

---

## Recomendados Next Steps

### 1. **Corrigir o executável Linux**
- O compilado não está atualizado com as correções
- Precisa recompilar: `cd bootstrap-go && go build -o ../wsl-bootstrap .`

### 2. **Documentar WSL/snapd**
- Adicionar instruções para habilitar systemd no WSL se necessário
- Alternativamente, documentar método AppImage

### 3. **Adicionar Testes**
- Criar testes unitários para `getWorkingDir()`
- Testar scripts shell (ex: `shellcheck`)

### 4. **Melhorar TUI**
- Adicionar suporte a seleção de texto (removido `WithAltScreen`)
- Melhorar progresso (atualmente sempre 0%)
- Adicionar indicador de atividade durante instalação

### 5. **Limpar Código**
- Remover funções não usadas (`runScript` antigo)
- Remover `debugPrint` quando `debugMode = false`
- Consolidar lógica de execução de scripts

---

## Status Atual

- ✅ Estrutura mapeada
- ✅ Hotspots identificados (3)
- ✅ Riscos documentados (3)
- ✅ Invariantes definidos (4)
- ⚠️ Análise finalizada, aguardando correção do executável Linux
