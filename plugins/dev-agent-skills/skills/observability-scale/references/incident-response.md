# Incident response

## During (first 30 minutes)

1. **Declare:** incident commander named, comms channel opened, status page updated. One commander; everyone else works the problem.
2. **Mitigate first, diagnose second:** roll back the last deploy (see `devops-delivery` rollback paths), shed load (disable the expensive feature flag), scale vertically if it buys time. A mitigated incident is a downgraded incident.
3. **Narrow with data:** error-rate spike at deploy time → bad release. Gradual saturation → capacity. Single-region → platform/dependency. Check the last change first — it is guilty until proven innocent.
4. **Communicate on a cadence:** users every 30 min (what is broken, workaround, next update time), internal every 15 min. Silence breeds duplicate work.

## After (within 48 hours)

Blameless postmortem using `templates/postmortem.md`. Rules:

- Timeline from logs, not memory. Every claim cites a timestamp.
- "Human error" is never the root cause — it is the starting point. The fix is the guardrail that makes the error impossible or harmless (require the check in CI, remove the footgun default, add the alert).
- Action items have owners and dates, reviewed at the next planning. Items without owners recur; that is the real postmortem finding.

## Readiness (before the next incident)

- Runbooks for the top 3 known failures (DB failover, provider outage, bad deploy) — one page each, tested in staging.
- Game-day the rollback path quarterly. An untested rollback is a rumor.
- On-call rotation with a primary and a shadow; alerts route to one place; alert fatigue is triaged (noisy alerts get fixed or deleted, never muted forever).
