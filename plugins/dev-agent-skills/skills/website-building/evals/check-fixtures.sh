#!/usr/bin/env bash
# Regression test for scripts/site-check.sh against the landing-bad fixture.
HERE="$(cd "$(dirname "$0")" && pwd)"; PF="$HERE/../scripts/site-check.sh"
out=$(bash "$PF" "$HERE/files/landing-bad" 2>&1); got=$(echo "$out" | grep -c '\[FAIL\]'); ok=1
[ "$got" -eq 1 ] || ok=0
for pat in 'FAIL.*broken internal link' 'warn.*meta description' 'warn.*OG tags' 'warn.*canonical' 'warn.*one h1' 'warn.*sitemap' 'warn.*robots' 'warn.*without action'; do echo "$out" | grep -qiE "$pat" || ok=0; done
[ $ok -eq 1 ] && { echo "PASS  landing-bad: 1 expected FAIL"; exit 0; } || { echo "FAIL  landing-bad (FAIL lines: got $got, want 1)"; echo "$out"; exit 1; }
