# Results: what this portfolio provably does

Two kinds of evidence live here. **Measured** (ran on 2026-10-01, re-runnable in ~30 seconds — commands below) and **open** (the with-vs-without AI protocol from `TESTING.md`, awaiting runs; empty tables are marked as such, not filled with wishes).

## Measured: deterministic suites (all green)

```bash
for s in web-app-development cross-platform-mobile website-building \
         security-review devops-delivery quality-assurance frontend-excellence; do
  bash $s/$s/evals/check-fixtures.sh || exit 1
done
bash scripts/check-house-style.sh          # 28 portfolio checks
bash scripts/sync-plugin.sh --check        # plugin copies vs canonical
```

| Suite | Result (2026-10-01) | What it proves |
|---|---|---|
| web-app-development fixtures | 4 passed, 0 failed | RCE floor, multer/mongoose/mongo EOL, CORS wildcard, Django 3.15 pin all fire correctly |
| cross-platform-mobile fixture | 1 passed (4 FAILs) | Old SDK, `newArchEnabled`, bundled secret, low `targetSdk` all caught |
| website-building fixture | 1 passed (1 FAIL) | Broken links FAIL; 7 SEO WARN classes fire |
| security-review fixture | 1 passed (4 FAILs) | Bundled secret, private key, live token, tracked `.env` all caught |
| devops-delivery fixture | 1 passed (1 FAIL) | Baked-in secrets FAIL; 5 hygiene WARNs fire |
| quality-assurance fixtures | 2 passed (1 FAIL / 0 FAILs) | Test-less repo FAILs; tested repo passes |
| frontend-excellence fixture | 1 passed (1 FAIL) | Missing `alt` FAILs; lang/viewport/title/click-div WARNs fire |
| house-style gate | 28 passed, 0 failed | Every script meets the contract; every skill has valid frontmatter + 8-prompt evals |
| plugin sync | 10 in sync, 0 drifted | Distributed copies byte-match canonical skills |
| installer matrix | 4 agents + link-fallback + default HOME | All destinations land 10/10 `SKILL.md` files |

Total: **7 fixture suites, 28 gate checks, 80 graded AI prompts (10 skills × 8), 0 failures.**

## Measured: bugs the gates caught during development

Not hypothetical — each of these was found by running the suites above, then fixed:

1. `container-check.sh` used grep-style flags with `find`: silently found zero Dockerfiles. Fixture caught it (`--exclude-dir` is not a `find` predicate).
2. `install.sh --agent bogus --dest X` skipped validation and installed with exit 0. Edge-case tests caught it.
3. `install.sh --link` silently copied instead of linking on systems without symlink rights. Now warns loudly + falls back.
4. `check-house-style.sh` v1 anchored `^Usage:` and missed the `# ` prefix all six scripts share. Its own first run caught it.
5. Committing fixture `.env` files added a 4th FAIL to the security suite — the check now derives the count from git state (4 committed, 3 exported; both proven).

## Open: with-vs-without AI protocol (results wanted)

The deterministic suites prove the *scripts* work. The remaining claim — *skills change model output* — is tested per `TESTING.md` Step 2: same prompt twice (skill installed vs removed), graded against `evals.json` expectations at 80%, security/live-source misses counted as defects. **No scores are claimed here until run** — the harness is ready, the table is empty:

| Skill | With-skill pass rate | Baseline pass rate | Delta | Run date / runner |
|---|---|---|---|---|
| product-planning | — | — | — | wanted |
| system-design | — | — | — | wanted |
| web-app-development | — | — | — | wanted |
| cross-platform-mobile | — | — | — | wanted |
| website-building | — | — | — | wanted |
| frontend-excellence | — | — | — | wanted |
| security-review | — | — | — | wanted |
| quality-assurance | — | — | — | wanted |
| devops-delivery | — | — | — | wanted |
| observability-scale | — | — | — | wanted |

To contribute a row: follow `TESTING.md` Steps 1–3, then PR this table plus the two transcripts. Partial rows (fewer than 8 evals) are welcome if labeled as such — a plotted 3-eval pilot beats an empty table.
