<#
.SYNOPSIS
  Installs Prime Directive agents, skills, and rules into a target .claude dir.

.DESCRIPTION
  Copies or symlinks the agents, skills, and rules from this repo into a target
  Claude Code directory (global ~/.claude or a project's .claude). Copy mode is
  self-contained and safe to pin per engagement. Symlink mode keeps every
  install in sync with the repo via git pull.

.PARAMETER Target
  The .claude directory to install into.
  Default: $env:USERPROFILE\.claude

.PARAMETER Mode
  copy    = copy files (per-install isolation, pin-friendly)
  symlink = symlink to this repo (single source of truth, updates on pull)

.EXAMPLE
  ./install.ps1 -Mode copy -Target C:\Users\Brian\.claude
#>

param(
    [string]$Target = (Join-Path $env:USERPROFILE '.claude'),

    [ValidateSet('copy', 'symlink')]
    [string]$Mode = 'copy'
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$parts = @('agents', 'skills', 'rules')

# Back up an existing install before touching it.
if (Test-Path $Target) {
    $ts = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backup = Join-Path $Target "backups\install-$ts"
    New-Item -ItemType Directory -Path $backup -Force | Out-Null
    foreach ($p in $parts) {
        $src = Join-Path $Target $p
        if (Test-Path $src) { Copy-Item $src $backup -Recurse -Force }
    }
    Write-Host "Backed up existing install to $backup"
}

New-Item -ItemType Directory -Path $Target -Force | Out-Null

foreach ($p in $parts) {
    $src = Join-Path $RepoRoot $p
    $dst = Join-Path $Target $p

    if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }

    if ($Mode -eq 'symlink') {
        New-Item -ItemType SymbolicLink -Path $dst -Target $src | Out-Null
        Write-Host "Linked $p -> $src"
    }
    else {
        Copy-Item $src $dst -Recurse -Force
        Write-Host "Copied $p"
    }
}

Write-Host ""
Write-Host "Prime Directive installed to $Target (mode: $Mode)."
Write-Host "Restart Claude Code so the skills register."
