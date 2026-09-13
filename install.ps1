<#
.SYNOPSIS
  Installs Prime Directive agents, skills, and rules into a target .claude dir.

.DESCRIPTION
  Copies or links the agents, skills, and rules from this repo into a target
  Claude Code directory (global ~/.claude or a project's .claude). Copy mode is
  self-contained and safe to pin per engagement. Symlink mode keeps every
  install in sync with the repo via git pull.

  Creating a symbolic link on Windows requires either an elevated session or
  Developer Mode. When that privilege is missing, symlink mode falls back to a
  directory junction, which needs no elevation and behaves the same way for
  this purpose: the target directory reads through to the repo.

.PARAMETER Target
  The .claude directory to install into.
  Default: $env:USERPROFILE\.claude

.PARAMETER Mode
  copy    = copy files (per-install isolation, pin-friendly)
  symlink = link to this repo (single source of truth, updates on pull)

.EXAMPLE
  ./install.ps1 -Mode copy -Target "$env:USERPROFILE\.claude"

.EXAMPLE
  ./install.ps1 -Mode symlink -Target .\.claude
#>

param(
    [string]$Target = (Join-Path $env:USERPROFILE '.claude'),

    [ValidateSet('copy', 'symlink')]
    [string]$Mode = 'copy'
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$parts = @('agents', 'skills', 'rules')

foreach ($p in $parts) {
    if (-not (Test-Path (Join-Path $RepoRoot $p))) {
        throw "Repo is missing '$p'. Run this script from a full checkout."
    }
}

# Back up an existing install before touching it. Linked parts are skipped:
# they point at the repo, so there is nothing local to preserve.
if (Test-Path $Target) {
    $ts = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backup = Join-Path $Target "backups\install-$ts"
    $backedUp = $false
    foreach ($p in $parts) {
        $src = Join-Path $Target $p
        if (Test-Path $src) {
            $item = Get-Item $src -Force
            if ($item.LinkType) { continue }
            if (-not $backedUp) {
                New-Item -ItemType Directory -Path $backup -Force | Out-Null
                $backedUp = $true
            }
            Copy-Item $src $backup -Recurse -Force
        }
    }
    if ($backedUp) { Write-Host "Backed up existing install to $backup" }
}

New-Item -ItemType Directory -Path $Target -Force | Out-Null

function New-RepoLink {
    param([string]$Path, [string]$LinkTarget)
    try {
        New-Item -ItemType SymbolicLink -Path $Path -Target $LinkTarget -ErrorAction Stop | Out-Null
        return 'symlink'
    }
    catch {
        New-Item -ItemType Junction -Path $Path -Target $LinkTarget -ErrorAction Stop | Out-Null
        return 'junction'
    }
}

foreach ($p in $parts) {
    $src = Join-Path $RepoRoot $p
    $dst = Join-Path $Target $p

    if (Test-Path $dst) {
        $existing = Get-Item $dst -Force
        if ($existing.LinkType) {
            # Remove the link itself, never the repo directory it points at.
            $existing.Delete()
        }
        else {
            Remove-Item $dst -Recurse -Force
        }
    }

    if ($Mode -eq 'symlink') {
        $kind = New-RepoLink -Path $dst -LinkTarget $src
        Write-Host "Linked $p -> $src ($kind)"
    }
    else {
        Copy-Item $src $dst -Recurse -Force
        Write-Host "Copied $p"
    }
}

Write-Host ""
Write-Host "Prime Directive installed to $Target (mode: $Mode)."
Write-Host "Restart Claude Code so the skills register."
