#!/usr/bin/env bash
# Demo 3/3: test-check refuses to bless an untested project, then passes a tested one.
# The first scan exits 1 by design. Not for CI (see check-fixtures.sh).
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo '$ test-check.sh quality-assurance/.../evals/files/no-tests'
bash "$ROOT/quality-assurance/quality-assurance/scripts/test-check.sh" "$ROOT/quality-assurance/quality-assurance/evals/files/no-tests" || true
echo
echo '$ test-check.sh quality-assurance/.../evals/files/tested'
bash "$ROOT/quality-assurance/quality-assurance/scripts/test-check.sh" "$ROOT/quality-assurance/quality-assurance/evals/files/tested" || true
echo '--- takeaway: zero test files is a FAIL that names the gate; the tested twin passes.'
