# MERN playbook (TypeScript)

Versions: see `current-state.md` (Node 24 LTS, Express 5.x, Mongoose 9, MongoDB 8.3 or 8.0, React 19.x, Vite 8.x).

## Layout (npm workspaces or pnpm)
```
apps/
  web/        # React + Vite
  api/        # Express 5
packages/
  shared/     # zod schemas + inferred types used by both
```
Define each request/response shape once as a zod schema in `packages/shared`, infer the TS type, and use the same schema for API validation and form validation.

## Express 5 specifics
- Rejected promises from async handlers are forwarded to the error handler automatically. Delete old `try/catch -> next(err)` wrappers.
- Wildcards must be named: `app.get('/*splat', ...)` instead of `'*'`.
- `req.body` is `undefined` unless a body parser ran. Add `express.json({ limit: '100kb' })` explicitly.
- One central error middleware, last in the chain, returning a stable JSON shape. Never send stack traces in production.

## API skeleton concerns (in this order)
1. `helmet()`, `express.json({limit})`, CORS allowlist from env (never `*` with credentials).
2. Rate limiting on auth routes (`express-rate-limit`) and any expensive route.
3. Validate with zod middleware before the handler.
4. Auth middleware: verify session/JWT, attach `req.user`.
5. Handler -> service -> repository. Keep Mongoose calls out of route files.
6. Central error handler, request logging (see morgan note below).

## MongoDB / Mongoose rules
- Never build a filter from raw request data. Parse with zod first, then query with explicit fields:
  ```ts
  const { email } = LoginSchema.parse(req.body);   // string, not an object
  const user = await User.findOne({ email });
  ```
  A body like `{"email": {"$ne": null}}` becomes a match-anything filter if passed through untyped.
- Enable `sanitizeFilter` (Mongoose option) as defense in depth, but do not rely on it instead of validation.
- Index every field you filter or sort on; check with `.explain('executionStats')`. Add unique indexes in the schema, not in code checks.
- Use transactions only on a replica set (Atlas or a local replica set); a standalone `mongod` throws.
- `lean()` for read-only queries; skip document hydration.
- Do not reference `mongo:8.2` images (security support ended 2026-07-31). Pin `mongo:8.0` or `mongo:8.3`.

## Auth (default)
- Cookie session or short-lived access token + rotating refresh token in an httpOnly, Secure, SameSite cookie. Cookie-based auth needs CSRF protection (SameSite=Lax/Strict plus a token on unsafe methods).
- Passwords: argon2id (`argon2`) or bcrypt. Never log credentials or tokens.

## Uploads (multer)
- Multer has had multiple High-severity CVEs in 2026 (Feb, Jun, Aug). Require `>= 2.3.0` and re-check the Express blog.
- Always set `limits: { fileSize, files, fields }`. Verify type by content (magic bytes), not by the client's mimetype. Store in object storage (S3-compatible) with random keys, not on the app disk.
- morgan: `:remote-user` was log-injectable; require `>= 1.12.0` and avoid logging raw auth headers.

## React + Vite frontend
- `npm create vite@latest`, template `react-ts`. Data fetching via TanStack Query; forms via react-hook-form + the shared zod schema.
- React Compiler 1.0 is stable: enable via the Babel preset only if the team wants it, then remove manual `useMemo`/`useCallback` gradually. Do not mass-delete them in the same commit as the enablement.
- TypeScript 7: run `tsc` for checking; if typescript-eslint breaks, install the `@typescript/typescript6` side-by-side package and point the linter at it until TS 7.1 ships an API.
- Env: only `VITE_`-prefixed vars reach the browser, and they are public.

## Deployment checklist
- [ ] `NODE_ENV=production`, `trust proxy` set correctly behind a load balancer.
- [ ] Health endpoint, graceful shutdown on SIGTERM (close server, then `mongoose.disconnect()`).
- [ ] Atlas IP allowlist / private networking; separate DB users per environment; backups verified.
- [ ] `npm audit --omit=dev` clean or exceptions written down.

## Common failures
| Symptom | First check |
|---|---|
| `Cannot set headers after they are sent` | Handler both responded and called `next()`; Express 5 async forwarding hides double-handling |
| Route `'*'` now throws at startup | Express 5 path syntax: use a named wildcard |
| `req.body` undefined | Missing `express.json()` |
| Random `MongoServerSelectionError` | Atlas allowlist, DNS SRV blocked, or pool exhaustion in serverless |
| Transactions error on local dev | Standalone mongod; run a single-node replica set |
