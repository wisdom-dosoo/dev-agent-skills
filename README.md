# dev-agent-skills

Ten Claude agent skills covering the full software-engineering lifecycle — from "I have an idea" to production operations. Install them into Claude Code or claude.ai and they trigger automatically on the right prompts: planning scopes the work, design records the decisions, stack skills build it, gates audit it, DevOps ships it, observability keeps it alive.

| Layer | Skill | Field in one line |
|---|---|---|
| Plan | `product-planning` | MVP slicing, PRDs, user stories, estimation, roadmaps |
| Design | `system-design` | Architecture patterns, API contracts, data modeling, ADRs |
| Build | `web-app-development` | MERN, Next.js 16, Django 6.1, FastAPI 0.x, Flask, Postgres/MongoDB |
| Build | `cross-platform-mobile` | Expo SDK 57 + EAS (default), bare React Native, Flutter |
| Build | `website-building` | Marketing/landing/portfolio/blog sites, static-first, SEO |
| Build quality | `frontend-excellence` | Core Web Vitals, bundles, accessibility (WCAG), SEO |
| Gate | `security-review` | OWASP audits, secret scanning, threat modeling |
| Gate | `quality-assurance` | Test pyramid, E2E, flaky triage, coverage gates |
| Ship | `devops-delivery` | CI/CD, Docker, PaaS → K8s, environments, rollback |
| Operate | `observability-scale` | Perf diagnosis, scaling ladders, SLOs, incidents, postmortems |

Each skill is a folder: `SKILL.md` (trigger description + workflow + hard rules) + `references/` (playbooks) + `templates/` (ADRs, PRDs, SLOs…) + `scripts/` (deterministic audits, offline by default, where automatable) + `evals/` (8 graded prompts + broken fixtures + regression where fixtures apply).

---

## Requirements

- **Claude Code** (skills install to `~/.claude/skills/`) or **claude.ai** (upload/attach per chat, enable in Customize → Skills), or any API consumer of `/v1/skills`.
- **Bash** for the audit scripts: native on macOS/Linux; on Windows use **Git Bash** or **WSL2** (`cmd.exe` is not supported).
- **Web search on** wherever you use them — several skills are required to confirm versions/advisories against live sources, and that requirement cannot pass without it.
- Optional per skill: `node` (JS version checks), `python3` (Python checks, eval JSON validation), `flutter` (Flutter version floor), `docker` (only to *run* the containers you write, never needed by the checks).

---

## Install

### All nine skills (recommended)

```bash
# macOS / Linux / WSL / Git Bash — installs to ~/.claude/skills/
./install.sh

# Windows PowerShell — same destination, no admin needed
.\install.ps1

# Custom destination (CI, second account, testing)
./install.sh --dest /tmp/skills-test
```

### One skill only

```bash
cp -r product-planning/product-planning ~/.claude/skills/product-planning
# …same pattern: <skill>/<skill> → ~/.claude/skills/<skill>
```

### Uninstall / update

```bash
rm -rf ~/.claude/skills/<skill-name>   # uninstall one
./install.sh                            # re-run to update (overwrites)
```

### Verify the install

```bash
# Every skill with a deterministic script has a 10-second fixture suite:
for s in web-app-development cross-platform-mobile website-building security-review devops-delivery quality-assurance frontend-excellence; do
  bash ~/.claude/skills/$s/evals/check-fixtures.sh || exit 1
done
# expect: all PASS
#   web: 4 passed · mobile: 4 FAILs · website: 1 FAIL · security: 3 FAILs (+ tracked-.env once committed)
#   devops: 1 FAIL · qa: 1+0 FAILs · frontend: 1 FAIL
bash scripts/check-house-style.sh   # run from the repo: 25 portfolio checks
```

---

## How to use (per field)

Start a **fresh session** per task (a skill already read earlier in a chat skews triggering), `cd` into your project, and prompt naturally. Each skill runs its script first, reads its playbook, then does the work. Always state what was *not* verified.

### 1. `product-planning` — scope the work

**Use when you say:** "help me scope the MVP", "write a PRD", "what should we build first", "how long will this take", "prioritize this backlog", "I have an idea for an app".
**Not for:** code, architecture, or deploys.

```text
I want to build a booking app for dog groomers: appointments,
reminders, payments. Help me scope the MVP.
```

