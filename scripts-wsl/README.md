# bashln-scripts WSL Edition

Coleção de scripts para configuração automatizada do WSL (Windows Subsystem for Linux) com Ubuntu 22.04 LTS.

## Objetivo

Criar um ambiente de desenvolvimento completo e produtivo no WSL com:
- **Shell**: Fish + Starship
- **Terminal**: Alacritty
- **Editor**: Neovim
- **Ferramentas CLI modernas**: ripgrep, fd, bat, eza, fzf, zoxide, lazygit, yazi
- **Dev tools**: git, GitHub CLI, fnm (Node), Python, pipx

## Estrutura

```
scripts-wsl/
├── wsl-bootstrap               # Aplicativo Go com TUI (executável Linux)
├── main.sh                      # Dispatcher CLI (legacy)
├── lib/
│   └── utils.sh                # Biblioteca compartilhada
├── install/                     # Scripts de instalação
│   ├── bootstrap.ps1           # PowerShell bootstrap
│   ├── base.sh
│   ├── shell.sh
│   ├── cli-tools.sh
│   ├── terminal.sh
│   ├── dev-tools.sh
│   └── dotfiles.sh
├── system/                      # Scripts de sistema
│   ├── update.sh
│   ├── clean.sh
│   └── ports.sh
├── utils/                       # Utilitários
│   ├── open-folder.sh
│   ├── vscode.sh
│   └── big-files.sh
├── wsl/                         # Integração WSL
│   ├── clipboard.sh
│   └── mount-drives.sh
└── bootstrap-go/                # Código fonte Go
    ├── main.go
    ├── model.go
    ├── views.go
    ├── commands.go
    ├── Makefile
    └── go.mod
```

## Instalação - Método Recomendado (Aplicativo Go)

### 🆕 NOVO: Executar DENTRO do WSL (Recomendado)

Agora o aplicativo roda **dentro do WSL/Ubuntu**, não mais no Windows!

**Vantagens:**
- ✅ Output em tempo real visível
- ✅ Sem erros de caminho
- ✅ Mais rápido
- ✅ Debug facilitado

### 1. Clone e Execute (Dentro do WSL)

```bash
# No WSL (Ubuntu)
git clone https://github.com/bashln/scripts ~/scripts-wsl
cd ~/scripts-wsl/bootstrap-go

# Execute
go run .
```

### 2. Ou Compile um Executável

```bash
cd ~/scripts-wsl/bootstrap-go
go build -o ../wsl-bootstrap ..
cd ..
./wsl-bootstrap
```

**Funcionalidades:**
- 🎯 Menu interativo com navegação por teclado
- 📦 Instalação completa com um clique
- 🔍 Verificação automática do WSL
- ✅ Feedback visual em tempo real
- 🎨 Interface moderna e colorida

### Menu do Aplicativo

```
🐧 WSL Bootstrap v2.0

✓ WSL instalado

INSTALAÇÃO
  ▸ 📦 Bootstrap Ubuntu WSL      - Instalar Ubuntu 22.04 no WSL
    🚀 Instalação Completa        - Instalar todos os pacotes
       Base                       - Pacotes essenciais
       Shell                      - Fish + Starship
       CLI Tools                  - ripgrep, eza, fzf, etc
       Dev Tools                  - git, gh, fnm, neovim
       Dotfiles                   - Clonar e configurar dotfiles

SISTEMA
    🔄 Atualizar Sistema          - Atualizar pacotes
    🧹 Limpar Sistema             - Limpar cache
    📡 Listar Portas              - Mostrar portas abertas

UTILITÁRIOS
    📂 Abrir Explorer             - Abrir pasta no Windows Explorer
    📝 Abrir VSCode               - Abrir VSCode no diretório atual
    🔍 Verificar Distros          - Listar distribuições WSL
```

### Compilar do Código Fonte

Se quiser compilar você mesmo:

```powershell
cd scripts-wsl\bootstrap-go

# Baixar dependências
make deps

# Compilar
make build

# Ou compilar versão otimizada
make release
```

## Instalação - Método Alternativo (Shell Scripts)

Se preferir usar os scripts shell diretamente:

