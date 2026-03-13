#requires -Version 5.1
<#
.SYNOPSIS
    Bootstrap WSL - Instalador de Ubuntu com TUI
.DESCRIPTION
    Script PowerShell com interface interativa para instalar e verificar WSL/Ubuntu
.EXAMPLE
    .\bootstrap.ps1
#>

[CmdletBinding()]
param()

# Configurações de cores
$Colors = @{
    Primary    = 'Cyan'
    Success    = 'Green'
    Warning    = 'Yellow'
    Error      = 'Red'
    Info       = 'White'
    Menu       = 'Magenta'
}

# Funções de UI
function Show-Header {
    Clear-Host
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor $Colors.Primary
    Write-Host "║           🐧 WSL Bootstrap - Ubuntu Installer            ║" -ForegroundColor $Colors.Primary
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor $Colors.Primary
    Write-Host ""
}

function Show-Menu {
    Write-Host "  Menu Principal:" -ForegroundColor $Colors.Menu
    Write-Host ""
    Write-Host "    [1] 📦 Instalar Ubuntu 22.04 LTS" -ForegroundColor $Colors.Info
    Write-Host "    [2] 🔍 Verificar instalação atual" -ForegroundColor $Colors.Info
    Write-Host "    [3] ❌ Sair" -ForegroundColor $Colors.Info
    Write-Host ""
}

function Get-UserChoice {
    $choice = Read-Host "  Escolha uma opção (1-3)"
    return $choice
}

function Show-Progress {
    param([string]$Message)
    Write-Host "  ⏳ $Message" -ForegroundColor $Colors.Warning -NoNewline
}

function Show-Success {
    param([string]$Message)
    Write-Host "`r  ✅ $Message" -ForegroundColor $Colors.Success
}

function Show-Error {
    param([string]$Message)
    Write-Host "  ❌ $Message" -ForegroundColor $Colors.Error
}

function Show-Info {
    param([string]$Message)
    Write-Host "  ℹ️  $Message" -ForegroundColor $Colors.Info
}

# Verificar se está rodando como Admin
function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Função principal de instalação
function Install-Ubuntu {
    Show-Header
    Write-Host "  📦 Instalando Ubuntu 22.04 LTS..." -ForegroundColor $Colors.Primary
    Write-Host ""
    
    # Verificar se já existe Ubuntu
    Show-Progress "Verificando instalações existentes..."
    try {
        $wslList = wsl --list --quiet 2>$null
        if ($wslList -match "Ubuntu") {
            Show-Success "Verificação concluída"
            Write-Host ""
            Show-Warning "Ubuntu já está instalado!"
            Write-Host ""
            Write-Host "Distros instaladas:" -ForegroundColor $Colors.Primary
            wsl --list --verbose
            Write-Host ""
            $continue = Read-Host "  Deseja continuar mesmo assim? (S/N)"
            if ($continue -notmatch "^[Ss]") {
                Show-Info "Operação cancelada pelo usuário"
                Pause
                return
            }
        } else {
            Show-Success "Verificação concluída"
        }
    } catch {
        Show-Error "Erro ao verificar WSL: $_"
        Pause
        return
    }
    
    Write-Host ""
    Write-Host "  ⚠️  A instalação será iniciada agora..." -ForegroundColor $Colors.Warning
    Write-Host "  Pressione ENTER para continuar ou CTRL+C para cancelar" -ForegroundColor $Colors.Info
    Write-Host ""
    Read-Host
    
    # Instalar Ubuntu
    Write-Host ""
    Show-Progress "Iniciando instalação do Ubuntu 22.04..."
    Write-Host ""
    
    try {
        # Executar instalação com output visível
        $process = Start-Process -FilePath "wsl.exe" -ArgumentList "--install", "-d", "Ubuntu-22.04" -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Show-Success "Ubuntu 22.04 instalado com sucesso!"
            Write-Host ""
            Write-Host "  ===============================================" -ForegroundColor $Colors.Success
            Write-Host "  🎉 Instalação concluída!" -ForegroundColor $Colors.Success
            Write-Host "  ===============================================" -ForegroundColor $Colors.Success
            Write-Host ""
            Show-Info "Próximos passos:"
            Write-Host "    1. Reinicie o computador se solicitado" -ForegroundColor $Colors.Info
            Write-Host "    2. Após reiniciar, execute: wsl" -ForegroundColor $Colors.Info
            Write-Host "    3. Configure seu usuário no primeiro acesso" -ForegroundColor $Colors.Info
            Write-Host "    4. Execute: ./main.sh install all" -ForegroundColor $Colors.Info
            Write-Host ""
        } else {
            Show-Error "A instalação retornou código de erro: $($process.ExitCode)"
        }
    } catch {
        Show-Error "Erro durante instalação: $_"
        Write-Host ""
        Show-Info "Tente executar manualmente: wsl --install -d Ubuntu-22.04"
    }
    
    Write-Host ""
    Pause
}

