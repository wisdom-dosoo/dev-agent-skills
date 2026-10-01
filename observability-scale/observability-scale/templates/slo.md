# SLO: <service / critical path>

## Objectives

| SLI | Target | Window |
|---|---|---|
| Availability (successful responses / total) | 99.9% | 30-day rolling |
| Latency (p95 of <critical endpoint>) | < 300 ms | 30-day rolling |

## Error budget

- 0.1% of requests ≈ <N> failed/slow requests per month at current traffic.
- Policy: budget > 50% consumed → no risky releases without sign-off. Budget exhausted → feature freeze until recovered (reliability work only).

## Alerting (burn-rate based)

- Fast burn (2% budget in 1h): page immediately.
- Slow burn (100% budget in 3 days): ticket for next business day.
- No alerts on raw thresholds (CPU > 90%) without a user-facing SLI attached — pages must mean user pain.

## Exclusions

- <Planned maintenance windows, third-party outages beyond our boundary, beta endpoints> — listed here, nowhere else counts.