### 1. Bootstrap (Windows)

```powershell
wsl --install -d Ubuntu-22.04
```

Reinicie o computador quando solicitado.

### 2. Configuração Completa (WSL)

Após instalar o Ubuntu, abra o WSL e execute:

```bash
cd ~/scripts-wsl

# Instalação completa
./main.sh install all

# Ou passo a passo:
./main.sh install base        # Essenciais
./main.sh install shell       # Fish + Starship
./main.sh install cli-tools   # CLI tools
./main.sh install dev-tools   # Dev tools
./main.sh install dotfiles    # Dotfiles
```

### 3. Usando

Após a instalação, reinicie o terminal e use o Fish:

```bash
fish
```

## Comandos Disponíveis

### Instalação
```bash
./main.sh install bootstrap    # Instalar Ubuntu WSL
./main.sh install base         # Essenciais + update
./main.sh install shell        # Fish + Starship
./main.sh install cli-tools    # CLI tools
./main.sh install terminal     # Alacritty
./main.sh install dev-tools    # Git, gh, fnm, Neovim
./main.sh install dotfiles     # Dotfiles
./main.sh install all          # Tudo
```

### Sistema
```bash
./main.sh system update        # Atualizar pacotes
./main.sh system clean         # Limpar sistema
./main.sh system ports         # Listar portas
```

### Utilitários
```bash
./main.sh utils open-folder    # Abrir pasta no Explorer
./main.sh utils vscode         # Abrir VSCode
./main.sh utils big-files      # Encontrar arquivos grandes
```

### WSL
```bash
./main.sh wsl clipboard        # Configurar clipboard
./main.sh wsl mount-drives     # Ver discos montados
```

## Ferramentas Instaladas

### CLI Tools
- **ripgrep** - grep moderno e rápido
- **fd** - find alternativo
- **bat** - cat com syntax highlighting
- **eza** - ls moderno (com ícones)
- **fzf** - fuzzy finder
- **zoxide** - cd inteligente
- **jq** - processador JSON
- **btop** - monitor de recursos
- **tmux** - terminal multiplexer
- **yazi** - file manager TUI
- **lazygit** - TUI para git

### Dev Tools
- **git** - versionamento
- **gh** - GitHub CLI
- **fnm** - Node.js version manager
- **python3** + **pipx**
- **neovim** - editor (PPA unstable)

### Shell
- **fish** - shell amigável
- **starship** - prompt customizável
- **fisher** - plugin manager

## Dotfiles

Os dotfiles são clonados de:
- **Repo**: https://github.com/bashln/dotfiles
- **Branch**: windows

Configs linkadas:
- `~/.config/fish/`
- `~/.config/alacritty/`
- `~/.config/nvim/`
- `~/.config/starship.toml`

## Requisitos

- Windows 11 (ou Windows 10 com WSL2)
- WSL habilitado
- Ubuntu 22.04 LTS

## Próximos Passos

Após instalar:

1. Configure o Git:
   ```bash
   git config --global user.name "Seu Nome"
   git config --global user.email "seu@email.com"
   ```

2. Instale as fontes (no Windows):
   - FiraCode Nerd Font
   - JetBrains Mono Nerd Font

3. Instale o Windows Terminal ou use Alacritty

4. Personalize o Starship editando `~/.config/starship.toml`

## Aliases Disponíveis

No Fish (após instalar dotfiles):

```fish
# Git
gs          # git status
ga          # git add -A
gc          # git commit -m
gp          # git push
gl          # git pull
gco         # git checkout
clone       # git clone
lz          # lazygit

# Navegação
..          # cd ..
...         # cd ../..
v           # nvim

# Listagem
ls          # eza -al (com ícones)
la          # eza -a
ll          # eza -l
lt          # eza -aT

# WSL
explorer    # abrir no Explorer
code        # abrir VSCode
```

## Atualizações

Para atualizar as ferramentas:

```bash
./main.sh system update
```

Para atualizar dotfiles:

```bash
cd ~/dotfiles
git pull
./main.sh install dotfiles
```

## Licença

MIT - Use, modifique e compartilhe livremente.

---

**Autor**: bashln
