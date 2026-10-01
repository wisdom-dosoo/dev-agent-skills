# Contributing: skill portfolio policy

This file turns three deliberate scope decisions into rules. Read it before adding or splitting a skill. `scripts/check-house-style.sh` enforces the machine-checkable parts in CI.

## Decision 1 — Skill granularity: merge by default, split on evidence

One skill = one job-to-be-done at one trigger moment. New skills start life as a `references/` file inside the nearest skill, and graduate only when **all three** split triggers hold:

1. **Divergent triggers.** Real prompts exist that need the new context but would *not* fire the parent skill (or would fire it with the wrong workflow). Show 3+ such prompts.
2. **Context overload.** The parent's references would grow past ~200 lines to cover the topic, diluting every trigger of the parent.
3. **Independent freshness.** The topic rots on a different schedule than the parent (different vendor blogs, different cadence), so sharing a snapshot harms one side.

**Worked example — `database-design` stays folded into `system-design`.** Data modeling is currently `system-design/references/data-modeling.md` because: (a) modeling prompts ("Postgres or Mongo?", "how do I index this?") already fire `system-design` — no divergent trigger proven; (b) the file is ~60 lines, far from overload; (c) index/migration guidance rots slowly, unlike framework patch levels. Split it the day someone shows 3+ prompts that need deep per-engine tuning (partitioning schemes, migration runbooks, per-index-type trade-offs) *without* wanting architecture advice. Until then, expanding the references file is the fix, not a new skill.

**Anti-patterns:** god-skills ("full SDLC assistant"), skill-per-framework (playbooks inside one stack skill instead), skill-per-template (templates live in `templates/`, they are not skills).

## Decision 2 — Scripts only where deterministic; evals everywhere

Scripts exist where a machine can check something (`preflight.sh`, `secrets-scan.sh`, `container-check.sh`, `test-check.sh`, `frontend-check.sh`). Judgment work gets no script — a grep cannot review an ADR, a scope, or an SLO.

- **Script-bearing skills** (web-app-development, cross-platform-mobile, security-review, devops-delivery, quality-assurance, frontend-excellence) MUST ship `evals/check-fixtures.sh` proving the script's FAILs on broken fixtures.
- **Doc-driven skills** (product-planning, system-design, observability-scale) MUST NOT ship a token script to look complete. Their quality gate is `evals/evals.json` (8 prompts, checkable expectations) graded at 80% per `TESTING.md`, Step 2.
- The checker enforces this registry both ways: a `scripts/` dir without a fixture test fails, and a new undocumented doc-driven skill fails. Update the `DOC_DRIVEN` list in `scripts/check-house-style.sh` when a skill legitimately changes category — with the reason in the commit message.

## Decision 3 — Script house style (the contract)

Every audit script (`<skill>/<skill>/scripts/*.sh`) MUST:

1. Start with `#!/usr/bin/env bash` and a header documenting `Usage:` (including which `RUN_*=1` flags enable network behavior).
2. Define `ok()` / `warn()` / `bad()` counters printing `  [ok]`, `  [warn]`, `  [FAIL]` respectively.
3. Print a `Summary: $PASS ok, $WARN warn, $FAIL FAIL` line.
4. Exit 0 on no FAILs, 1 on any FAIL (conventionally `[ "$FAIL" -eq 0 ]` as the last line).
5. Touch the network only behind a `RUN_*` gate (default runs are offline and deterministic). If the script mentions `curl`, `wget`, `npm audit`, `pip-audit`, or `expo-doctor`, it must also mention `RUN_`.
6. Exclude generated/vendor dirs from scans (`node_modules`, `.venv`, `venv`, `.git`, build output).

Every `SKILL.md` MUST: carry `---` frontmatter with `name:` matching its directory, a `description:` of ≥ 200 characters (trigger keywords need room) containing a `Not for …` exclusion clause (nearest-neighbor skills, not distant ones), and name its inputs/outputs so file-based handoffs work without an orchestrator.

Every `evals/evals.json` MUST: be valid JSON with `skill_name` matching the directory, exactly 8 evals, each with non-empty `prompt`, `expected_output`, and `expectations` (≥ 3 checkable behaviors; security and live-source expectations are defects if missed, per `TESTING.md`).

## Adding a skill (checklist)

- [ ] Proves all three split triggers (Decision 1) in the PR description, or lands as a `references/` file instead.
- [ ] Declares script-bearing (with fixture test) or doc-driven (added to `DOC_DRIVEN` with reason).
- [ ] Passes `scripts/check-house-style.sh` and every fixture suite in `README.md`.
- [ ] If any skill changed, re-ran `scripts/sync-plugin.sh` so the Codex plugin copies match (CI checks this).
- [ ] Wired into `README.md` table, `install.sh` / `install.ps1`, and `.github/workflows/ci.yml`.
- [ ] Snapshot file only if versions/store-deadlines drive decisions; otherwise no `current-state.md` (freshness burden must be earned).