What happens: clarifies the user + one success metric (≤3 questions) → slices one thin end-to-end path → writes stories with acceptance criteria (`templates/story.md`) → estimates in ranges with spikes for unknowns → produces a PRD (`templates/prd.md`) with an explicit **Out of scope** list. Every proposal names what is deferred and its revisit trigger.
Key files: `references/mvp-slicing.md` (thin slices, MoSCoW, fake/concierge/defer), `references/estimation.md` (ranges not dates, spike policy).
No script — doc-driven by policy (`CONTRIBUTING.md`); quality gate is the 8-prompt evals at 80%.

### 2. `system-design` — decide how the pieces fit

**Use when you say:** "design the system for…", "microservices or monolith?", "Postgres or Mongo?", "design this API", "how should I structure the backend".
**Not for:** framework setup (web/mobile skills) or what-to-build scoping (planning).

```text
Design the backend for the groomer booking MVP: 5 engineers,
bookings + reminders + payments. Reads dominate 10:1.
```

What happens: clarifies constraints (scale, latency, consistency, team size) → proposes 2–3 options from `references/patterns.md` (default: modular monolith — distribution needs a forcing reason) → designs the seams: versioned OpenAPI contract (`references/api-contracts.md`), data model and index plan (`references/data-modeling.md`), sync-vs-async boundaries → records each decision as `docs/adr/NNN-<slug>.md` (`templates/adr.md`). Downstream skills read those ADRs instead of re-deciding.
Key rules: one data owner per entity (no shared databases), sync chains longer than two hops need written justification, events are past-tense facts with idempotent consumers.

### 3. `web-app-development` — build the web app / API

**Use when you say:** "set up a MERN app", "my Next.js app…", "Django or FastAPI?", "review this login route", "npm audit shows…", "upgrade Next.js", "build a REST API".
**Not for:** static landing pages or mobile apps.

```text
cd my-project
# in a fresh Claude session:
Audit this project before we ship it, then fix the FAILs.
```

What happens: detects the stack (`package.json`, `manage.py`, `pyproject.toml`) → reads `references/current-state.md` **and re-confirms patched versions live** (snapshot: 2026-09-30; Next.js ships security releases roughly weekly) → runs `scripts/preflight.sh` and fixes FAILs first → reads the playbook (`mern.md`, `nextjs.md`, `django.md`, `fastapi.md`) + `security-baseline.md` for auth/uploads/queries/secrets → smallest change → verifies (type-check, tests, production build, hits the changed endpoint).

```bash
bash ~/.claude/skills/web-app-development/scripts/preflight.sh [project-root]
RUN_AUDIT=1 bash .../preflight.sh   # adds npm audit / pip-audit (needs network)
```

**FAILs (fix before other work):** Next.js below the RCE floor (`next/og` GHSA-vcvr-r3jv-pc5j), multer/morgan/hbs/multiparty below CVE floors, Mongoose < 8, unsupported Django, `mongo:8.2` image (security support ended 2026-07-31), `postgres:19-beta` in prod, wildcard CORS + credentials, tracked `.env`, hard-coded `SECRET_KEY`, browser-secret names (`VITE_/NEXT_PUBLIC_/REACT_APP_`), missing lockfile.
**WARNs (confirm by reading code):** `express.json()` without `limit`, missing `helmet`/rate-limit, raw `req.body` in a Mongo filter, plaintext password compare, Flask `DEBUG` literals. A clean preflight is *not* a clean bill of health.

### 4. `cross-platform-mobile` — build the iOS/Android app

**Use when you say:** "build an app for iPhone and Android", "eas build fails…", "Expo or Flutter?", "raise target API level", "upgrade Expo SDK", "submit to TestFlight".
**Not for:** websites, backend-only work, fully native Swift/Kotlin apps.

```text
Upgrade this Expo app to the latest SDK.
```

What happens: detects Expo (`app.json` + `expo`) vs Flutter (`pubspec.yaml`) vs bare RN → reads `references/current-state.md` (snapshot: 2026-09-29; re-verify if >30 days old or if a store deadline drives the answer — SDK 58 may have landed) → runs `scripts/preflight.sh`, fixes FAILs → reads `references/expo.md` or `flutter.md` → upgrades one SDK at a time (`npx expo install --fix`, `npx expo-doctor`) → verifies both platforms → follows `references/release-checklist.md` when shipping.

```bash
bash ~/.claude/skills/cross-platform-mobile/scripts/preflight.sh [project-root]
RUN_DOCTOR=1 bash .../preflight.sh   # adds npx expo-doctor (needs network)
```

