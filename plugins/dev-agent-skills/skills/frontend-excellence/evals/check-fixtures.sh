#!/usr/bin/env bash
# Regression test for scripts/frontend-check.sh against the a11y-bad fixture.
HERE="$(cd "$(dirname "$0")" && pwd)"; PF="$HERE/../scripts/frontend-check.sh"
out=$(bash "$PF" "$HERE/files/a11y-bad" 2>&1); got=$(echo "$out" | grep -c '\[FAIL\]'); ok=1
[ "$got" -eq 1 ] || ok=0
for pat in 'FAIL.*without alt' 'warn.*lang' 'warn.*viewport' 'warn.*title' 'warn.*click-only'; do echo "$out" | grep -qiE "$pat" || ok=0; done
[ $ok -eq 1 ] && { echo "PASS  a11y-bad: 1 expected FAIL"; exit 0; } || { echo "FAIL  a11y-bad (FAIL lines: got $got, want 1)"; echo "$out"; exit 1; }
