# Security baseline (all stacks)

Read this whenever a task touches auth, uploads, database queries, secrets, or deployment.

## Dependencies (the recurring risk in 2026)
- Frameworks and their middleware ship security fixes every few weeks. Subscribe to: nextjs.org/blog, expressjs.com/en/blog, djangoproject.com/weblog, GitHub advisories for your lockfile.
- Run `npm audit --omit=dev` / `pip-audit` in CI and fail the build on High or Critical.
- Pin exact versions in production lockfiles; upgrade on a schedule, plus immediately on Critical advisories.
- Prefer few dependencies. Every middleware package is attack surface (multer, morgan, hbs, multiparty all had CVEs in 2026).

## Authentication and sessions
- Use a maintained auth library or provider. No custom crypto.
- Password hashing: argon2id or bcrypt with sane cost. Enforce rate limiting and lockout/backoff on login.
- Session cookie flags: `HttpOnly; Secure; SameSite=Lax` (or Strict). Rotate session IDs on login.
- Authorization is checked on the server for every resource access ("can this user touch this record?"), not only at the route or middleware level.

## Input and output
- Validate at the boundary with a schema; reject unknown fields where practical.
- Database: parameterized queries / ORM only. For MongoDB, cast to expected primitive types before querying.
- Output: escape by default (React and Django templates do); never render user HTML without a sanitizer.

## Transport and headers
- HTTPS everywhere, HSTS. `helmet` (Express) or the equivalent Django settings. A Content-Security-Policy that at least blocks inline script from untrusted sources.
- CORS: explicit allowlist from config.

## Secrets
- Environment or a secret manager; `.env` in `.gitignore` and never committed. Rotate anything that ever touched git history.
- Browser-exposed prefixes (`NEXT_PUBLIC_`, `VITE_`, `REACT_APP_`) are public by definition.

## Uploads
Size and count limits, content-type verified by magic bytes, random storage keys, object storage, and no execution permissions on the upload location.

## Operations
- Structured logs without secrets or full auth headers. Error responses without stack traces.
- Backups tested by restoring. Separate credentials per environment.
- A written rollback path before every production deploy.