**FAILs:** Expo below SDK 57, `newArchEnabled` (Legacy Architecture is gone), secret-looking `EXPO_PUBLIC_` names (bundled into the app), `targetSdkVersion` < 36 (Play minimum since 2026-08-31), bare RN far behind current, Flutter < 3.44. **WARNs:** unpinned `targetSdkVersion` on a current SDK, missing `eas.json`, Intel Mac for Xcode 27 (Apple-silicon only), non-macOS iOS builds (EAS/CI only).
Default stack for greenfield with no preference: Expo + TypeScript + Expo Router + EAS (`references/stack-decision.md`).

### 5. `frontend-excellence` — make the web UI fast and accessible

**Use when you say:** "the page is slow/janky", "Lighthouse score", "Core Web Vitals", "bundle size", "accessibility/a11y", "keyboard navigation", "Google ranks us low".
**Not for:** backend logic or native mobile UI.

```text
Our landing page scores 55 on mobile Lighthouse with 4s LCP. Fix it.
```

What happens: runs `scripts/frontend-check.sh` (alt text, `lang`, viewport, title, click-only divs) → measures baseline (Lighthouse mobile throttled + bundle breakdown) → applies `references/performance.md` in budget order (images → JS weight → fonts → render path → caching; LCP/INP/CLS + byte budgets) → does the keyboard-and-screen-reader pass (`references/accessibility.md`, WCAG 2.2 AA) → locks budgets and `jsx-a11y` lint into CI. Numbers first: metric → cause → expected gain per change; ends with the residual list.

```bash
bash ~/.claude/skills/frontend-excellence/scripts/frontend-check.sh [project-root]
```

**FAILs:** `img` without `alt`. **WARNs:** missing `lang`/viewport/`title`, click-only `div`s. Automated checks catch ~30% — the manual keyboard pass is the skill.

### 6. `security-review` — audit before you ship

**Use when you say:** "audit this", "is this safe to ship", "review the login/payments", "threat-model…", "npm audit shows…", "where do I put this API key".
**Not for:** adding features or designing systems.

```text
Audit this app before we ship it. It handles logins and Stripe payments.
```

What happens: scopes to auth/payments/PII/uploads/input paths → runs `scripts/secrets-scan.sh`, confirms every FAIL by reading the file → threat-models lightly (`references/threat-modeling.md`: assets → attackers → entry points) → walks `references/owasp-checklist.md` (A01–A10, 2026-tuned) → reports findings ordered Critical → High → Medium → Low, each with file:line, one-line impact, exact fix, and how to verify. Ends with the top 3 actions if you do nothing else.

```bash
bash ~/.claude/skills/security-review/scripts/secrets-scan.sh [project-root]
```

**FAILs:** client-bundled secret names (`VITE_/NEXT_PUBLIC_/REACT_APP_/EXPO_PUBLIC_*SECRET…`), private-key material (headers or `*.pem`/`id_rsa`), hard-coded cloud tokens (`AKIA…`, `sk_live_`, `ghp_`, `xox…`), tracked `.env`. **Rule:** secrets in code, logs, URLs, or bundles are always findings; rotation is part of the fix once git history is touched.

### 7. `quality-assurance` — test it and gate it

**Use when you say:** "how do I test this", "write tests for…", "E2E with Playwright", "flaky tests", "coverage", "QA plan", "load test".
**Not for:** writing features or security audits.

```text
This project has no tests. Where do we start before shipping?
```

What happens: runs `scripts/test-check.sh` (zero test files is a FAIL — say so first) → applies `references/test-pyramid.md` for the stack (~70% unit / 20% integration on a real test DB / 10% E2E on critical paths only) → writes the missing layer first → quarantines flakes (shared state → clock → async waits → doubles; fixed in one Sprint or deleted) → gates coverage (diff ≥ 80% + ratcheting floor) and required CI checks. Ends with the residual-risk list: critical paths still uncovered.

```bash
bash ~/.claude/skills/quality-assurance/scripts/test-check.sh [project-root]
```

**FAILs:** no test files. **WARNs:** no coverage thresholds, app without E2E, CI not running tests. **Rules:** mock at the boundary (network/clock), never your own modules; never the dev database; E2E suite under 10 minutes or it stops running.

### 8. `devops-delivery` — ship reproducibly

**Use when you say:** "put this online", "set up CI/CD", "write a Dockerfile", "Kubernetes or…?", "staging vs production", "how do we roll back".
**Not for:** app code or architecture.

```text
Put this Node app online. Small team, no infra experience, 500 users.
```

