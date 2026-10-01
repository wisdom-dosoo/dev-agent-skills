# Data modeling

> Scope note: this file *is* the database-design skill, folded in per `CONTRIBUTING.md` Decision 1 (no divergent trigger proven, ~60 lines, slow rot). It graduates to its own skill only when prompts need deep per-engine tuning without architecture advice — until then, expand this file, don't split it.

## Database rule of thumb

- Relational data, transactions across entities, reporting, or unknown future queries: **Postgres**. Default when unsure.
- Self-contained documents read whole, flexible schema, or vector search as a hard requirement: **MongoDB**.
- Money, inventory, reservations, anything where double-spend is catastrophic: Postgres with real transactions. No exceptions for fashion.

## Relational modeling

- Model the domain, not the screens: entities and their invariants first; view-specific shapes are queries/views, not tables.
- Every foreign key gets an index; every frequent filter/sort gets a composite index designed from the actual query (`WHERE` equality first, then range, then `ORDER BY`). Verify with `EXPLAIN ANALYZE`, not intuition.
- Constraints in the database (unique, check, not-null, foreign keys), not just in app code. The DB is the last validator and it never skips validation.
- Schema changes only through migrations, reviewed as code. Autogenerate-then-read: the generator misses renames and some constraint changes.

## Document modeling

- Embed what is read together; reference what is written independently or shared. Comments on a post: embed. Users across posts: reference.
- Never build a filter from raw request data (see web-app-development `mern.md`): parse with a schema, query explicit fields, enable `sanitizeFilter` as defense in depth.
- Transactions only on a replica set; design to avoid multi-document transactions where possible (they are a smell that the boundary is wrong).

## Index design recipe (the 80% case)

1. Take the slow query's `EXPLAIN ANALYZE`: sequential scan, sort spill, or nested loop over thousands of rows is the signal.
2. Build one composite index per hot query: equality columns first (in selectivity order), then a single range column, then `ORDER BY` columns. One range column per index — a second range column is decoration.
3. Cover the query (`INCLUDE` the selected columns) when the table is wide and the query is hot; otherwise keep indexes narrow — every index taxes every write.
4. Verify: re-run `EXPLAIN ANALYZE` (index scan + ms down 10–100×), then check `pg_stat_user_indexes` after a week — zero-scan indexes get dropped.
5. MongoDB equivalent: same column order (equality → sort → range), compound before single-field, `explain('executionStats')` to confirm, Atlas Performance Advisor as the second opinion.

## Analytical / reporting needs

- Operational queries and reporting queries diverge. Plan the split early: read replica first, materialized views second, separate warehouse third. Do not let ad-hoc reporting queries run against the primary.

## Migration and growth

- One entity, one owner (matches the architecture rule: no shared databases across services).
- Backfill in batches with progress logging and idempotency; large migrations run online (expand → migrate → contract), never lock-the-world rewrites on a live table.
