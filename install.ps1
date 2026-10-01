# Install all skills into %USERPROFILE%\.claude\skills\ (no admin needed).
# Usage: .\install.ps1 [-Dest "$HOME\.claude\skills"]
param([string]$Dest = (Join-Path $HOME ".claude\skills"))
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$skills = @("product-planning", "system-design", "web-app-development", "cross-platform-mobile", "frontend-excellence", "security-review", "quality-assurance", "devops-delivery", "observability-scale")
foreach ($s in $skills) {
  $src = Join-Path $here "$s\$s"
  $dst = Join-Path $Dest $s
  if (-not (Test-Path $src)) { throw "Missing source: $src" }
  New-Item -ItemType Directory -Force -Path $dst | Out-Null
  Copy-Item -Recurse -Force (Join-Path $src "*") $dst
  Write-Host "Installed $s -> $dst"
}
Write-Host 'Verify in Git Bash or WSL (skills with fixture suites):'
foreach ($s in @("web-app-development", "cross-platform-mobile", "security-review", "devops-delivery", "quality-assurance", "frontend-excellence")) {
  Write-Host "  bash ~/.claude/skills/$s/evals/check-fixtures.sh"
}
Write-Host 'Note: *.sh scripts require Git Bash or WSL on Windows; cmd.exe is not supported.'
