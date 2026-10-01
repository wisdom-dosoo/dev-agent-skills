#!/usr/bin/env bash
# Install all skills into ~/.claude/skills/.
# Usage: ./install.sh [--dest DIR]   (default DIR is ~/.claude/skills)
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="${1:-}"
if [ "${1:-}" = "--dest" ]; then DEST="${2:-}"; fi
DEST="${DEST:-$HOME/.claude/skills}"
SKILLS="product-planning system-design web-app-development cross-platform-mobile frontend-excellence security-review quality-assurance devops-delivery observability-scale"
for s in $SKILLS; do
  mkdir -p "$DEST/$s"
  cp -r "$HERE/$s/$s/." "$DEST/$s/"
  echo "Installed $s -> $DEST/$s"
done
echo "Verify (skills with fixture suites):"
for s in web-app-development cross-platform-mobile security-review devops-delivery quality-assurance frontend-excellence; do
  echo "  bash $DEST/$s/evals/check-fixtures.sh"
done
