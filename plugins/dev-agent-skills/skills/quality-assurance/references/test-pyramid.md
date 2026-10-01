# Test pyramid (per stack)

Effort split: ~70% unit, ~20% integration, ~10% E2E. Invert this and you get a slow, flaky suite that still misses logic bugs.

## Unit (fast, many)

- **JS/TS:** Vitest (Vite projects) or Jest. Pure functions, validators (zod schemas!), state machines, pricing math. Mock the boundary (fetch, timers), never your own modules.
- **Python:** pytest. Services, serializers, business rules. `responses`/`respx` for HTTP boundaries; real objects elsewhere.
- **Flutter:** `flutter test`. Widgets with `testWidgets` for critical screens, pure unit for logic.
- Rule: if it has an `if`, it has a unit test. Table-driven cases for validators and pricing.

## Integration (medium speed, fewer)

- **API + DB:** spin a real test database (Postgres service in CI, Mongo memory server or test Atlas project). One session/transaction per test, rolled back. Never the dev database, never shared state between tests.
- **Contract:** generate the TS client from OpenAPI in CI — backend changes break the frontend build instead of production.
- **Auth in tests:** dependency overrides / test tokens, with at least one test proving an unauthorized request fails (that test belongs to you and to `security-review`).

## E2E (slow, critical paths only)

- **Web:** Playwright. Signup → core transaction → outcome. Seed via API, assert via UI, one browser project for speed (add matrix only when platform bugs justify it).
- **Mobile:** E2E on release builds for the golden path; simulators for the rest. Real-device check before store submission (see `cross-platform-mobile` release checklist).
- Budget: whole E2E suite under 10 minutes or it stops running. Parallelize by file, then cut scope — never increase timeouts as a fix.

## Coverage policy

- Gate on *diff* coverage (new code ≥ 80%) plus a ratcheting total floor. A flat 80%-of-everything rule incentivizes testing getters.
- The coverage number ships with the uncovered-critical-paths list. Untested payment code at 85% total is a FAIL in review even when the gate passes.
- Mutation spot-checks (Stryker/pitest/cosmic-ray) quarterly on the riskiest module — not in CI, as a health check.

## Flaky triage

1. Quarantine immediately (suite stays green and trusted) with a tracking issue.
2. Fix in this order: shared state → time dependence (freeze the clock) → async waits (assert on conditions, never `sleep`) → external services (record/replay or test doubles at the boundary).
3. Fixed within one Sprint or deleted. A test that cannot be made deterministic is not testing anything.