What happens: picks the simplest target from `references/pipelines.md` (PaaS first; containers when needed; K8s only with a forcing reason + an owner) → runs `scripts/container-check.sh` on Dockerfiles/compose → builds the pipeline from `templates/ci.yml` (lint → test → build → scan → staging → smoke → promote the *same artifact SHA*) → wires per-environment secrets/identities → writes the rollback path *before* merging (previous tag/SHA, migration-compatible). Migrations run as a separate expand→migrate→contract step, never in app boot.

```bash
bash ~/.claude/skills/devops-delivery/scripts/container-check.sh [project-root]
```

**FAILs:** literal secrets in `ENV`/`environment`, unpinned (`:latest`/untagged) images. **WARNs:** missing `HEALTHCHECK`, `ADD` over `COPY`, running as root, missing `.dockerignore`, compose services without `restart:`. Every prod deploy names its rollback and its 24h owner, or it doesn't ship.

### 9. `observability-scale` — diagnose, scale, operate

**Use when you say:** "the app is slow", "can this handle X users", "we're launching tomorrow", "should we add Redis", "set SLOs", "production is down", "write a postmortem".
**Not for:** initial builds, architecture selection, or pipelines.

```text
Our booking list takes 8 seconds with 500 rows. Django + Postgres. What's wrong?
```

