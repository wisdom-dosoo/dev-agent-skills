# Testing the two skills

Two things can go wrong with a skill: it **doesn't trigger** when it should (or triggers when it shouldn't), or it **triggers but doesn't change the output**. Test both.

Test files live inside each skill: `evals/evals.json` (8 prompts each, with checkable expectations), `evals/files/` (small broken projects to run against), and `evals/check-fixtures.sh` (automatic check of the preflight scripts).

---

## Step 0: automatic check (10 seconds, no AI)

```bash
# from a repo checkout (no install needed):
bash web-app-development/web-app-development/evals/check-fixtures.sh      # expect: 4 passed, 0 failed
bash cross-platform-mobile/cross-platform-mobile/evals/check-fixtures.sh  # expect: PASS expo-old (4 expected FAILs)

# or, once installed:
~/.claude/skills/web-app-development/evals/check-fixtures.sh
~/.claude/skills/cross-platform-mobile/evals/check-fixtures.sh
```
Other fixture suites (same pattern): `website-building` (expect 1 FAIL), `security-review` (3 content FAILs, +1 tracked-.env FAIL once committed — derived from git state, see its `check-fixtures.sh`), `devops-delivery` (expect 1 FAIL), `quality-assurance` (no-tests 1 FAIL, tested 0 FAILs), `frontend-excellence` (expect 1 FAIL). Doc-driven skills (`product-planning`, `system-design`, `observability-scale`) have `evals/evals.json` (8 prompts each) but no fixtures — test them via Step 2 only. The full contract (when a skill earns scripts, frontmatter and eval rules) lives in `CONTRIBUTING.md` and is enforced by `scripts/check-house-style.sh`.
This only tests the scripts. Run it again whenever you edit a threshold in a script. On Windows, run these from Git Bash or WSL (see README.md).

---

## Step 1: does it trigger? (the description test)

Open a **fresh session** for each prompt (a skill already read earlier in a chat skews the result). Pass = the skill's `SKILL.md` is read or the skill is named in Claude's steps.

**Should trigger, `web-app-development`**
| # | Prompt |
|---|---|
| 1 | "Set up a MERN app for a recipe site" |
| 2 | "My login endpoint feels slow and I think it's unsafe, can you look?" *(vague, no framework named)* |
| 3 | "npm audit shows a high severity in multer" |
| 4 | "Should I use Django or FastAPI for this?" |
| 5 | "Upgrade Next.js, I heard there was a security release" |
| 6 | "Build a REST API for my dashboard" |

**Should trigger, `cross-platform-mobile`**
| # | Prompt |
|---|---|
| 1 | "Build an app for iPhone and Android" *(vague)* |
| 2 | "eas build fails with a Gradle error" |
| 3 | "Is Expo or Flutter better for us?" |
| 4 | "Google says I must raise my target API level" |
| 5 | "Upgrade my Expo SDK" |
| 6 | "How do I submit my React Native app to TestFlight?" |

**Should trigger, `website-building`**
| # | Prompt |
|---|---|
| 1 | "Make a landing page for my bakery" |
| 2 | "Build a marketing site for our SaaS" *(vague)* |
| 3 | "Our shared links show a gray box with no image" |
| 4 | "We need a blog our team can publish to" |
| 5 | "Astro or Next.js for our marketing site?" |
| 6 | "Plan the pages for a freelancer portfolio" |

**Should NOT trigger either skill**
| # | Prompt | Why |
|---|---|---|
| 1 | "Write a Python script that renames files by date" | Not a web app |
| 2 | "Write a SQL query for monthly revenue" | Not a web app |
| 3 | "Make a PowerPoint about our Q3 results" | Different skill |
| 4 | "Build a native Swift app for the Apple Watch" | Mobile skill excludes native-only apps |
| 5 | "Explain how binary search works" | General knowledge |

**Scoring:** if a should-trigger prompt misses, add that phrasing to the skill's `description` and retest. If a should-not prompt triggers, tighten the "Not for ..." clause. Aim for at least 5 of 6 on each should-trigger list and 0 false triggers.

---

## Step 2: does it change the output? (with vs without)

For each eval, run the same prompt twice: once with the skill installed, once without. The difference is what the skill is worth. If the two answers are about equally good, the skill isn't earning its place for that case.

### Claude Code
```bash
# WITH the skill: run inside the fixture folder named in the eval's "files"
cd ~/.claude/skills/web-app-development/evals/files/next-old
claude
# paste the prompt from evals.json (id 2), then check the expectations

# WITHOUT the skill: hide it, repeat, then put it back
mkdir -p ~/.claude/skills-off
mv ~/.claude/skills/web-app-development ~/.claude/skills-off/
# ... run the same prompt in a NEW session ...
mv ~/.claude/skills-off/web-app-development ~/.claude/skills/
```
Tip: copy the fixture folder somewhere else first if you want to let Claude edit files.

### claude.ai
Zip the fixture folder, attach it to a new chat, and paste the prompt. For the "without" run, switch the skill off in **Customize > Skills** (or use a chat in an account without it). Web search must be on, or the "verify live" expectations cannot pass.

---

## Step 3: score each run

Open `evals/evals.json`, read the `expectations` for that eval, and mark each Pass or Fail. A run passes at **80% or more**. Two expectations matter most and any failure is a defect worth fixing:

1. **"Verifies from a live source instead of memory."** The skills' main promise. If Claude states a version number with no source, the freshness rule is not working.
2. **Security items** (RCE flagged, secret not placed in `EXPO_PUBLIC_`, NoSQL injection caught). A miss here is a wrong answer, not a style issue.

Use `evals/evals.json` with the skill-creator skill if you want it to run, grade, and chart these automatically; the file is already in its format.

---

## Things that will change, so test behavior, not numbers

Expectations name behaviors ("confirms the latest patched version from a live source") rather than exact versions, because numbers move: Next.js 16.3.8 was scheduled for Sept 30, Python 3.15.0 for Oct 1, and Expo SDK 58 may already be out. When a run gives a newer number than `current-state.md` and cites a source, that is a **pass**, and the cue to refresh the snapshot file.

## Known gaps

- **Boundary case (now covered):** "Make a landing page" triggers `website-building`, not the web-app skill. If the web-app skill fires on it instead, tighten its "Not for static marketing sites" clause.
- **Fixtures use placeholder versions** (e.g. `expo ~56.0.0`, `react-native 0.85.0`). They are illustrative; the failures they trigger (newArchEnabled, secret in `EXPO_PUBLIC_`, target SDK 35) are real.
- **Not tested:** the claude.ai upload path, and the API (`/v1/skills`) path.
