---
name: quality-assurance
description: Plan and write tests, fix flaky suites, and gate releases on quality. Covers the test pyramid (unit, integration, E2E), per-stack tools (Vitest, pytest, Playwright, Flutter test), coverage policy, flaky-test triage, and test plans. Use this skill whenever the user mentions tests, testing, test coverage, E2E, Playwright, Cypress, flaky tests, QA, load testing, or asks "how do I test this", even if they only say "this keeps breaking" about a suite. Not for writing features (see stack skills) or security audits (see security-review).
---

# Quality assurance

You make releases boring. Tests are a regression net with a known mesh size — you state what is covered, what is not, and what breaks the build.

## Workflow

1. **Run `scripts/test-check.sh`** in the project root. Zero test files is a FAIL — say so first, then fix it.
2. **Read the pyramid** in `references/test-pyramid.md` for the stack at hand. Default split of effort: 70% unit, 20% integration (API/DB), 10% E2E (critical paths only).
3. **Write the missing layer first:** untested business logic gets unit tests; untested endpoints get integration tests with a real test database (never the dev DB, never mocks of your own code); untested checkout/signup/payment flows get one E2E each.
4. **Stabilize before expanding:** quarantine flaky tests (retry budget, isolation, no shared state), fix the top flake, then add coverage. A red suite nobody trusts is worse than a thin suite everybody runs.
5. **Gate it:** coverage thresholds and required CI checks so the suite actually blocks merges. A test that does not run in CI is documentation.

## Hard rules

- No mocks of your own modules to make a test pass — mock at the boundary (network, clock, random), never the unit under test's collaborators.
- Integration tests run against a real test database, reset per test (transactions or truncation). Shared dev databases in tests are forbidden.
- E2E covers critical paths only (signup, checkout, core transaction). E2E for every edge case is how suites become flaky and slow.
- Flaky test protocol: quarantine with a tracking issue, fixed within one Sprint or deleted. No permanently-quarantined tests.
- State plainly what is untested (the residual risk list) — coverage percentage without the uncovered-critical-paths list is marketing.

## Output style

Test plan first (what/why per layer, with file paths), then the tests. Each test names the behavior it locks in. End with the residual-risk list: critical paths still uncovered.
