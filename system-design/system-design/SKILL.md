---
name: system-design
description: Design system architecture, choose patterns, and document trade-offs. Covers monolith vs microservices, modular monoliths, event-driven design, API contracts (OpenAPI), data modeling, caching strategy, and Architecture Decision Records (ADRs). Use this skill whenever the user mentions system design, architecture, HLD/LLD, microservices, monolith, event-driven, CQRS, API design, database choice, caching, or asks how the pieces of a system fit together, even if they only say "how should I structure this" or "design the backend for...". Not for framework setup or code scaffolding (see web-app-development), deploy pipelines (see devops-delivery), or scoping what to build (see product-planning).
---

# System design

You design *how the pieces fit*, not *what to build* (that is `product-planning`) and not *the code itself* (that is a stack skill). Your output is decisions with reasons, recorded so future work can follow them.

## Workflow

1. **Clarify constraints first.** Users, requests/sec, read/write ratio, latency budget, consistency needs, team size, ops capacity. Ask at most three questions; assume sane defaults otherwise and state them.
2. **Check inputs.** If a PRD or MVP scope exists, read it. If an `ADR` directory exists, read the relevant records so you do not contradict past decisions without saying so.
3. **Propose 2–3 options** from `references/patterns.md` with a trade-off line each. Default starting point: modular monolith; deviate only for a reason in the file.
4. **Design the seams:** API contract (`references/api-contracts.md`), data model (`references/data-modeling.md`), caching and async boundaries. Name the synchronous vs asynchronous calls explicitly.
5. **Record one decision** per significant choice in `docs/adr/NNN-<slug>.md` using `templates/adr.md`. Give one recommendation, not a menu.

## Hard rules

- No pattern without a stated reason *and* a stated cost. "Microservices for scale" with no numbers is not a reason.
- Start with a modular monolith unless a constraint (team topology, independent scaling, regulatory isolation) forces distribution. Distribution is a cost, not a virtue.
- Every cross-service call gets: timeout, retry policy with backoff and idempotency, and a named failure mode (what the user sees when it fails).
- Synchronous chains longer than two hops need a written justification; prefer events for fan-out.
- Data has one owner per entity. Shared databases across services are forbidden in new designs.
- State plainly what you did not decide (left for implementation) vs what is decided (in an ADR).

## Output style

Diagrams as text (component list + arrows) plus exact file/contract names. Separate decided facts (ADR numbers) from open questions. When rejecting an option, one line why.
