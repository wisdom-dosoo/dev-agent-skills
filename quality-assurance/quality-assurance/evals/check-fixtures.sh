#!/usr/bin/env bash
# Regression test for scripts/test-check.sh: no-tests FAILs, tested passes.
HERE="$(cd "$(dirname "$0")" && pwd)"; PF="$HERE/../scripts/test-check.sh"; ok=1
out=$(bash "$PF" "$HERE/files/no-tests" 2>&1); got=$(echo "$out" | grep -c '\[FAIL\]')
[ "$got" -eq 1 ] || ok=0
echo "$out" | grep -qE 'FAIL.*no test files' || ok=0
echo "$out" | grep -qiE 'warn.*e2e' || ok=0
out2=$(bash "$PF" "$HERE/files/tested" 2>&1); got2=$(echo "$out2" | grep -c '\[FAIL\]')
[ "$got2" -eq 0 ] || ok=0
echo "$out2" | grep -qE '\[ok\].*test file' || ok=0
[ $ok -eq 1 ] && { echo "PASS  no-tests: 1 FAIL; tested: 0 FAILs"; exit 0; } || { echo "FAIL  fixtures"; echo "--- no-tests:"; echo "$out"; echo "--- tested:"; echo "$out2"; exit 1; }
