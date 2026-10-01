#!/usr/bin/env bash
# Regression test for scripts/preflight.sh against the expo-old fixture.
HERE="$(cd "$(dirname "$0")" && pwd)"; PF="$HERE/../scripts/preflight.sh"
out=$(bash "$PF" "$HERE/files/expo-old" 2>&1); got=$(echo "$out" | grep -c '\[FAIL\]'); ok=1
[ "$got" -eq 4 ] || ok=0
for pat in 'FAIL.*expo .*below SDK 57' 'FAIL.*newArchEnabled' 'FAIL.*EXPO_PUBLIC' 'FAIL.*targetSdkVersion 35'; do echo "$out" | grep -qE "$pat" || ok=0; done
[ $ok -eq 1 ] && { echo "PASS  expo-old: 4 expected FAILs"; exit 0; } || { echo "FAIL  expo-old (FAIL lines: got $got, want 4)"; echo "$out"; exit 1; }
