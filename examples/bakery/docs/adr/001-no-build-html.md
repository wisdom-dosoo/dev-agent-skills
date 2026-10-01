# ADR-001: No-build HTML for the v1 site

- Status: accepted
- Date: 2026-10-01
- Deciders: Demo

## Context

Two content pages, zero interactivity beyond one form. No non-technical editors yet; the owner edits via PR review.

## Decision

Hand-written HTML + one CSS file, no framework, no build step. Deploy as static files.

## Alternatives considered

1. **Astro** — rejected because 2 pages don't repay a toolchain (revisit at 5+ pages or first interactive widget).
2. **Next.js** — rejected because there is no app here; a server runtime for static content is pure cost.

## Consequences

- Good: zero dependencies, instant loads, nothing to upgrade.
- Bad: repetition across pages is manual; layout drift possible.
- Follow-ups: revisit when page count exceeds 5 or interactivity appears.
