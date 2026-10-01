#!/usr/bin/env bash
# Deterministic preflight for MERN / Node APIs / Next.js / Django / FastAPI / Flask projects.
# Usage: scripts/preflight.sh [project-root]
#   RUN_AUDIT=1   also run npm audit / pip-audit (needs network)
# Exit code: 0 = no FAIL lines, 1 = at least one FAIL.
# Thresholds mirror references/current-state.md (snapshot 2026-09-30). Update both together.
# SECURITY thresholds go stale within days: confirm against the vendor advisory pages.
#
# What this script enforces (FAIL): vulnerable dep floors, EOL database images,
# wildcard CORS + credentials, tracked .env, hard-coded Django SECRET_KEY,
# browser-prefixed secret names (VITE_/NEXT_PUBLIC_/REACT_APP_).
# What it only warns on (heuristic, confirm by reading code): express.json()
# without limit, missing helmet/rate-limit, raw req.body in a MongoDB filter,
# password comparison without bcrypt/argon2 in the repo. A clean preflight is
# not a clean bill of health; the SKILL hard rules still apply.

NEXT16_MIN=16.3.6        # critical next/og RCE fixed here (affects >=16.2.0 <16.3.6)
NEXT16_LATEST=16.3.8     # scheduled 2026-09-30 release (9 vulns, 1 critical); VERIFY published
NEXT15_MIN=15.5.26
NEXT15_LATEST=15.5.27
MULTER_MIN=2.3.0; MORGAN_MIN=1.12.0; HBS_MIN=4.3.0; MULTIPARTY_MIN=4.3.0
NODE_OK_MAJOR=24         # Active LTS; 26 becomes LTS 2026-10-28

PASS=0; WARN=0; FAIL=0
ok()   { echo "  [ok]   $1"; PASS=$((PASS+1)); }
warn() { echo "  [warn] $1"; WARN=$((WARN+1)); }
bad()  { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }

ROOT="${1:-.}"
cd "$ROOT" || { echo "Cannot cd to $ROOT"; exit 2; }
echo "Preflight in $(pwd)"

EXCL="--exclude-dir=node_modules --exclude-dir=.venv --exclude-dir=venv --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist"

