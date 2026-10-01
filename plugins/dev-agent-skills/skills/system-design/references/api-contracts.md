# API contracts

The contract is the seam between teams, services, and the frontend. Design it before code; generate clients from it (never hand-write types twice).

## OpenAPI-first

- Write (or generate-then-freeze) the OpenAPI schema first. The frontend TS client is generated in CI (`openapi-typescript` or equivalent) so backend changes break the frontend build instead of production.
- Separate wire schemas from DB models everywhere (Pydantic response models, zod schemas, DRF serializers). Never serialize an ORM object directly — it leaks fields (password hashes, internal flags).

## Resource and versioning rules

- Resources are nouns, plural (`/orders/{id}/lines`). Actions that are not CRUD become sub-resources or explicit verbs (`/orders/{id}/cancel`), not RPC soup.
- Version with a path prefix (`/v1`) from day one, even with one client. Removing a field is a new version; adding an optional field is not.
- Pagination: cursor-based for feeds and large collections (stable under inserts); offset only for admin UIs. Every list endpoint gets `limit` with a server-side max.
- Errors: stable JSON shape (`{ error: { code, message, details } }`), `code` is machine-readable and documented; `message` is human-readable and never contains secrets or stack traces.

## Public-endpoint discipline

- Every endpoint (including webhooks, Server Actions, admin routes) authenticates and authorizes inside the handler. Gateway/middleware auth is defense-in-depth, not the check.
- Idempotency keys on every mutating endpoint clients may retry (payments, bookings, order placement).
- Rate limits per endpoint class (auth: strict; reads: generous; writes: moderate). Document the limits in the contract.

## Events as contracts

Event schemas follow the same rules: versioned, documented, additive-changes-only. A breaking event change is announced with producer + all consumers migrated in lockstep, or dual-published during transition.
