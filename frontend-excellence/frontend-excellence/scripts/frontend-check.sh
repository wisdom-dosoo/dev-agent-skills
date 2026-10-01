#!/usr/bin/env bash
# Deterministic static hygiene check for web frontends (HTML/JSX).
# Usage: scripts/frontend-check.sh [project-root]
# Exit code: 0 = no FAIL lines, 1 = at least one FAIL.
# Catches the cheap, non-negotiable issues; the keyboard/reader pass stays manual.

PASS=0; WARN=0; FAIL=0
ok()   { echo "  [ok]   $1"; PASS=$((PASS+1)); }
warn() { echo "  [warn] $1"; WARN=$((WARN+1)); }
bad()  { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }

ROOT="${1:-.}"
cd "$ROOT" || { echo "Cannot cd to $ROOT"; exit 2; }
echo "Frontend check in $(pwd)"

FILES=$(find . -maxdepth 4 \( -path './node_modules' -o -path './.git' -o -path './.next' -o -path './dist' -o -path './build' \) -prune -o -type f \( -name '*.html' -o -name '*.jsx' -o -name '*.tsx' \) -print 2>/dev/null)
if [ -z "$FILES" ]; then
  warn "no HTML/JSX files found; nothing to check"; echo; echo "Summary: $PASS ok, $WARN warn, $FAIL FAIL"; exit 0
fi

# ---- images without alt (WCAG defect, trivially fixable) -------------------------
NOALT=$(echo "$FILES" | xargs grep -lE '<img' 2>/dev/null | while IFS= read -r f; do
  grep -E '<img' "$f" 2>/dev/null | grep -vE '\balt=' | head -3 | sed "s|^|$f:|"
done)
if [ -n "$NOALT" ]; then
  N=$(echo "$NOALT" | wc -l | tr -d ' ')
  bad "$N img tag(s) without alt text; add descriptive alt (empty only for decorative)"
  echo "$NOALT" | head -5 | while IFS= read -r line; do echo "    -> $line"; done
else ok "all img tags have alt text"; fi

# ---- document basics ---------------------------------------------------------------
if echo "$FILES" | xargs grep -lE '<html' 2>/dev/null | xargs grep -L 'lang=' 2>/dev/null | grep -q .; then
  warn "html element without lang attribute; screen readers need it"
else ok "html lang present (or no raw html files)"; fi
if echo "$FILES" | xargs grep -lE '<head' 2>/dev/null | xargs grep -L 'name="viewport"' 2>/dev/null | grep -q .; then
  warn "page without viewport meta; mobile layout will break"
else ok "viewport meta present (or no raw html files)"; fi
if echo "$FILES" | xargs grep -lE '<head' 2>/dev/null | xargs grep -L '<title>' 2>/dev/null | grep -q .; then
  warn "page without <title>; every page needs a unique title"
else ok "title present (or no raw html files)"; fi

# ---- click-only divs (keyboard defect) ------------------------------------------------
if echo "$FILES" | xargs grep -nE 'onClick' 2>/dev/null | grep -E '<div' | grep -qvE 'role=|tabIndex|onKey' ; then
  CLICKDIVS=$(echo "$FILES" | xargs grep -nE 'onClick' 2>/dev/null | grep -E '<div' | grep -vE 'role=|tabIndex|onKey' | head -3)
  if [ -n "$CLICKDIVS" ]; then warn "click-only div(s) without role/keyboard handling; use a button"; echo "$CLICKDIVS" | while IFS= read -r line; do echo "    -> $line"; done; fi
else ok "no bare click-only divs"; fi

echo; echo "Summary: $PASS ok, $WARN warn, $FAIL FAIL"
[ "$FAIL" -eq 0 ]
