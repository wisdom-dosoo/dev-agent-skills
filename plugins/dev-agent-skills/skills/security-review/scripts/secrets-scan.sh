#!/usr/bin/env bash
# Deterministic secrets scan: client-bundled secrets, key material, cloud tokens.
# Usage: scripts/secrets-scan.sh [project-root]
# Exit code: 0 = no FAIL lines, 1 = at least one FAIL.
# Heuristic only: every FAIL needs a human to read the file before reporting.

PASS=0; WARN=0; FAIL=0
ok()   { echo "  [ok]   $1"; PASS=$((PASS+1)); }
warn() { echo "  [warn] $1"; WARN=$((WARN+1)); }
bad()  { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }

ROOT="${1:-.}"
cd "$ROOT" || { echo "Cannot cd to $ROOT"; exit 2; }
echo "Secrets scan in $(pwd)"

EXCL="--exclude-dir=node_modules --exclude-dir=.venv --exclude-dir=venv --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist"

# ---- browser / mobile-bundled secret names (ship to the client) --------------
if grep -RIlsE '(VITE_|NEXT_PUBLIC_|REACT_APP_|EXPO_PUBLIC_)[A-Z0-9_]*(SECRET|PRIVATE|PASSWORD|TOKEN|SERVICE_ROLE|API_KEY|STRIPE_SECRET)' --include='.env*' --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='eas.json' . 2>/dev/null | grep -v node_modules | grep -q .; then
  bad "client-bundled variable name suggests a secret (VITE_/NEXT_PUBLIC_/REACT_APP_/EXPO_PUBLIC_*SECRET/...); these ship to users"
else ok "no secret-looking client-bundled variables"; fi

# ---- private key material -----------------------------------------------------
if grep -RIslE $EXCL --include='*' -e '-----BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY-----' . 2>/dev/null | grep -q .; then
  bad "private key material in the repo; move to a secret manager and rotate"
elif ls *.pem keys/*.pem .ssh/id_rsa 2>/dev/null | grep -q .; then
  bad "private key file (*.pem/id_rsa) in the repo; move to a secret manager and rotate"
else ok "no private key material"; fi

# ---- cloud / provider tokens hard-coded ---------------------------------------
if grep -RInsE $EXCL --include='*' -e 'AKIA[0-9A-Z]{16}' -e 'sk_live_[0-9a-zA-Z]+' -e 'ghp_[0-9a-zA-Z]{20,}' -e 'xox[bap]-[0-9a-zA-Z-]+' -e '-----BEGIN .*PRIVATE KEY-----' . 2>/dev/null | grep -q .; then
  bad "hard-coded cloud/provider credential (AWS key, sk_live_, GitHub/Slack token); revoke and move to env/secret manager"
else ok "no hard-coded cloud credentials"; fi

# ---- git hygiene ----------------------------------------------------------------
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git ls-files --error-unmatch .env >/dev/null 2>&1; then bad ".env is tracked by git; remove it from history and rotate its secrets"
  else ok ".env not tracked"; fi
else warn "not a git repository"; fi
if [ -f .gitignore ] && grep -qE '^\.env' .gitignore; then ok ".gitignore covers .env"; else warn ".gitignore does not list .env"; fi

echo; echo "Summary: $PASS ok, $WARN warn, $FAIL FAIL"
[ "$FAIL" -eq 0 ]
