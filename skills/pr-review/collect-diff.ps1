<#
.SYNOPSIS
  Captures a diff and a file manifest for the pr-review fan-out.

.DESCRIPTION
  Writes the diff under review to a stable file and produces a manifest of
  changed files so every dimension sub-agent reviews the same input. Keep the
  git logic deterministic. Validate live with -Scope working before trusting.

.PARAMETER Scope
  working  = uncommitted changes in the working tree
  staged   = changes staged for commit
  branch   = changes on this branch vs BaseBranch

.PARAMETER BaseBranch
  The base branch to diff against when Scope is 'branch'. Default: main.

.PARAMETER OutDir
  Where to write diff.patch and manifest.txt. Default: .pr-review
#>

param(
    [ValidateSet('working', 'staged', 'branch')]
    [string]$Scope = 'working',

    [string]$BaseBranch = 'main',

    [string]$OutDir = '.pr-review'
)

$ErrorActionPreference = 'Stop'

# Confirm we are inside a git repo.
git rev-parse --is-inside-work-tree > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Not inside a git repository.'
    exit 1
}

if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

$diffPath = Join-Path $OutDir 'diff.patch'
$manifestPath = Join-Path $OutDir 'manifest.txt'

switch ($Scope) {
    'working' {
        git diff > $diffPath
        git diff --name-status > $manifestPath
    }
    'staged' {
        git diff --cached > $diffPath
        git diff --cached --name-status > $manifestPath
    }
    'branch' {
        # Diff this branch against the merge-base with BaseBranch.
        $mergeBase = (git merge-base HEAD $BaseBranch).Trim()
        if ([string]::IsNullOrWhiteSpace($mergeBase)) {
            Write-Error "Could not find merge-base with $BaseBranch."
            exit 1
        }
        git diff "$mergeBase..HEAD" > $diffPath
        git diff --name-status "$mergeBase..HEAD" > $manifestPath
    }
}

$diffSize = (Get-Item $diffPath).Length
if ($diffSize -eq 0) {
    Write-Warning "Diff is empty for scope '$Scope'. Nothing to review."
    exit 0
}

$fileCount = (Get-Content $manifestPath | Measure-Object -Line).Lines
Write-Host "Captured diff for scope '$Scope': $fileCount file(s), $diffSize bytes."
Write-Host "Diff:     $diffPath"
Write-Host "Manifest: $manifestPath"
