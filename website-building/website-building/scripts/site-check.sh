#!/usr/bin/env bash
# Deterministic launch hygiene for static marketing sites: links, SEO tags,
# sitemap/robots, forms. Distinct from frontend-check.sh (which owns WCAG
# defects like alt text and keyboard handling).
# Usage: scripts/site-check.sh [project-root]
# Exit code: 0 = no FAIL lines, 1 = at least one FAIL.
# Rankings, card rendering, and crawler behavior stay manual: check pre-launch.

PASS=0; WARN=0; FAIL=0
ok()   { echo "  [ok]   $1"; PASS=$((PASS+1)); }
warn() { echo "  [warn] $1"; WARN=$((WARN+1)); }
bad()  { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }

ROOT="${1:-.}"
cd "$ROOT" || { echo "Cannot cd to $ROOT"; exit 2; }
echo "Site check in $(pwd)"

PAGES=$(find . -maxdepth 4 \( -path './node_modules' -o -path './.git' -o -path './dist' -o -path './build' -o -path './.astro' \) -prune -o -type f -name '*.html' -print 2>/dev/null)
if [ -z "$PAGES" ]; then
  warn "no HTML files found; nothing to check"; echo; echo "Summary: $PASS ok, $WARN warn, $FAIL FAIL"; exit 0
fi

# ---- broken internal links (must-fix: 404s on launch day) -------------------------
BROKEN=""
for page in $PAGES; do
  dir=$(dirname "$page")
  hrefs=$(grep -oE 'href="[^"]*"' "$page" 2>/dev/null | sed -e 's/^href="//' -e 's/"$//')
  for h in $hrefs; do
    case "$h" in http://*|https://*|mailto:*|tel:*|"#"*|//*|data:*) continue;; esac
    h=$(printf '%s' "$h" | sed -e 's/[?#].*//')
    [ -z "$h" ] && continue
    target=""
    case "$h" in
      /*) target=".$h";;
      *) target="$dir/$h";;
    esac
    case "$target" in
      */) [ -f "${target}index.html" ] || BROKEN="$BROKEN
    -> $page: $h";;
      *) if [ -f "$target" ]; then :;
         elif [ -f "$target.html" ]; then :;
         elif [ -f "$target/index.html" ]; then :;
         else BROKEN="$BROKEN
    -> $page: $h"; fi;;
    esac
  done
done
if [ -n "$BROKEN" ]; then
  bad "broken internal link(s); fix or remove before launch:$BROKEN"
else ok "no broken internal links"; fi

# ---- per-page SEO tags ---------------------------------------------------------------
NODESC=""; NOOG=""; NOCANON=""; NOH1=""
for page in $PAGES; do
  grep -qiE '<meta[^>]+name="description"' "$page" 2>/dev/null || NODESC="$NODESC $page"
  grep -qiE '<meta[^>]+property="og:title"' "$page" 2>/dev/null || NOOG="$NOOG $page(title)"
  grep -qiE '<meta[^>]+property="og:image"' "$page" 2>/dev/null || NOOG="$NOOG $page(image)"
  grep -qiE '<link[^>]+rel="canonical"' "$page" 2>/dev/null || NOCANON="$NOCANON $page"
  H1N=$(grep -oiE '<h1([[:space:]>])' "$page" 2>/dev/null | wc -l | tr -d ' ')
  [ "$H1N" = 1 ] || NOH1="$NOH1 $page($H1N)"
done
[ -z "$NODESC" ] && ok "meta descriptions present" || warn "page(s) without meta description:$NODESC"
[ -z "$NOOG" ] && ok "Open Graph tags present" || warn "page(s) missing OG tags:$NOOG"
[ -z "$NOCANON" ] && ok "canonical URLs present" || warn "page(s) without canonical:$NOCANON"
[ -z "$NOH1" ] && ok "one h1 per page" || warn "page(s) without exactly one h1:$NOH1"

# ---- site-level files ------------------------------------------------------------------
[ -f sitemap.xml ] && ok "sitemap.xml present" || warn "no sitemap.xml; crawlers discover pages slower"
[ -f robots.txt ] && ok "robots.txt present" || warn "no robots.txt; add one (and Disallow: / on staging)"

# ---- forms need an endpoint ---------------------------------------------------------------
NOFORM=$(echo "$PAGES" | xargs grep -lE '<form' 2>/dev/null | while IFS= read -r f; do
  grep -E '<form' "$f" 2>/dev/null | grep -vqE 'action=' && echo "$f"
done)
if [ -n "$NOFORM" ]; then warn "form(s) without action; ensure an endpoint + spam protection exists:$NOFORM"
else ok "forms have endpoints (or no forms)"; fi

echo; echo "Summary: $PASS ok, $WARN warn, $FAIL FAIL"
[ "$FAIL" -eq 0 ]
