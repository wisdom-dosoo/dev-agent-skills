#!/usr/bin/env bash
# Demo 1/3: secrets-scan catches a live key, a browser-bundled secret, and a key file.
# Expect exit 1 — a caught problem is the point. Not for CI (see check-fixtures.sh).
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo '$ secrets-scan.sh security-review/.../evals/files/leaky-app'
bash "$ROOT/security-review/security-review/scripts/secrets-scan.sh" "$ROOT/security-review/security-review/evals/files/leaky-app"
echo '--- takeaway: 3 FAILs, each naming the file, the fix, and the rotation rule.'
