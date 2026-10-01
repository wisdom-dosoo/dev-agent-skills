<#
.SYNOPSIS
  Install skills into any coding agent's discovery path (no admin needed).
.EXAMPLE
  .\install.ps1
  .\install.ps1 -Agent codex
  .\install.ps1 -Agent all
  .\install.ps1 -Agent copilot -Dest "D:\skills"
  .\install.ps1 -Agent agents -Link
#>
param(
  [ValidateSet("claude", "codex", "copilot", "agents", "all")]
  [string]$Agent = "claude",
  [string]$Dest = "",
  [switch]$Link
)
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$skills = @("product-planning", "system-design", "web-app-development", "cross-platform-mobile", "website-building", "frontend-excellence", "security-review", "quality-assurance", "devops-delivery", "observability-scale")
$fixtured = @("web-app-development", "cross-platform-mobile", "website-building", "security-review", "devops-delivery", "quality-assurance", "frontend-excellence")

function Get-DefaultDest($a) {
  switch ($a) {
    "claude"  { Join-Path $HOME ".claude\skills" }
    "codex"   { Join-Path $HOME ".agents\skills" }
    "copilot" { Join-Path $HOME ".copilot\skills" }
    "agents"  { Join-Path $HOME ".agents\skills" }
  }
}

function Install-To($dest) {
  foreach ($s in $skills) {
    $src = Join-Path $here "$s\$s"
    $dst = Join-Path $dest $s
    if (-not (Test-Path $src)) { throw "Missing source: $src" }
    if ($Link) {
      New-Item -ItemType Directory -Force -Path $dest | Out-Null
      try {
        if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
        New-Item -ItemType SymbolicLink -Path $dst -Target $src | Out-Null
      } catch {
        Write-Warning "Symlink failed (enable Developer Mode for symlinks); falling back to copy for $s."
        New-Item -ItemType Directory -Force -Path $dst | Out-Null
        Copy-Item -Recurse -Force (Join-Path $src "*") $dst
      }
    } else {
      if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
      New-Item -ItemType Directory -Force -Path $dst | Out-Null
      Copy-Item -Recurse -Force (Join-Path $src "*") $dst
    }
    if (-not (Test-Path (Join-Path $dst "SKILL.md"))) { throw "Verify failed: $dst\SKILL.md missing" }
    Write-Host "Installed $s -> $dst"
  }
}

if ($Agent -eq "all") {
  if ($Dest) { throw "--Dest needs a single -Agent (not all)." }
  foreach ($a in @("claude", "codex", "copilot")) {
    $d = Get-DefaultDest $a
    Write-Host "== $a ($d) =="
    Install-To $d
  }
} else {
  if (-not $Dest) { $Dest = Get-DefaultDest $Agent }
  Install-To $Dest
}
Write-Host 'Verify in Git Bash or WSL (skills with fixture suites):'
foreach ($s in $fixtured) { Write-Host "  bash <skills-dir>/$s/evals/check-fixtures.sh" }
Write-Host 'Note: *.sh scripts require Git Bash or WSL on Windows; cmd.exe is not supported.'
