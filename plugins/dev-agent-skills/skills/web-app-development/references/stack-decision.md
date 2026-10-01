# Choosing a web stack

Ask at most two questions (data shape, team language), then recommend one option. These are opinionated defaults, not facts; the repo's existing choices always win.

## Decision table
| Signal | Choose |
|---|---|
| Team is JS/TS only; data is nested documents; a mobile app (Expo) will share the API | **MERN**: React (Vite) + Express 5 + Mongoose + MongoDB |
| Public pages need SEO and the app lives in the same codebase | **Next.js** (App Router) + Postgres |
| Content/business app: users, permissions, admin UI, forms, reporting | **Django** + Postgres |
| API-first product, async I/O, websockets, or Python ML/LLM code sits next to the API | **FastAPI** + SQLAlchemy 2 + Alembic + Postgres, with a React/Next frontend |
| Small internal tool, few endpoints | Flask or FastAPI, single service |

## Database rule of thumb
- Relational data, transactions across entities, reporting, or unknown future queries: **Postgres**. This is the default when unsure.
- Self-contained documents read whole, flexible schema, or Atlas Vector Search is a hard requirement: **MongoDB**.
- "MERN because it's popular" is not a reason. Money, inventory, or many-to-many relationships push toward Postgres even in a JS shop (Express + Drizzle/Prisma + Postgres is a valid "PERN").

## Language-mix patterns
- **JS everywhere:** monorepo (`apps/web`, `apps/api`, `packages/shared`), shared zod schemas, one lockfile.
- **Python API + JS frontend:** two deployables, OpenAPI as the contract, generate the TS client from the schema instead of hand-writing types.
- **Python for AI next to a JS app:** keep the model code in a small FastAPI service; do not rewrite the main app.

## Node framework alternatives to Express
Fastify (schema-first, fast), Hono (tiny, edge-friendly), NestJS (structured, large teams). Recommend one only with a concrete reason; Express 5 remains fine.

## Anti-recommendations
- Do not start a new project on Express 4, Mongoose <9, Django <5.2, or Node <24.
- Do not adopt PostgreSQL 19 or an unconfirmed MongoDB 9.0 in production before GA is verified.
- Do not put business logic in Next.js Server Actions if a mobile client will need the same logic; put it behind an API.
- Do not use Django for a service whose whole job is a thin async proxy, or FastAPI for a CRUD admin-heavy app.
