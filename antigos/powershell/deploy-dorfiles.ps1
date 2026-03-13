<# deploy-dotfiles.ps1
   - Fase 1: remove links antigos (ou faz backup se não for link)
   - Fase 2: recria symlinks
   - Use: powershell -ExecutionPolicy Bypass -File .\deploy-dotfiles.ps1 [-DryRun]
#>

param(
  [switch]$DryRun  # mostra o que faria, sem mudar nada
)

# === Config ===
$repo     = "C:\Users\itinerario\leo\development\dotfiles"
$homePath = "C:\Users\itinerario"

# Liste aqui o que quer linkar (arquivos/pastas relativos ao $repo)
$dotfiles = @(
  ".bashrc",
  ".gitignore",
  ".config",
  ".fonts"
)

# Pasta de backups (só usada se existir algo real no lugar do link)
$backupRoot = Join-Path $homePath (".dotfiles_backup_" + (Get-Date -Format "yyyyMMdd_HHmmss"))

function Is-Link($p) {
  if (-not (Test-Path $p)) { return $false }
  try {
    $gi = Get-Item -LiteralPath $p -Force
    # LinkType existe nas versões novas; como fallback usa atributo ReparsePoint
    return ($gi | Get-Member -Name LinkType -ErrorAction SilentlyContinue) -and $gi.LinkType -in @("SymbolicLink","Junction")
  } catch { return $false }
}

function Remove-Existing-Or-Backup($linkPath) {
  if (-not (Test-Path $linkPath)) { return }

  if (Is-Link $linkPath) {
    Write-Host "[REMOVER] link $linkPath"
    if (-not $DryRun) { Remove-Item -LiteralPath $linkPath -Force -Recurse }
  } else {
    # é arquivo/pasta real: mover para backup
    $rel = Split-Path -Leaf $linkPath
    $dest = Join-Path $backupRoot $rel
    Write-Host "[BACKUP]  $linkPath  ->  $dest"
    if (-not $DryRun) {
      New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
      Move-Item -LiteralPath $linkPath -Destination $dest -Force
    }
  }
}

function Ensure-Parent($p) {
  $parent = Split-Path -Parent $p
  if ($parent -and -not (Test-Path $parent)) {
    Write-Host "[MKDIR]   $parent"
    if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
  }
}

function Create-Link($linkPath, $targetPath) {
  $isDir = (Test-Path $targetPath -PathType Container)
  $type  = "SymbolicLink"
  Write-Host "[LINK]    $linkPath -> $targetPath ($type)"
  if ($DryRun) { return }

  try {
    New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath | Out-Null
  } catch {
    # Fallback: alguns ambientes bloqueiam symlink de diretório -> tenta Junction
    if ($isDir) {
      Write-Host "          (fallback) tentando Junction"
      New-Item -ItemType Junction -Path $linkPath -Target $targetPath | Out-Null
    } else {
      throw
    }
  }
}

# === FASE 1: Remoção / Backup ===
foreach ($item in $dotfiles) {
  $target = Join-Path $repo $item
  $link   = Join-Path $homePath $item
  Remove-Existing-Or-Backup $link
}

# === FASE 2: Criação dos links ===
foreach ($item in $dotfiles) {
  $target = Join-Path $repo $item
  $link   = Join-Path $homePath $item

  if (-not (Test-Path $target)) {
    Write-Host "[SKIP]    destino não existe: $target" -ForegroundColor Yellow
    continue
  }

  Ensure-Parent $link
  Create-Link $link $target
}

Write-Host "`nConcluído." -ForegroundColor Green
if (Test-Path $backupRoot) {
  Write-Host "Backups guardados em: $backupRoot" -ForegroundColor Cyan
}

