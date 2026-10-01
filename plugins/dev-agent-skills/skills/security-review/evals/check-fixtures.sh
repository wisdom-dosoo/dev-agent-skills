#!/usr/bin/env bash
# Regression test for scripts/secrets-scan.sh against the leaky-app fixture.
# The tracked-.env FAIL is git-state dependent (fires once the fixture is
# committed), so the expected count is derived from the environment, not fixed.
HERE="$(cd "$(dirname "$0")" && pwd)"; PF="$HERE/../scripts/secrets-scan.sh"
out=$(bash "$PF" "$HERE/files/leaky-app" 2>&1); got=$(echo "$out" | grep -c '\[FAIL\]'); ok=1
want=3
if git -C "$HERE/files/leaky-app" ls-files --error-unmatch .env >/dev/null 2>&1; then want=4; fi
[ "$got" -eq "$want" ] || ok=0
for pat in 'FAIL.*client-bundled' 'FAIL.*private key' 'FAIL.*cloud/provider'; do echo "$out" | grep -qE "$pat" || ok=0; done
[ $ok -eq 1 ] && { echo "PASS  leaky-app: $want expected FAILs"; exit 0; } || { echo "FAIL  leaky-app (FAIL lines: got $got, want $want)"; echo "$out"; exit 1; }
