# FastAPI playbook

Versions: `current-state.md`. FastAPI is 0.x with several releases a month: **pin an exact version** and upgrade deliberately (read release notes; deprecations do get removed).

## New project
```bash
uv init api && cd api
uv add "fastapi[standard]==<pinned>" "sqlalchemy>=2" alembic "psycopg[binary]" pydantic-settings
uv run fastapi dev app/main.py
```

## Structure
```
app/
  main.py          # app factory, middleware, routers
  api/             # routers by resource
  core/config.py   # pydantic-settings, reads env
  db/              # engine, session dependency
  models/          # SQLAlchemy models
  schemas/         # Pydantic request/response models
  services/        # business logic
alembic/           # migrations
```
- Separate DB models from API schemas. Never return an ORM model directly; return a response schema (`response_model`), which also prevents leaking fields like password hashes.
- One session per request via a dependency that commits/rolls back and always closes.
- Use `async def` only with async drivers/libraries. A blocking call inside `async def` stalls the whole event loop; use plain `def` (runs in a threadpool) or an async driver.

## Auth and security
- Auth as a dependency (`Depends(get_current_user)`) so it is impossible to forget on a route; group protected routes under one router with that dependency.
- Passwords: argon2id or bcrypt. Tokens: short-lived access + refresh; verify signature, `exp`, and audience.
- CORS: explicit origins. `allow_origins=["*"]` together with `allow_credentials=True` is invalid and dangerous.
- Rate limiting via a proxy/gateway or a maintained library; validate upload size at the proxy as well as in code.

## Migrations
`alembic revision --autogenerate -m "msg"`, then read the generated file; autogenerate misses renames and some constraint changes. Never call `create_all()` in production.

## Testing
`pytest` + `httpx.AsyncClient` (or `TestClient`), a separate test database, and dependency overrides for auth and the DB session.

## Frontend contract
Export the OpenAPI schema and generate the TypeScript client in CI (e.g. `openapi-typescript`) so backend changes break the frontend build instead of production.

## Common failures
| Symptom | First check |
|---|---|
| Whole API freezes under load | Blocking call inside `async def` |
| 422 on valid-looking requests | Schema mismatch; read the `detail` array locations |
| CORS errors only in browser | Origin list, or credentials with wildcard |
| Sessions leak connections | Session dependency not closing on exceptions |
