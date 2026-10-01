# Next.js full-stack playbook

Versions and patch levels: `current-state.md` (16.3.x line; SECURITY section). **Before any Next.js work, confirm the current patched version from nextjs.org/blog; releases have been landing every week or two.**

## Setup
```bash
npx create-next-app@latest my-app --ts --app --eslint
```
Database: Postgres via Drizzle or Prisma (migrations mandatory). Auth: a maintained library (Auth.js, Better Auth, or a hosted provider), never hand-rolled sessions.

## Boundaries that prevent most bugs
- Server Components fetch data; Client Components (`'use client'`) hold interactivity. Keep the client boundary as low in the tree as possible.
- Server Actions and Route Handlers are public HTTP endpoints. Authenticate and authorize inside each one, and validate input with zod. Never assume the call came from your UI.
- Secrets only in server code. `NEXT_PUBLIC_*` is bundled to the browser.
- Data access lives in one server-only module (`import 'server-only'`) so it cannot be imported into client code by accident.

## Caching
Caching behavior changed across recent majors, so never rely on remembered defaults. Read the current caching docs for the installed version, then set caching explicitly per fetch/route, and test with a production build (`next build && next start`), not dev.

## Upgrading
```bash
npm install next@<patched-version> react@<current> react-dom@<current>
npx next build
```
Upgrade within the same minor first (patch bump), run the build and tests, then consider the next minor. Read the release notes of every skipped version.

## Security specifics
- `next/og` (`ImageResponse`) on the Node.js runtime was the source of a critical RCE in 16.2.0 to 16.3.5 (fixed 16.3.6). If you cannot patch immediately, the Edge implementation was reported as unaffected.
- Middleware is not a complete authorization layer: previous middleware-bypass advisories exist. Enforce auth again at the data-access layer.
- Image optimization and file-serving paths had critical fixes in Aug 2026; keep `images.remotePatterns` narrow.

## Deployment checklist
- [ ] `next build` passes with type-checking on; no `ignoreBuildErrors`.
- [ ] Environment variables set per environment; no secrets in `NEXT_PUBLIC_*`.
- [ ] Node runtime matches `.nvmrc` (24 today).
- [ ] Security release notes for the deployed line read within the last week.
