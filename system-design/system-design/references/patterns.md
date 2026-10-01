# Architecture patterns

Opinionated defaults. The repo's existing choices always win; ADRs outrank this file.

## Default: modular monolith

One deployable, strict module boundaries (`billing/`, `scheduling/`, `users/`), each with its own services and schema namespace, talking through in-code interfaces — not HTTP. Split into services later *along these seams* when a forcing reason appears. Most products never outgrow this.

Move to distributed only on a concrete trigger:

| Signal | Points to |
|---|---|
| Team > ~15 engineers stepping on each other's deploys (Conway pressure) | Split the hottest seam into a service |
| One workload needs independent scaling (e.g. image processing vs CRUD) | Extract that worker + queue |
| Regulatory/data-residency isolation for a subset of data | Isolate that bounded context |
| "Might need scale one day" | Stay monolith. This is not a reason. |

## Event-driven (within or across services)

Use events for: fan-out notifications, audit trails, cross-context reactions ("order placed" → email + analytics + inventory). Rules:

- Events are facts about the past (`OrderPlaced`, never `SendEmail`). Consumers decide what to do.
- Schema-version every event from day one; consumers tolerate unknown fields and ignore unknown event types.
- At-least-once delivery + idempotent consumers. Exactly-once is a lie; design for duplicates.
- One broker per system (Postgres LISTEN/NOTIFY or a queue table for small scale; a managed broker only when throughput or routing demands it).

## CQRS / event sourcing

Only when the audit log *is* the product (ledgers, banking, compliance-heavy domains). Cost: replay logic, projection lag, unfamiliar debugging. For "read-heavy dashboard" problems, a read replica or materialized view solves it without CQRS.

## Caching strategy (in order of adoption)

1. HTTP/CDN caching for public reads.
2. Application cache (Redis) for hot, expensive, slowly-changing reads — every entry gets a TTL and an invalidation story.
3. Materialized views / read models for reporting queries.
4. Never cache inside request handlers without a TTL. "Cache until deploy" is a bug, not a policy.

## Anti-recommendations

- Do not start greenfield on microservices, Kubernetes, or event sourcing without a forcing reason above.
- Do not share a database between services; share versioned contracts instead.
- Do not put business logic in the API gateway; it routes and authenticates, nothing more.
- Do not design for 10x imagined scale; design seams so 10x is a migration, not a rewrite.
