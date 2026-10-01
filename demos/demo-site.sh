#!/usr/bin/env bash
# Demo 2/3: site-check fails a launch-day landing page on broken links + SEO gaps.
# Expect exit 1 — a caught problem is the point. Not for CI (see check-fixtures.sh).
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo '$ site-check.sh website-building/.../evals/files/landing-bad'
bash "$ROOT/website-building/website-building/scripts/site-check.sh" "$ROOT/website-building/website-building/evals/files/landing-bad"
echo '--- takeaway: 1 FAIL (broken links) plus every missing SEO tag named with its fix.'
