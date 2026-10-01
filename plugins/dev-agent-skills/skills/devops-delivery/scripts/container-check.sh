#!/usr/bin/env bash
# Deterministic container hygiene check for Dockerfiles and compose files.
# Usage: scripts/container-check.sh [project-root]
# Exit code: 0 = no FAIL lines, 1 = at least one FAIL.
# Heuristic only: a clean scan is hygiene, not a full review.

PASS=0; WARN=0; FAIL=0
ok()   { echo "  [ok]   $1"; PASS=$((PASS+1)); }
warn() { echo "  [warn] $1"; WARN=$((WARN+1)); }
bad()  { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }

ROOT="${1:-.}"
cd "$ROOT" || { echo "Cannot cd to $ROOT"; exit 2; }
echo "Container check in $(pwd)"

EXCL="--exclude-dir=node_modules --exclude-dir=.venv --exclude-dir=venv --exclude-dir=.git"
DOCKERFILES=$(find . -maxdepth 3 \( -path './node_modules' -o -path './.git' -o -path './.venv' -o -path './venv' \) -prune -o -name 'Dockerfile*' -print 2>/dev/null)
COMPOSE=$(ls docker-compose*.yml docker-compose*.yaml compose*.yml compose*.yaml 2>/dev/null)

if [ -z "$DOCKERFILES" ] && [ -z "$COMPOSE" ]; then
  warn "no Dockerfile or compose file found; nothing to check"; echo; echo "Summary: $PASS ok, $WARN warn, $FAIL FAIL"; exit 0
fi

# ---- secrets baked into images / compose --------------------------------------
# Matches ENV assignments and compose keys holding SECRET/PASSWORD/TOKEN with a
# literal value. Lines referencing $VAR or ${VAR} are excluded (proper wiring).
SECRETS=$(grep -RInsE $EXCL --include='Dockerfile*' --include='docker-compose*.y*ml' --include='compose*.y*ml' -e 'ENV[[:space:]]+[A-Z0-9_]*(SECRET|PASSWORD|TOKEN)' -e '(PASSWORD|SECRET)[[:space:]]*:[[:space:]]+[^$[:space:]]' . 2>/dev/null | grep -v '\$' | head -5)
if [ -n "$SECRETS" ]; then
  bad "literal secret in Dockerfile/compose; use gitignored env files or a secret manager"
  echo "$SECRETS" | while IFS= read -r line; do echo "    -> $line"; done
else ok "no literal secrets in Dockerfile/compose"; fi

# ---- unpinned images -----------------------------------------------------------
UNPINNED=""
for f in $DOCKERFILES $COMPOSE; do
  [ -f "$f" ] || continue
  if grep -Eq '(FROM|image:)[[:space:]]*[^[:space:]#]+:latest([^0-9a-zA-Z]|$)' "$f" 2>/dev/null; then UNPINNED="$UNPINNED $f:latest"; fi
  if grep -Eq '^[[:space:]]*FROM[[:space:]]+[^[:space:]:#]+([[:space:]]|$)' "$f" 2>/dev/null; then UNPINNED="$UNPINNED $f:untagged"; fi
  if grep -Eq '^[[:space:]]*image:[[:space:]]*[^[:space:]:#]+([[:space:]]|$)' "$f" 2>/dev/null; then UNPINNED="$UNPINNED $f:untagged"; fi
done
if [ -n "$UNPINNED" ]; then warn "unpinned images ($UNPINNED ); pin exact tags for reproducible deploys"
else ok "images pinned"; fi

# ---- Dockerfile hygiene ----------------------------------------------------------
for f in $DOCKERFILES; do
  [ -f "$f" ] || continue
  grep -qE '^[[:space:]]*HEALTHCHECK' "$f" || warn "$f: no HEALTHCHECK"
  grep -qE '^[[:space:]]*ADD[[:space:]]' "$f" && warn "$f: uses ADD; prefer COPY" || true
  grep -qE '^[[:space:]]*USER[[:space:]]' "$f" || warn "$f: no USER; image runs as root"
done
if [ -n "$DOCKERFILES" ]; then
  if [ -f .dockerignore ]; then ok ".dockerignore present"; else warn "no .dockerignore; build context likely ships secrets and bloat"; fi
fi

# ---- compose hygiene ---------------------------------------------------------------
for f in $COMPOSE; do
  [ -f "$f" ] || continue
  grep -qE 'restart:' "$f" || warn "$f: services without restart: policy"
done

echo; echo "Summary: $PASS ok, $WARN warn, $FAIL FAIL"
[ "$FAIL" -eq 0 ]
