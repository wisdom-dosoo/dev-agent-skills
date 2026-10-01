#!/usr/bin/env bash
# Regression test for scripts/container-check.sh against the docker-bad fixture.
HERE="$(cd "$(dirname "$0")" && pwd)"; PF="$HERE/../scripts/container-check.sh"
out=$(bash "$PF" "$HERE/files/docker-bad" 2>&1); got=$(echo "$out" | grep -c '\[FAIL\]'); ok=1
[ "$got" -eq 1 ] || ok=0
for pat in 'FAIL.*literal secret' 'warn.*unpinned images' 'warn.*no HEALTHCHECK' 'warn.*no USER' 'warn.*no .dockerignore' 'warn.*without restart'; do echo "$out" | grep -qiE "$pat" || ok=0; done
[ $ok -eq 1 ] && { echo "PASS  docker-bad: 1 expected FAIL"; exit 0; } || { echo "FAIL  docker-bad (FAIL lines: got $got, want 1)"; echo "$out"; exit 1; }
