# Postmortem: <incident title>

- Date: YYYY-MM-DD | Severity: S1–S4 | Commander: <name>
- Status: draft | actions tracked in <link>

## Summary

<2–3 sentences: what broke, user impact, duration.>

## Timeline (from logs, all times UTC)

- HH:MM — <event with log/metric link>
- HH:MM — <mitigation action>

## Root cause

<The system condition that allowed this. "Human error" is not accepted — name the missing guardrail.>

## What went well / poorly

- Well: <e.g. rollback path worked, alerts fired in 2 min>
- Poorly: <e.g. no runbook, status page lagged 40 min>

## Action items

| Action | Owner | Due | Status |
|---|---|---|---|
| <e.g. require smoke test in promote pipeline> | <name> | <date> | open |

Follow-up review date: <date>. Items without owners are not action items.
