# WSL Bootstrap - Modo WSL (Dentro do Ubuntu)

## 🚀 Como Usar (NOVO - Dentro do WSL)

### 1. Clone o repositório DENTRO do WSL

```bash
# No WSL (Ubuntu)
git clone https://github.com/bashln/scripts ~/scripts/ubuntu-wsl
cd ~/scripts/ubuntu-wsl/bootstrap-go
```

### 2. Execute com Go

```bash
# Certifique-se de que tem o Go instalado
go version

# Execute diretamente
go run .
```

### 3. Ou compile um executável

```bash
# Compilar
go build -o ../wsl-bootstrap .

# Executar
cd ..
./wsl-bootstrap
```

---

## ✅ Correções Recentes

### v2.1 - Correções de Path
- ✅ Corrigido erro de path com `go run` (usando `os.Getwd()`)
- ✅ Removido modo AltScreen para permitir seleção de texto
- ✅ Logs agora são copiáveis!

---

## 📋 O que mudou?

### Antes (Windows)
- Executável `.exe` no Windows
- Chamava `wsl.exe` para executar comandos
- Output não era visível
- Caminhos complexos Windows ↔ WSL

### Agora (Dentro do WSL)
- Roda diretamente no Ubuntu
- Executa scripts bash nativamente
- **Output em tempo real visível!**
- **Texto selecionável e copiável!**
- Caminhos simples (Linux)

---

## 🎮 Controles

- **↑/↓** ou **j/k**: Navegar
- **Enter**: Selecionar
- **ESC**: Voltar/Sair
- **q**: Sair

---

## 📦 Menu

### INSTALAÇÃO
- 🚀 **Instalação Completa** - Instala tudo de uma vez
- Base - Pacotes essenciais
- Shell - Fish + Starship
- CLI Tools - ripgrep, eza, fzf, etc
- Dev Tools - git, gh, fnm, neovim
- Dotfiles - Suas configurações

### SISTEMA
- Atualizar Sistema
- Limpar Sistema
- Listar Portas

### UTILITÁRIOS
- Abrir Explorer (Windows)
- Abrir VSCode
- Verificar Distros

---

## 🐛 Debug

Agora você pode ver:
- ✅ Logs em tempo real
- ✅ Progresso da instalação
- ✅ Erros detalhados
- ✅ Status de cada etapa

---

## 💡 Dica

Para facilitar, adicione um alias no seu `.bashrc` ou `.zshrc`:

```bash
alias wsl-bootstrap='cd ~/scripts/ubuntu-wsl/bootstrap-go && go run .'
```

---

**Execute agora:** `go run .` dentro da pasta `bootstrap-go`!
