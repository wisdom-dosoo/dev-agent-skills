# Scaling ladders

Climb one rung at a time. Each rung lists its trigger (do this when…) and its proof (it worked when…).

## App tier

| Rung | Trigger | Proof |
|---|---|---|
| 1. Fix the query/code path | p95 dominated by one endpoint/query (`EXPLAIN ANALYZE`, profiler) | p95 down, same traffic |
| 2. Right-size the runtime | CPU throttled or event-loop lag; pool waits in logs | Saturation < 70% at peak, pool waits gone |
| 3. Horizontal replicas + LB | Single instance saturated after (1–2); stateless already | Linear headroom: 2× instances ≈ 2× throughput |
| 4. Cache hot reads (CDN → Redis) | Repeatable expensive reads, high cache-hit potential | Hit rate > 80%, origin p95 down; every entry has TTL + invalidation |

## Data tier (Postgres-first; Mongo notes inline)

| Rung | Trigger | Proof |
|---|---|---|
| 1. Index the actual queries | Sequential scans / sort spills in `EXPLAIN ANALYZE`; N+1 in traces | Query ms down 10–100× on the hot path |
| 2. Read replica | Read-heavy ratio (>4:1), primary CPU from SELECTs | Primary CPU down; replica lag < 1s (alert if not) |
| 3. Connection pooling (PgBouncer) | `too many clients` / connection churn in serverless | Connection count flat while throughput rises |
| 4. Partition/shard hot tables | Single table > 100M rows with time-range or tenant access patterns | Query prunes to one partition; maintenance windows sane |
| 5. Separate analytics | Reporting queries contend with OLTP on primary | Primary p95 unaffected during report runs |

MongoDB equivalents: compound indexes from the query shape (equality → sort → range), replica-set secondaries for reads (mind replication lag), sharding only on a high-cardinality shard key you have already validated.

## Async tier

Queues (BullMQ, Celery, platform queues) when: work is deferrable (emails, webhooks, thumbnails), bursty (10× spikes), or slow (third-party APIs). Every job is idempotent with retries + backoff + dead-letter queue. A queue without DLQ monitoring is a black hole with extra steps.

## What NOT to do

- Do not shard, microservice-split, or multi-region before rungs 1–3 are exhausted — with metrics proving it.
- Do not cache the unmeasured. Caching hides the bottleneck and adds invalidation bugs.
- Do not scale writes with replicas. Replicas scale reads; writes scale with smaller transactions, batching, and (last) partitioning.
