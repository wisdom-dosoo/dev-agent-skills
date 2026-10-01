#!/usr/bin/env bash
# Install skills into any coding agent's discovery path.
# Usage: ./install.sh [--agent NAME] [--dest DIR] [--link]
# Agents (default: claude):
#   claude   -> ~/.claude/skills     (Claude Code)
#   codex    -> ~/.agents/skills     (OpenAI Codex CLI/IDE/app)
#   copilot  -> ~/.copilot/skills    (VS Code / Copilot CLI; .agents also scanned)
#   agents   -> ~/.agents/skills     (open interop path from agentskills.io)
#   all      -> claude + codex + copilot destinations
# --dest DIR overrides the destination (single-agent installs only).
# --link symlinks instead of copying (drift-free; Codex follows symlinks).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SKILLS="product-planning system-design web-app-development cross-platform-mobile website-building frontend-excellence security-review quality-assurance devops-delivery observability-scale"
FIXTURED="web-app-development cross-platform-mobile website-building security-review devops-delivery quality-assurance frontend-excellence"

usage() {
  cat <<'EOF'
Install skills into any coding agent's discovery path.
Usage: ./install.sh [--agent NAME] [--dest DIR] [--link]
Agents (default: claude):
  claude   -> ~/.claude/skills     (Claude Code)
  codex    -> ~/.agents/skills     (OpenAI Codex CLI/IDE/app)
  copilot  -> ~/.copilot/skills    (VS Code / Copilot CLI; .agents also scanned)
  agents   -> ~/.agents/skills     (open interop path from agentskills.io)
  all      -> claude + codex + copilot destinations
--dest DIR overrides the destination (single-agent installs only).
--link symlinks instead of copying (drift-free; Codex follows symlinks).
EOF
  exit "${1:-0}"
}

AGENT="claude"; DEST=""; LINK=0
while [ $# -gt 0 ]; do
  case "$1" in
    --agent=*) AGENT="${1#*=}"; shift;;
    --agent) AGENT="${2:-}"; shift 2;;
    --dest=*) DEST="${1#*=}"; shift;;
    --dest) DEST="${2:-}"; shift 2;;
    --link) LINK=1; shift;;
    -h|--help) usage 0;;
    *) echo "Unknown option: $1"; usage 1;;
  esac
done

default_dest() {
  case "$1" in
    claude) echo "$HOME/.claude/skills";;
    codex|agents) echo "$HOME/.agents/skills";;
    copilot) echo "$HOME/.copilot/skills";;
    *) echo "Unknown agent: $1 (choose claude|codex|copilot|agents|all)"; exit 1;;
  esac
}

install_to() {
  dest="$1"
  for s in $SKILLS; do
    src="$HERE/$s/$s"
    [ -d "$src" ] || { echo "Missing source: $src"; exit 1; }
    if [ "$LINK" = 1 ]; then
      mkdir -p "$dest"
      rm -rf "$dest/$s"
      if ln -s "$src" "$dest/$s" 2>/dev/null && [ -L "$dest/$s" ]; then
        : # linked
      else
        echo "Warning: symlinks unavailable here; copying $s instead (re-run with --link where symlinks work to avoid drift)." >&2
        rm -rf "$dest/$s"
        mkdir -p "$dest/$s"
        cp -r "$src/." "$dest/$s/"
      fi
    else
      rm -rf "$dest/$s"
      mkdir -p "$dest/$s"
      cp -r "$src/." "$dest/$s/"
    fi
    echo "Installed $s -> $dest/$s"
  done
  for s in $SKILLS; do
    [ -f "$dest/$s/SKILL.md" ] || { echo "Verify failed: $dest/$s/SKILL.md missing"; exit 1; }
  done
}

if [ "$AGENT" = "all" ]; then
  [ -z "$DEST" ] || { echo "--dest needs a single --agent (not all)"; exit 1; }
  for a in claude codex copilot; do
    echo "== $a ($(default_dest "$a")) =="
    install_to "$(default_dest "$a")"
  done
else
  case "$AGENT" in
    claude|codex|copilot|agents) ;;
    *) echo "Unknown agent: $AGENT (choose claude|codex|copilot|agents|all)"; exit 1;;
  esac
  [ -n "$DEST" ] || DEST="$(default_dest "$AGENT")"
  install_to "$DEST"
fi
echo "Verify (skills with fixture suites, Git Bash/WSL on Windows):"
for s in $FIXTURED; do echo "  bash <skills-dir>/$s/evals/check-fixtures.sh"; done
