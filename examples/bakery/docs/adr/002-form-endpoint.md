# ADR-002: Form endpoint service instead of mailto

- Status: accepted
- Date: 2026-10-01
- Deciders: Demo

## Context

The PRD's counter-metric is zero lost orders. A `mailto:` link drops the order into the customer's mail client — unsent drafts, wrong inboxes, no tracking.

## Decision

The order form POSTs to a form-endpoint service with spam protection and a success page. `mailto:` remains as a fallback contact link only.

## Alternatives considered

1. **mailto-only** — rejected because lost orders are invisible (violates the counter-metric).
2. **Hand-rolled backend** — rejected because a subscriber database for one form is a second product.

## Consequences

- Good: every submit tracked; spam filtered before it reaches the shop.
- Bad: third-party dependency for the single dynamic function.
- Follow-ups: replace the placeholder endpoint with the shop's real inbox before launch (TODO, owner: shop).