# Verificar instalação atual
function Check-Installation {
    Show-Header
    Write-Host "  🔍 Verificando instalação WSL..." -ForegroundColor $Colors.Primary
    Write-Host ""
    
    # Verificar versão do WSL
    Show-Progress "Verificando versão do WSL..."
    try {
        $wslVersion = wsl --version 2>&1
        Show-Success "WSL encontrado"
        Write-Host ""
        Write-Host "  Versão do WSL:" -ForegroundColor $Colors.Primary
        $wslVersion | ForEach-Object { Write-Host "    $_" -ForegroundColor $Colors.Info }
    } catch {
        Show-Error "WSL não encontrado ou não instalado"
    }
    
    Write-Host ""
    
    # Listar distros
    Show-Progress "Listando distribuições..."
    try {
        $distros = wsl --list --verbose 2>&1
        Show-Success "Distros encontradas"
        Write-Host ""
        Write-Host "  Distribuições instaladas:" -ForegroundColor $Colors.Primary
        $distros | ForEach-Object { 
            if ($_ -match "Ubuntu") {
                Write-Host "    $_" -ForegroundColor $Colors.Success
            } elseif ($_ -match "\*") {
                Write-Host "    $_" -ForegroundColor $Colors.Warning
            } else {
                Write-Host "    $_" -ForegroundColor $Colors.Info
            }
        }
    } catch {
        Show-Error "Nenhuma distribuição encontrada"
    }
    
    Write-Host ""
    Write-Host "  ===============================================" -ForegroundColor $Colors.Primary
    Show-Info "Status: Verificação concluída"
    Write-Host ""
    Pause
}

function Show-Warning {
    param([string]$Message)
    Write-Host "  ⚠️  $Message" -ForegroundColor $Colors.Warning
}

function Pause {
    Write-Host ""
    Read-Host "  Pressione ENTER para continuar"
}

# Loop principal
function Main {
    # Verificar admin
    if (-not (Test-Administrator)) {
        Clear-Host
        Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor $Colors.Error
        Write-Host "║                    ⚠️  ATENÇÃO                           ║" -ForegroundColor $Colors.Error
        Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor $Colors.Error
        Write-Host ""
        Show-Error "Este script precisa ser executado como Administrador!"
        Write-Host ""
        Show-Info "Feche o PowerShell e abra novamente como Administrador"
        Write-Host ""
        Pause
        exit 1
    }
    
    # Loop do menu
    do {
        Show-Header
        Show-Menu
        $choice = Get-UserChoice
        
        switch ($choice) {
            '1' { Install-Ubuntu }
            '2' { Check-Installation }
            '3' { 
                Show-Header
                Write-Host "  👋 Até logo!" -ForegroundColor $Colors.Success
                Write-Host ""
                exit 0
            }
            default {
                Show-Header
                Show-Error "Opção inválida! Escolha 1, 2 ou 3"
                Pause
            }
        }
    } while ($true)
}

# Iniciar
Main
