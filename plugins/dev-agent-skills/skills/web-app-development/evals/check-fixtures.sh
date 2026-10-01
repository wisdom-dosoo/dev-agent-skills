#!/usr/bin/env bash
# Regression test for scripts/preflight.sh: each fixture must produce its expected findings.
# Usage: evals/check-fixtures.sh      (exit 0 = all pass)
HERE="$(cd "$(dirname "$0")" && pwd)"; PF="$HERE/../scripts/preflight.sh"; F="$HERE/files"
pass=0; fail=0
check() { # name fixture expected-fail-count pattern...
  name=$1; dir=$2; want=$3; shift 3
  out=$(bash "$PF" "$F/$dir" 2>&1); got=$(echo "$out" | grep -c '\[FAIL\]')
  [ "$got" -eq "$want" ] && ok=1 || ok=0
  for pat in "$@"; do echo "$out" | grep -qE "$pat" || ok=0; done
  if [ $ok -eq 1 ]; then echo "PASS  $name"; pass=$((pass+1)); else echo "FAIL  $name (FAIL lines: got $got, want $want)"; fail=$((fail+1)); fi
}
check "next-old: RCE flagged"         next-old     1 'FAIL.*next 16\.3\.5'
check "mern-bad: multer/mongoose/mongo" mern-bad   3 'FAIL.*multer' 'FAIL.*mongoose' 'FAIL.*mongo:8\.2' 'warn.*postgres:19'
check "fastapi-bad: wildcard CORS"    fastapi-bad  1 'FAIL.*wildcard CORS' 'warn.*fastapi is not pinned'
check "django-py315: 3.15 pin warned" django-py315 0 'warn.*pins 3\.15'
echo; echo "$pass passed, $fail failed"; [ $fail -eq 0 ]