# ---- helpers (need node for semver-ish compare) ----------------------------
HAVE_NODE=0; command -v node >/dev/null 2>&1 && HAVE_NODE=1
vge() { node -e '
const p=s=>String(s).split("-")[0].split(".").map(x=>parseInt(x,10)||0);
const a=p(process.argv[1]),b=p(process.argv[2]);
for(let i=0;i<3;i++){if((a[i]||0)>(b[i]||0))process.exit(0);if((a[i]||0)<(b[i]||0))process.exit(1)}process.exit(0)' "$1" "$2"; }
depver() { node -e '
const fs=require("fs");const n=process.argv[1];
try{console.log(require(process.cwd()+"/node_modules/"+n+"/package.json").version);process.exit()}catch(e){}
try{const p=JSON.parse(fs.readFileSync("package.json"));const d={...p.dependencies,...p.devDependencies};if(d[n])console.log(String(d[n]).replace(/^[^0-9]*/,""))}catch(e){}
' "$1"; }
major() { echo "${1%%.*}"; }
hasdep() { [ -f package.json ] && grep -q "\"$1\"" package.json; }
pytext() { cat requirements*.txt pyproject.toml Pipfile 2>/dev/null; }
anyfile() { for f in "$@"; do [ -e "$f" ] && return 0; done; return 1; }

# ---- detect stacks ---------------------------------------------------------
NODE_APP=0; STACKS=""
if [ -f package.json ]; then
  NODE_APP=1
  hasdep next && STACKS="$STACKS nextjs"
  if hasdep express && { hasdep mongoose || hasdep mongodb; }; then STACKS="$STACKS mern"
  elif hasdep express; then STACKS="$STACKS express-api"; fi
  hasdep react && STACKS="$STACKS react"
fi
PY_APP=0
if [ -f manage.py ] && pytext | grep -qi django; then PY_APP=1; STACKS="$STACKS django"; fi
if pytext | grep -qi '^[[:space:]"]*fastapi'; then PY_APP=1; STACKS="$STACKS fastapi"; fi
if pytext | grep -qi '^[[:space:]"]*flask'; then PY_APP=1; STACKS="$STACKS flask"; fi
[ -z "$STACKS" ] && { bad "No Node, Next.js, Django, FastAPI, or Flask project detected"; echo; echo "Summary: $PASS ok, $WARN warn, $FAIL FAIL"; exit 1; }
echo "Stack:$STACKS"; echo

# ---- common ----------------------------------------------------------------
echo "Common"
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  [ -z "$(git status --porcelain)" ] && ok "git working tree clean" || warn "uncommitted changes; commit or stash before upgrading"
  if git ls-files --error-unmatch .env >/dev/null 2>&1; then bad ".env is tracked by git; remove it from history and rotate its secrets"
  else ok ".env not tracked"; fi
else warn "not a git repository"; fi
if [ -f .gitignore ] && grep -qE '^\.env' .gitignore; then ok ".gitignore covers .env"; else warn ".gitignore does not list .env"; fi
# Browser-exposed secret names ship to the client bundle. Name-based heuristic,
# same family as the mobile EXPO_PUBLIC_ check; confirm values by reading code.
if grep -RIlsE '(VITE_|NEXT_PUBLIC_|REACT_APP_)[A-Z0-9_]*(SECRET|PRIVATE|PASSWORD|TOKEN|SERVICE_ROLE|API_KEY|STRIPE_SECRET)' --include='.env*' --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' . 2>/dev/null | grep -v node_modules | grep -v '.next/' | grep -q .; then
  bad "browser-exposed variable name suggests a secret (VITE_/NEXT_PUBLIC_/REACT_APP_*SECRET/PRIVATE/PASSWORD/TOKEN); these ship to the browser"
else ok "no secret-looking browser-exposed variables"; fi

# ---- Node ------------------------------------------------------------------
if [ "$NODE_APP" = 1 ]; then
  echo; echo "Node"
  if [ "$HAVE_NODE" = 1 ]; then
    NV=$(node -v | tr -d v); NM=$(major "$NV")
    if   [ "$NM" -lt 22 ]; then bad "Node $NV is end-of-life or near it; use $NODE_OK_MAJOR (Active LTS)"
    elif [ "$NM" -eq 22 ]; then warn "Node $NV is Maintenance LTS; move to $NODE_OK_MAJOR"
    elif [ $((NM % 2)) -eq 1 ]; then warn "Node $NV is an odd-numbered non-LTS release; use an LTS line"
    elif [ "$NM" -ge 26 ]; then ok "Node $NV (26 is Current; becomes LTS 2026-10-28)"
    else ok "Node $NV"; fi
  else warn "node not found"; fi
  if anyfile package-lock.json yarn.lock pnpm-lock.yaml bun.lock bun.lockb; then ok "lockfile present"; else bad "no lockfile; installs are not reproducible"; fi
  if [ -f .nvmrc ] || grep -q '"engines"' package.json; then ok "Node version pinned (.nvmrc or engines)"; else warn "no .nvmrc or engines.node"; fi

  if [ "$HAVE_NODE" = 1 ]; then
    # Next.js
    NX=$(depver next)
    if [ -n "$NX" ]; then
      NXM=$(major "$NX")
      if [ "$NXM" = 16 ]; then
        if ! vge "$NX" "$NEXT16_MIN"; then bad "next $NX < $NEXT16_MIN: critical next/og RCE (GHSA-vcvr-r3jv-pc5j). Upgrade now"
        elif ! vge "$NX" "$NEXT16_LATEST"; then warn "next $NX: security release planned 2026-09-30 targets $NEXT16_LATEST. Confirm at nextjs.org/blog and upgrade"
        else ok "next $NX"; fi
      elif [ "$NXM" = 15 ]; then
        if ! vge "$NX" "$NEXT15_MIN"; then bad "next $NX < $NEXT15_MIN (15.x hardening + security fixes)"
        elif ! vge "$NX" "$NEXT15_LATEST"; then warn "next $NX: planned patched 15.x is $NEXT15_LATEST. Confirm at nextjs.org/blog"
        else ok "next $NX (Maintenance LTS line; plan a move to 16)"; fi
      else bad "next $NX is outside the supported lines (16 LTS, 15.5.x maintenance)"; fi
    fi
    # Express ecosystem
    EX=$(depver express)
    if [ -n "$EX" ]; then
      [ "$(major "$EX")" = 5 ] && ok "express $EX" || warn "express $EX: v4 still gets fixes, but new work should target v5"
      for pair in "multer:$MULTER_MIN:FAIL" "hbs:$HBS_MIN:FAIL" "multiparty:$MULTIPARTY_MIN:FAIL" "morgan:$MORGAN_MIN:WARN"; do
        P=${pair%%:*}; rest=${pair#*:}; MIN=${rest%%:*}; SEV=${rest##*:}
        V=$(depver "$P")
        if [ -n "$V" ]; then
          if vge "$V" "$MIN"; then ok "$P $V"
          elif [ "$SEV" = FAIL ]; then bad "$P $V < $MIN (High-severity CVEs fixed; see expressjs.com/en/blog)"
          else warn "$P $V < $MIN (security fix)"; fi
        fi
      done
      if grep -RIqsE $EXCL --include='*.js' --include='*.ts' -e 'express\.json\(\)' . 2>/dev/null; then warn "express.json() without a size limit; set { limit }"
      elif grep -RIqsE $EXCL --include='*.js' --include='*.ts' -e 'express\.json\(\{' . 2>/dev/null; then
        if ! grep -RIsE $EXCL --include='*.js' --include='*.ts' -e 'express\.json\([^)]*limit' . 2>/dev/null | grep -q .; then
          warn "express.json({...}) without a limit option; set { limit }"
        fi
      fi
      if ! grep -RIsqE $EXCL --include='*.js' --include='*.ts' -e 'helmet' . 2>/dev/null; then
        warn "no helmet middleware found; add it for security headers"
      fi
      if grep -RIl $EXCL --include='*.js' --include='*.ts' -e 'login' -e '/auth' . 2>/dev/null | grep -q .; then
        if ! grep -RIsqE $EXCL --include='*.js' --include='*.ts' -e 'express-rate-limit|rateLimit\(' . 2>/dev/null; then
          warn "auth/login routes present but no express-rate-limit found; add rate limiting"
        fi
      fi
      # NoSQL injection heuristic: raw req data straight into a MongoDB filter.
      # WARN only (needs code review to confirm); the mern-bad fixture triggers this.
      if grep -RInsE $EXCL --include='*.js' --include='*.ts' -e 'findOne\(\s*req\.(body|query|params)' -e '\.find\(\s*req\.(body|query|params)' -e 'findById\(\s*req\.body' . 2>/dev/null | grep -q .; then
        warn "possible NoSQL filter from raw req.body/query/params; validate with a schema and query explicit fields"
      fi
      if grep -RInsE $EXCL --include='*.js' --include='*.ts' -e '\$where' . 2>/dev/null | grep -q .; then
        warn '$where found in server code; avoid it (injection + performance risk)'
      fi
      # Plaintext password heuristic: ==/=== comparison mentioning password with
      # no bcrypt/argon2 anywhere in the repo.
      if grep -RInsE $EXCL --include='*.js' --include='*.ts' -e 'password[^;]*===|===[^;]*password' . 2>/dev/null | grep -q .; then
        if ! grep -RIsqE $EXCL --include='*.js' --include='*.ts' --include='*.json' -e 'bcrypt|argon2' . 2>/dev/null; then
          warn "password compared without bcrypt/argon2 in the repo; use argon2id or bcrypt"
        fi
      fi
    fi
    # Mongoose
    MG=$(depver mongoose)
    if [ -n "$MG" ]; then
      MGM=$(major "$MG")
      if   [ "$MGM" -lt 8 ]; then bad "mongoose $MG is unsupported; use 9.x"
      elif [ "$MGM" -eq 8 ]; then warn "mongoose $MG: 9 is the current major"
      else ok "mongoose $MG"; fi
    fi
    # TypeScript 7 + typescript-eslint
    TS=$(depver typescript)
    if [ -n "$TS" ]; then
      ok "typescript $TS"
      if [ "$(major "$TS")" -ge 7 ] && { hasdep typescript-eslint || hasdep '@typescript-eslint/parser'; }; then
        hasdep '@typescript/typescript6' || warn "typescript $TS has no compiler API until 7.1; typescript-eslint needs @typescript/typescript6 side-by-side"
      fi
    fi
    RV=$(depver react); [ -n "$RV" ] && ok "react $RV"
  fi
  if [ "${RUN_AUDIT:-0}" = 1 ]; then
    echo "  running npm audit (needs network)..."
    npm audit --omit=dev --audit-level=high >/dev/null 2>&1 && ok "npm audit: no High/Critical" || bad "npm audit reports High/Critical issues"
  else warn "skipped npm audit (RUN_AUDIT=1 to include)"; fi
fi

# ---- Python ----------------------------------------------------------------
if [ "$PY_APP" = 1 ]; then
  echo; echo "Python"
  PYV=""; command -v python3 >/dev/null 2>&1 && PYV=$(python3 -c 'import sys;print("%d.%d"%sys.version_info[:2])' 2>/dev/null)
  if [ -n "$PYV" ]; then
    PYMIN=${PYV#*.}
    if   [ "$PYMIN" -lt 12 ]; then bad "Python $PYV: Django 6.1 needs 3.12+; 3.14 is the stable line"
    elif [ "$PYMIN" -ge 15 ]; then warn "Python $PYV: Django 6.1 officially supports 3.12 to 3.14 only"
    else ok "Python $PYV"; fi
  else warn "python3 not found"; fi
  # the pinned version matters as much as the installed one
  case "$STACKS" in *django*)
    if [ -f .python-version ]; then
      PIN=$(head -1 .python-version | grep -oE '^[0-9]+\.[0-9]+')
      if [ -n "$PIN" ]; then
        PM=${PIN#*.}
        if   [ "$PM" -ge 15 ]; then warn ".python-version pins $PIN: Django 6.1 officially supports 3.12 to 3.14 only; pin 3.14"
        elif [ "$PM" -lt 12 ]; then bad ".python-version pins $PIN: below Django 6.1's minimum (3.12)"; fi
      fi
    fi
  ;; esac
  if [ -f .python-version ] || grep -qs 'requires-python' pyproject.toml; then ok "Python version pinned"; else warn "no .python-version or requires-python"; fi
  if anyfile uv.lock poetry.lock Pipfile.lock requirements.txt; then ok "dependency lock/pins present"; else warn "no lockfile or requirements pins"; fi

  case "$STACKS" in *django*)
    DJV=$(python3 -c 'import django;print(django.get_version())' 2>/dev/null)
    [ -z "$DJV" ] && [ -f uv.lock ] && DJV=$(awk '/^name = "django"$/{f=1;next} f&&/^version = /{gsub(/[^0-9.]/,"",$3);print $3;exit}' uv.lock)
    if [ -n "$DJV" ]; then
      if   vge "$DJV" 6.1; then ok "django $DJV"
      elif vge "$DJV" 6.0; then warn "django $DJV: 6.0 is security-only until April 2027; move to 6.1"
      elif vge "$DJV" 5.2; then ok "django $DJV (5.2 LTS line)"
      else bad "django $DJV is unsupported; upgrade to 5.2 LTS or 6.1"; fi
    else warn "could not determine Django version"; fi
    if grep -RInsE $EXCL --include='settings*.py' '^[[:space:]]*DEBUG[[:space:]]*=[[:space:]]*True' . | grep -q .; then warn "DEBUG = True literal in settings; drive it from env"; else ok "no hard-coded DEBUG = True"; fi
    if grep -RInsE $EXCL --include='settings*.py' "SECRET_KEY[[:space:]]*=[[:space:]]*['\"]" . | grep -q .; then bad "SECRET_KEY hard-coded in settings"; else ok "no hard-coded SECRET_KEY"; fi
    if [ "${RUN_AUDIT:-0}" = 1 ]; then python3 manage.py check --deploy >/dev/null 2>&1 && ok "manage.py check --deploy clean" || warn "manage.py check --deploy reports issues"; fi
  ;; esac

  case "$STACKS" in *fastapi*)
    if pytext | grep -qiE '^[[:space:]"]*fastapi(\[[a-z]+\])?[[:space:]]*(>=|~=|<|>|,|"$|$)'; then warn "fastapi is not pinned to an exact version (0.x, several releases/month)"; else ok "fastapi pinned"; fi
    for f in $(grep -RIl $EXCL --include='*.py' 'CORSMiddleware' . 2>/dev/null); do
      if grep -qE "allow_origins[[:space:]]*=[[:space:]]*\[[[:space:]]*[\"']\*[\"']" "$f" && grep -qE 'allow_credentials[[:space:]]*=[[:space:]]*True' "$f"; then
        bad "$f: wildcard CORS origin together with allow_credentials=True"; fi
    done
  ;; esac

  case "$STACKS" in *flask*)
    if grep -RInsE $EXCL --include='*.py' -e '^[[:space:]]*DEBUG[[:space:]]*=[[:space:]]*True' -e 'app\.debug[[:space:]]*=[[:space:]]*True' -e 'app\.run\([^)]*debug[[:space:]]*=[[:space:]]*True' . | grep -q .; then
      warn "Flask DEBUG enabled in code; drive it from env and keep it off in production"
    else ok "no hard-coded Flask DEBUG = True"; fi
    if grep -RInsE $EXCL --include='*.py' -e 'app\.secret_key[[:space:]]*=[[:space:]]*["'\'']' -e 'SECRET_KEY[[:space:]]*=[[:space:]]*["'\'']' . | grep -q .; then
      bad "Flask SECRET_KEY hard-coded; load it from env or a secret manager"
    else ok "no hard-coded Flask SECRET_KEY"; fi
  ;; esac
  if [ "${RUN_AUDIT:-0}" = 1 ] && command -v pip-audit >/dev/null 2>&1; then pip-audit >/dev/null 2>&1 && ok "pip-audit clean" || bad "pip-audit reports vulnerabilities"; fi
fi

# ---- containers / databases ------------------------------------------------
IMGS=$(cat docker-compose*.y*ml compose*.y*ml Dockerfile* 2>/dev/null | grep -oE '(image:[[:space:]]*|FROM[[:space:]]+)(mongo|postgres):[^[:space:]]+' | sed -E 's/.*(mongo|postgres):/\1:/')
if [ -n "$IMGS" ]; then
  echo; echo "Databases"
  for i in $IMGS; do
    name=${i%%:*}; tag=${i#*:}; tmaj=${tag%%[.-]*}
    case "$name" in
      mongo)
        case "$tag" in 8.2*) bad "mongo:$tag: 8.2 security support ended 2026-07-31; use 8.0 or 8.3";;
          latest) warn "mongo:latest is unpinned";;
          *) if [ "$tmaj" -lt 7 ] 2>/dev/null; then bad "mongo:$tag is end-of-life"; elif [ "$tmaj" -eq 7 ] 2>/dev/null; then warn "mongo:$tag: verify 7.0 end-of-life date"; else ok "mongo:$tag"; fi;; esac;;
      postgres)
        case "$tag" in latest) warn "postgres:latest is unpinned";;
          19*) warn "postgres:$tag: PostgreSQL 19 is beta until GA (RC early Oct 2026); not for production";;
          *) if [ "$tmaj" -lt 14 ] 2>/dev/null; then bad "postgres:$tag is end-of-life"; else ok "postgres:$tag"; fi;; esac;;
    esac
  done
fi

echo; echo "Summary: $PASS ok, $WARN warn, $FAIL FAIL"
[ "$FAIL" -eq 0 ]
