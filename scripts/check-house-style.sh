#!/usr/bin/env bash
# House-style gate for the skill portfolio. Enforces CONTRIBUTING.md Decisions 1-3.
# Usage: scripts/check-house-style.sh  (run from repo root; needs python3 for JSON checks)
# Exit code: 0 = all pass, 1 = at least one violation.

PASS=0; FAILN=0
pass() { echo "PASS  $1"; PASS=$((PASS+1)); }
viol() { echo "FAIL  $1"; FAILN=$((FAILN+1)); }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || { echo "Cannot cd to $ROOT"; exit 2; }
echo "House-style check in $(pwd)"

# Registry for Decision 2: doc-driven skills MUST NOT have scripts/;
# script-bearing skills MUST have evals/check-fixtures.sh.
DOC_DRIVEN="product-planning system-design observability-scale"
is_doc_driven() { case " $DOC_DRIVEN " in *" $1 "*) return 0;; *) return 1;; esac; }

# ---- A. audit-script contract (Decision 3) --------------------------------------
for script in */*/scripts/*.sh; do
  [ -f "$script" ] || continue
  ok=1
  [ "$(head -1 "$script")" = "#!/usr/bin/env bash" ] || { viol "$script: first line must be #!/usr/bin/env bash"; ok=0; }
  grep -q '^# Usage:' "$script" || { viol "$script: header must document Usage:"; ok=0; }
  for fn in 'ok()' 'warn()' 'bad()'; do grep -q "$fn" "$script" || { viol "$script: must define $fn counter"; ok=0; }; done
  grep -q 'Summary:' "$script" || { viol "$script: must print a Summary: line"; ok=0; }
  [ "$(grep -v '^[[:space:]]*$' "$script" | tail -1)" = '[ "$FAIL" -eq 0 ]' ] || { viol "$script: last line must be [ \"\$FAIL\" -eq 0 ] (exit 1 on FAIL)"; ok=0; }
  if grep -Eq 'curl|wget|npm audit|pip-audit|expo-doctor' "$script"; then
    grep -q 'RUN_' "$script" || { viol "$script: network use must sit behind a RUN_* gate (offline by default)"; ok=0; }
  fi
  [ "$ok" = 1 ] && pass "$script meets the script contract"
done

# ---- B. SKILL.md frontmatter contract (Decision 3) -------------------------------
for skillfile in */*/SKILL.md; do
  [ -f "$skillfile" ] || continue
  skill=$(basename "$(dirname "$skillfile")")
  ok=1
  [ "$(head -1 "$skillfile")" = "---" ] || { viol "$skillfile: must open with --- frontmatter"; ok=0; }
  grep -q "^name: $skill$" "$skillfile" || { viol "$skillfile: frontmatter name: must match directory ($skill)"; ok=0; }
  DESC=$(sed -n '/^---$/,/^---$/p' "$skillfile" | grep '^description:' | sed 's/^description: //')
  [ "${#DESC}" -ge 200 ] || { viol "$skillfile: description is ${#DESC} chars, need >= 200 (trigger keywords need room)"; ok=0; }
  echo "$DESC" | grep -q 'Not for' || { viol "$skillfile: description must contain a Not for exclusion clause"; ok=0; }
  [ "$ok" = 1 ] && pass "$skill meets the frontmatter contract"
done

# ---- C. evals structure contract (Decision 3) --------------------------------------
for f in */*/evals/evals.json; do
  [ -f "$f" ] || continue
  skill=$(basename "$(dirname "$(dirname "$f")")")
  if ! python3 -c "
import json,sys
d = json.load(open('$f'))
assert d.get('skill_name') == '$skill', 'skill_name must match directory ($skill)'
assert len(d.get('evals', [])) == 8, 'must contain exactly 8 evals'
for e in d['evals']:
    assert e.get('prompt') and e.get('expected_output'), 'eval needs prompt + expected_output'
    assert len(e.get('expectations', [])) >= 3, 'eval needs >= 3 expectations'
" 2>&1; then viol "$f: evals contract broken (skill_name == dir, 8 evals, prompt + expected_output + >=3 expectations each)"; else pass "$f meets the evals contract"; fi
done

# ---- D. script-vs-doc-driven registry, both ways (Decision 2) ----------------------
for dir in */*/; do
  case "$dir" in */evals/*|scripts/*|.github/*) continue;; esac
  [ -f "${dir}SKILL.md" ] || continue
  skill=$(basename "$dir")
  if is_doc_driven "$skill"; then
    [ -d "${dir}scripts" ] && viol "$skill: registered doc-driven but ships scripts/ (remove it or re-register with reason)"
  else
    [ -d "${dir}scripts" ] || viol "$skill: script-bearing skills must ship scripts/"
    [ -f "${dir}evals/check-fixtures.sh" ] || viol "$skill: script-bearing skills must ship evals/check-fixtures.sh"
  fi
done
pass "doc-driven registry consistent ($DOC_DRIVEN)"

echo; echo "$PASS passed, $FAILN failed"
[ "$FAILN" -eq 0 ]
