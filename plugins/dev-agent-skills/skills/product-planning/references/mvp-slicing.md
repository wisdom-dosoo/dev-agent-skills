# MVP slicing

## The thin slice

An MVP is not "phase 1 of everything." It is the thinnest end-to-end path through real user value: a real user completes a real job with a real (possibly manual) backend. If no user can use it, it is not a slice — it is a layer.

Slicing technique: story-map the user journey left-to-right (discover → sign up → core action → outcome), then draw a horizontal line: everything above the line is the MVP, everything below is sequenced later. The line must cut *vertically* (a bit of frontend + backend + data per story), never horizontally (all of the database, then all of the API).

## MoSCoW (per release, not per project)

- **Must:** the release fails without it. If everything is Must, nothing is — force at most ~60% of effort into Must.
- **Should:** high value, release survives without it. First candidates for the next release.
- **Could:** nice-to-have. Do not schedule; pull only if Must/Should finish early.
- **Won't (this release):** explicitly deferred with a revisit trigger. This list is the most important part of the scope doc.

## What to fake, concierge, or defer

- Fake it: admin UIs (use DB console), dashboards (manual queries), notifications (manual sends) — until usage proves the need.
- Concierge it: human-behind-the-curtain for matching, moderation, onboarding — before automating.
- Defer it: multi-tenancy, permissions matrices, audit logs, i18n, native apps, SSO — until a paying user asks. Each deferral gets a revisit trigger ("when we sign a second clinic").

## Sequencing after the MVP

Order by risk × value: riskiest assumptions first (technical spikes and demand tests), then value delivery, then polish. Never sequence "infrastructure Sprint 0" longer than a week — build the slice on boring defaults and extract later.

## Anti-patterns

- "MVP" with 40 stories and no out-of-scope list. Send it back.
- Backend-only milestones with no demoable user effect. Every story ends with something a user can see.
- Scope decided by effort ("small, so include it") instead of value. Small-but-useless is still useless.
