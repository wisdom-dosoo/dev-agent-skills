#!/usr/bin/env bash
# Regression test for scripts/secrets-scan.sh against the leaky-app fixture.
HERE="$(cd "$(dirname "$0")" && pwd)"; PF="$HERE/../scripts/secrets-scan.sh"
out=$(bash "$PF" "$HERE/files/leaky-app" 2>&1); got=$(echo "$out" | grep -c '\[FAIL\]'); ok=1
[ "$got" -eq 3 ] || ok=0
for pat in 'FAIL.*client-bundled' 'FAIL.*private key' 'FAIL.*cloud/provider'; do echo "$out" | grep -qE "$pat" || ok=0; done
[ $ok -eq 1 ] && { echo "PASS  leaky-app: 3 expected FAILs"; exit 0; } || { echo "FAIL  leaky-app (FAIL lines: got $got, want 3)"; echo "$out"; exit 1; }
