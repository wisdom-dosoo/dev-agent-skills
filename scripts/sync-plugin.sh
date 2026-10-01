#!/usr/bin/env bash
# Sync canonical skills into the Codex plugin package (or verify with --check).
# Canonical source: <skill>/<skill>/  (single source of truth)
# Package copy:     plugins/dev-agent-skills/skills/<skill>/
# Usage: scripts/sync-plugin.sh [--check]  (run from repo root)
# Exit code: 0 = synced/clean, 1 = drift found (--check) or error.
# The plugin dir is a build artifact: edit canonical skills, re-run sync,
# and CI (--check) fails on any drift between the two.

SYNC=1
[ "${1:-}" = "--check" ] && SYNC=0

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || { echo "Cannot cd to $ROOT"; exit 2; }
PKG="plugins/dev-agent-skills/skills"

PASS=0; FAILN=0
pass() { echo "PASS  $1"; PASS=$((PASS+1)); }
viol() { echo "FAIL  $1"; FAILN=$((FAILN+1)); }

for f in */*/SKILL.md; do
  skill=$(basename "$(dirname "$f")")
  src="$skill/$skill"
  dst="$PKG/$skill"
  if [ "$SYNC" = 1 ]; then
    rm -rf "$dst"
    mkdir -p "$dst"
    cp -r "$src/." "$dst/"
    echo "synced $skill"
  else
    [ -d "$dst" ] || { viol "$skill: missing from plugin package (run scripts/sync-plugin.sh)"; continue; }
    if diff -r -q "$src" "$dst" >/dev/null 2>&1; then pass "$skill in sync"
    else viol "$skill: drifted from canonical (run scripts/sync-plugin.sh)"; diff -r -q "$src" "$dst" | head -5; fi
  fi
done

if [ "$SYNC" = 0 ]; then
  [ -f plugins/dev-agent-skills/plugin.json ] || viol "plugins/dev-agent-skills/plugin.json missing"
  [ -f .agents/plugins/marketplace.json ] || viol ".agents/plugins/marketplace.json missing"
  echo; echo "$PASS in sync, $FAILN drifted"
  [ "$FAILN" -eq 0 ]
fi
