# bashln-scripts Fedora WSL Edition

Colecao de scripts para configurar um ambiente de desenvolvimento no WSL com Fedora Linux.

## Objetivo

Provisionar um setup de desenvolvimento no Fedora WSL com:
- Fish + Starship
- Alacritty
- Neovim
- CLI tools modernas: ripgrep, fd, bat, eza, fzf, zoxide, lazygit, yazi
- Dev tools: git, GitHub CLI, fnm, Python, pipx

## Estrutura

```text
scripts-wls/
|- wsl-bootstrap
|- main.sh
|- lib/
|- install/
|- system/
|- utils/
|- wsl/
\- go/fedora-wsl-bootstrap/
```

## Uso rapido

No Fedora WSL:

```bash
git clone https://github.com/bashln/scripts ~/scripts-wls
cd ~/scripts-wls
./main.sh install all
```

Se preferir a interface TUI em Go:

```bash
cd ~/scripts-wls/bootstrap-go
go run .
```

## Bootstrap do Fedora no WSL

No Windows, o bootstrap detecta automaticamente a release `FedoraLinux-*` mais recente disponivel em `wsl --list --online` e executa a instalacao correspondente.

Via PowerShell:

```powershell
cd scripts\scripts-wls\install
.\bootstrap.ps1
```

Ou via shell:

```bash
./main.sh install bootstrap
```

## Comandos

```bash
./main.sh install bootstrap
./main.sh install base
./main.sh install shell
./main.sh install cli-tools
./main.sh install terminal
./main.sh install dev-tools
./main.sh install dotfiles
./main.sh install all

./main.sh system update
./main.sh system clean
./main.sh system ports
```

## Diferencas desta versao

- `apt` foi substituido por `dnf`
- bootstrap troca Ubuntu por Fedora WSL
- scripts de shell, sistema e dev-tools foram ajustados para pacotes do Fedora
- a pasta nova `scripts-wls` preserva a versao antiga `scripts/fedora-wsl`

## Requisitos

- Windows 10/11 com WSL2
- Fedora Linux disponivel em `wsl --list --online`
- acesso sudo dentro do WSL

## Observacoes

- `Alacritty` depende de suporte grafico no WSL; se o pacote nao estiver disponivel no repositrio atual, o script apenas registra um aviso.
- `eza`, `yazi` e `lazygit` usam fallback por download quando necessario.
