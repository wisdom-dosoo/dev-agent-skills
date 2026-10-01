# Django playbook

Versions: `current-state.md` (Django 6.1.x on Python 3.12 to 3.14; 5.2 is the LTS line; 6.0 is security-only until April 2027).

## New project
```bash
uv init mysite && cd mysite
uv add "django>=6.1,<6.2" psycopg[binary] gunicorn
uv run django-admin startproject config .
uv run python manage.py startapp core
```
Use Postgres from day one (`psycopg` 3). SQLite only for throwaway prototypes.

## Structure rules
- One Django project (`config/`), several small apps by domain. Business logic in `services.py`, not in views or model `save()` overrides.
- Custom user model **before the first migration** (`AUTH_USER_MODEL`), even if it only subclasses `AbstractUser`.
- API: Django REST Framework (mature) or Django Ninja (typed, Pydantic-style). Pick one per project.
- Frontend: server-rendered templates + HTMX for most CRUD apps; React only when the UI is truly app-like.

## Queries
- Fix N+1 with `select_related` (FK/one-to-one) and `prefetch_related` (reverse/M2M). Test with `assertNumQueries`.
- Django 6.1 adds model-field fetch modes to control how deferred fields load; read the 6.1 release notes before adopting.
- Index fields used in filters and ordering; add indexes via migrations, review generated SQL with `sqlmigrate`.

## Settings for production
- `DEBUG = False`, `ALLOWED_HOSTS` set, `SECRET_KEY` from env, `CSRF_TRUSTED_ORIGINS` for real origins.
- `SECURE_SSL_REDIRECT`, `SESSION_COOKIE_SECURE`, `CSRF_COOKIE_SECURE`, HSTS settings.
- Run `python manage.py check --deploy` and treat every warning as a task.
- Static files via WhiteNoise or a CDN; media on object storage.

## Upgrading
- Move one feature release at a time; run tests with `-W error::DeprecationWarning` on the current version first, fix warnings, then bump.
- Django 6.x needs Python 3.12+. Do not move to Python 3.15 until Django's release notes list it.
- Third-party packages lag a Django release: check each dependency's supported versions before bumping.

## Common failures
| Symptom | First check |
|---|---|
| `CSRF verification failed` behind a proxy | `CSRF_TRUSTED_ORIGINS`, `SECURE_PROXY_SSL_HEADER` |
| Migration conflicts on a team | Two branches created migrations from the same parent; `makemigrations --merge` |
| Slow list pages | N+1; add `select_related`/`prefetch_related` |
| Works locally, 400 in prod | `ALLOWED_HOSTS` |
