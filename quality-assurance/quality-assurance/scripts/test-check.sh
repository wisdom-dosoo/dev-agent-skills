#!/usr/bin/env bash
# Deterministic test-presence check: fails repos with no tests, warns on gaps.
# Usage: scripts/test-check.sh [project-root]
# Exit code: 0 = no FAIL lines, 1 = at least one FAIL.

PASS=0; WARN=0; FAIL=0
ok()   { echo "  [ok]   $1"; PASS=$((PASS+1)); }
warn() { echo "  [warn] $1"; WARN=$((WARN+1)); }
bad()  { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }

ROOT="${1:-.}"
cd "$ROOT" || { echo "Cannot cd to $ROOT"; exit 2; }
echo "Test check in $(pwd)"

TESTS=$(find . -maxdepth 4 \( -path './node_modules' -o -path './.git' -o -path './.venv' -o -path './venv' -o -path './dist' -o -path './build' -o -path './.next' \) -prune -o -type f \( -name '*.test.*' -o -name '*.spec.*' -o -name '*_test.py' -o -name 'test_*.py' -o -name '*_test.go' -o -name '*Test.php' \) -print 2>/dev/null)
if [ -n "$TESTS" ]; then
  N=$(echo "$TESTS" | wc -l | tr -d ' ')
  ok "$N test file(s) present"
else
  bad "no test files found (*.test.*, *_test.py, ...); add tests before shipping"
fi

# ---- coverage config ------------------------------------------------------------
if ls codecov.yml .codecov.yml 2>/dev/null >/dev/null \
  || grep -RqsE 'coverage.*(threshold|fail-under|statements|lines)' vitest.config.* jest.config.* pyproject.toml setup.cfg .nycrc* package.json 2>/dev/null; then
  ok "coverage config present"
else warn "no coverage thresholds configured; add gates for new code"; fi

# ---- e2e for app-like projects ----------------------------------------------------
IS_APP=0
[ -f package.json ] && grep -qE '"(next|react|expo|react-native)"' package.json 2>/dev/null && IS_APP=1
[ -f pubspec.yaml ] && IS_APP=1
if [ "$IS_APP" = 1 ]; then
  if [ -d e2e ] || [ -d tests/e2e ] || [ -d cypress ] || [ -d integration_test ] || ls playwright.config.* cypress.config.* 2>/dev/null >/dev/null; then
    ok "e2e setup present"
  else warn "app project without e2e (Playwright/Cypress/integration_test); add the golden path"; fi
fi

# ---- CI runs the tests --------------------------------------------------------------
if [ -d .github/workflows ] && grep -RqsE 'npm test|pytest|flutter test|go test|vitest' .github/workflows 2>/dev/null; then
  ok "CI runs tests"
elif [ -d .github/workflows ]; then warn "CI workflows exist but none run tests; add the suite as a required check"
else warn "no CI workflows; tests do not block merges"; fi

echo; echo "Summary: $PASS ok, $WARN warn, $FAIL FAIL"
[ "$FAIL" -eq 0 ]
