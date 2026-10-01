# Containers

## Dockerfile rules

- Pin the base image exactly (`node:24.11.0-slim`, never `node:latest` in production). Record the digest for prod if the registry supports it.
- Multi-stage builds: dependencies → build → minimal runtime. Dev tools and secrets never reach the final stage.
- `COPY`, not `ADD`. One `COPY` for manifests first (cache deps layer), then source. `.dockerignore` must exist and exclude `.git`, `node_modules`, `.env`, and local build output.
- Run as non-root (`USER node` / dedicated user). No `sudo`, no root-owned runtime files.
- `HEALTHCHECK` on every service image. If the platform provides health probes instead, wire them — "no probe" is not an option.
- `ENV` carries configuration, never secrets. Build-time secrets use mount/secret mechanisms, never `ENV` or layers (layers are forever).

## Compose rules (dev and small prod)

- Every image pinned (no `latest`). Every service has `restart:` policy and resource `limits` where supported.
- Secrets via env files listed in `.gitignore` or a secret manager — never literal values in `compose.yml`. If a literal secret ever touched the file, rotate it.
- Named volumes for data; throwaway containers get `profiles:` or separate override files, never commented-out services.
- One command to boot the whole dev stack (`docker compose up --build`), documented in the README.

## What the script enforces

`scripts/container-check.sh` FAILs on: secret-looking values in `ENV`/compose `environment`, `:latest` or unpinned images. It WARNs on: missing `HEALTHCHECK`, `ADD` usage, missing `USER`, missing `.dockerignore`, compose services without `restart:`. A clean scan is hygiene, not a full review — read the files for multi-stage leaks and migration strategy.
