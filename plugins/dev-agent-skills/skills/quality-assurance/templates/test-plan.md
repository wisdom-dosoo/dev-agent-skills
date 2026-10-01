# Test plan: <feature/release>

## Scope

- Under test: <endpoints, screens, jobs>
- Explicitly not tested (residual risk): <list with reason each>

## Layers

| Layer | Cases | Location | Tool |
|---|---|---|---|
| Unit | <e.g. pricing rules, zod schemas> | `__tests__/` | Vitest |
| Integration | <e.g. POST /orders with test DB> | `tests/api/` | Vitest + test DB |
| E2E | <e.g. signup → booking → confirmation> | `e2e/` | Playwright |

## Data & doubles

- Test database: <how provisioned, how reset per test>
- Boundaries mocked: <network, clock, random — nothing else>

## Gates

- [ ] New-code coverage ≥ 80%, total floor ≥ <N>% and ratcheting
- [ ] Suite runs in CI on every PR (required check)
- [ ] E2E suite under 10 minutes
- [ ] Zero quarantined tests older than one Sprint