What happens: instruments first (p95, error rate, saturation — no metrics is itself finding #1) → finds the actual bottleneck top-down (edge → app → queries with `EXPLAIN ANALYZE` → connections → downstream) → climbs `references/scaling-ladders.md` **one rung at a time**, each with trigger + proof metrics → sets SLOs (`templates/slo.md`: availability + latency, burn-rate alerts, freeze policy) → runs incidents per `references/incident-response.md` (mitigate first: rollback, shed load) → lands a blameless postmortem (`templates/postmortem.md`) with owned, dated actions.
No script — measurement and judgment work; quality gate is the evals. **Rules:** no scaling number without trigger + proof metrics; cache always carries TTL + invalidation; "human error" is never a root cause.

---

## End-to-end example (all nine, one project)

```text
# 1. Plan — fresh session in an empty dir
I want a booking app for dog groomers: appointments, reminders, payments.
Scope the MVP.                                            # → product-planning → PRD + backlog

# 2. Design — fresh session, PRD attached
Design the backend for this PRD: 5 engineers, reads dominate 10:1.
                                                  # → system-design → docs/adr/*.md + API contract

# 3–4. Build — fresh session in the repo, ADRs referenced
Scaffold the API per ADR-002 (modular monolith, Postgres), then run
preflight and fix the FAILs.                     # → web-app-development
Build the companion mobile app; our team knows React.
                                                  # → cross-platform-mobile → Expo + EAS
The booking list is janky on mobile Safari.       # → frontend-excellence → metrics + fixes

# 5–6. Gate — fresh sessions before ship
Audit this before we ship: logins + Stripe.       # → security-review → findings table
No tests on the booking flow. Start there.        # → quality-assurance → pyramid plan + tests

# 7. Ship
Put this online for 500 users; small team, no infra experience.
                                                  # → devops-delivery → PaaS + pipeline + rollback

# 8. Operate (post-launch loop)
Launch day: 50x traffic expected tomorrow.        # → observability-scale → readiness + SLOs
```

Handoffs are files, not chat context: PRD → ADRs → code → findings → pipeline → SLOs. Each skill reads the previous artifact; no orchestrator needed.

---

## Scripts reference

| Script | Skill | Offline default | Opt-in network | Purpose |
|---|---|---|---|---|
| `preflight.sh` | web-app-development | ✅ | `RUN_AUDIT=1` (npm/pip audit) | Dep floors, EOL images, CORS, secrets, pins |
| `preflight.sh` | cross-platform-mobile | ✅ | `RUN_DOCTOR=1` (expo-doctor) | SDK floors, `targetSdk`, secrets, arch flags |
| `secrets-scan.sh` | security-review | ✅ | — | Client-bundled secrets, key material, cloud tokens |
| `container-check.sh` | devops-delivery | ✅ | — | Baked-in secrets, unpinned images, Dockerfile/compose hygiene |
| `test-check.sh` | quality-assurance | ✅ | — | Test presence, coverage gates, E2E setup, CI wiring |
| `frontend-check.sh` | frontend-excellence | ✅ | — | Missing alt/lang/viewport/title, click-only divs |
| `check-house-style.sh` | repo (CONTRIBUTING gate) | ✅ | — | Script/frontmatter/eval contracts for all skills |

Convention (enforced in CI): `ok/warn/bad` counters → `Summary: X ok, Y warn, Z FAIL` → exit 1 on any FAIL. Doc-driven skills (`product-planning`, `system-design`, `observability-scale`) intentionally ship no script — grep cannot review an ADR.

---

## Snapshot freshness policy

Version/store data rots fast (Next.js shipped ~3 security releases in 10 days in Sept 2026):

- `current-state.md` files refresh **monthly**; each carries a `## Changelog` footer (last refresh + next review).
- Mobile: snapshot > 30 days old → re-verify live before it drives a decision.
- Web: Next.js / Express-ecosystem / Django versions are **always** re-confirmed live, regardless of snapshot date.
- CI **fails past 60 days** stale, warns past 30. When a live source disagrees with a snapshot, live wins and the snapshot gets refreshed.
- New skills only earn a snapshot file if versions/deadlines drive their decisions — freshness burden must be justified (`CONTRIBUTING.md`).

---

## Testing the skills

Full methodology in `TESTING.md`: trigger tests (does it fire / not fire) + with-vs-without output tests, 8 prompts per skill, pass at 80%, security and live-source misses are defects.

```bash
# Automatic checks (10 seconds, no AI) — from the repo root:
for s in web-app-development cross-platform-mobile website-building security-review devops-delivery quality-assurance frontend-excellence; do
  bash $s/$s/evals/check-fixtures.sh || exit 1
done
bash scripts/check-house-style.sh   # 28 portfolio checks
```

---

## Repo layout

The double nesting mirrors the Claude install layout (`~/.claude/skills/<name>/SKILL.md`), so each inner folder is install-ready:

```
product-planning/product-planning/SKILL.md        # Plan
system-design/system-design/{SKILL.md,references/,templates/,evals/}   # Design
web-app-development/web-app-development/{SKILL.md,references/,scripts/,evals/}  # Build
...
scripts/check-house-style.sh   # portfolio gate (CONTRIBUTING.md Decisions 1–3)
.github/workflows/ci.yml       # shellcheck + gates + fixtures + freshness
CONTRIBUTING.md  TESTING.md    # policy + methodology
```

Do not import across skills — composition happens through handoff files (PRD, ADRs, findings), not shared code.

---

## Windows

All `*.sh` scripts need **Git Bash** (`"C:\Program Files\Git\bin\bash.exe" …\scripts\preflight.sh`) or **WSL2**; `cmd.exe` is not supported. `install.ps1` handles installation (no admin). Line endings are pinned via `.gitattributes` (LF for scripts).

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Skill doesn't trigger | Use a fresh session; name the keyword ("MVP", "ADR", "audit", "E2E", "SLO"). If a should-trigger prompt repeatedly misses, its phrasing belongs in that skill's `description` — see `TESTING.md` Step 1. |
| Wrong skill triggers | Tighten the moment: "scope the MVP" (planning) vs "design the system" (architecture) vs "audit before ship" (security). The `Not for…` clauses disambiguate. |
| Script fails on a clean repo | Check you're in the project root and on Git Bash/WSL; run `bash -n <script>` for syntax; WARNs are advisory — read the flagged code. |
| Snapshot vs live version conflict | Live source wins, always. Note it and refresh the snapshot file. |
| `npm install` ERESOLVE after an Expo upgrade | Peer cap in a library — check its issues for a compatible release before `--legacy-peer-deps`; then `npx expo-doctor` (mobile skill). |
| Fixture suite fails after editing a threshold | Update `preflight`/check thresholds **and** `evals/check-fixtures.sh` together, then `current-state.md` — the three move as one. |

---

## Contributing

Read `CONTRIBUTING.md` before adding or splitting a skill: the merge-vs-split triggers (with the `database-design` worked example), the script-vs-doc-driven registry, the script/frontmatter/eval contracts, and the PR checklist. `scripts/check-house-style.sh` + CI enforce it.

---

## Known gaps

- `website-building` covers marketing/landing/portfolio/blog sites (static-first). "Make a landing page" triggers it — the former gap is closed.
- Fixtures use illustrative placeholder versions (e.g. `expo ~56.0.0`); the failures they trigger are real.
- Flask coverage is minimal (detection + generic checks); Django/FastAPI are the supported Python paths.
- Not tested: claude.ai upload path, API (`/v1/skills`) path.

---

## License

MIT — see `LICENSE`.
