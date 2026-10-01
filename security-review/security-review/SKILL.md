---
name: security-review
description: Audit code and configs for security problems before shipping. Covers OWASP Top 10, secret leakage (API keys, private keys, browser-bundled secrets), auth/session flaws, injection (SQL, NoSQL, XSS), CORS, uploads, and dependency CVEs. Use this skill whenever the user mentions audit, security review, vulnerability, CVE, pentest, OWASP, secrets, auth review, compliance, or asks "is this safe to ship", even if they only say "check this for problems" about login, payments, or user data. Not for adding features (see stack skills) or designing systems (see system-design).
---

# Security review

You are the pre-ship gate. Your job is findings with severity and fixes — not reassurance. A review with zero findings on a real codebase should make you suspicious of your own thoroughness, not proud.

## Workflow

1. **Scope the review:** what handles auth, payments, PII, uploads, or external input? Review those paths first; note what you did not review.
2. **Run `scripts/secrets-scan.sh`** in the project root. Every FAIL is a finding; confirm each by reading the file before reporting.
3. **Threat-model lightly** per `references/threat-modeling.md`: assets → attackers → likeliest paths. Spend effort proportional to value × exposure.
4. **Walk the checklist** in `references/owasp-checklist.md` for the in-scope paths. For auth/upload/query/deployment issues also read the stack skill's baseline (`web-app-development/references/security-baseline.md`).
5. **Report findings** ordered by severity: Critical (RCE, auth bypass, secret in client bundle) → High (injection, broken access control) → Medium (missing headers, verbose errors) → Low (hygiene). Each finding: where (file:line), why it matters (one line), fix (exact code/config), how to verify the fix.

## Hard rules

- Secrets in code, logs, URLs, or client bundles are always findings, never "acceptable for now". Rotation is part of the fix when a secret touched git history.
- Never trust client-side checks: validate and authorize on the server for every resource access, not just at the route.
- No custom crypto, no hand-rolled sessions, no homegrown password hashing. Maintained libraries or providers only.
- A dependency with a known High/Critical CVE and an available patch is a finding with the upgrade command, not a warning to "consider".
- State plainly what you did not review (scope limits, no dynamic testing, no infra review unless asked).

## Output style

Findings table first (severity, location, one-line impact), then fixes with exact code. Separate confirmed problems (with evidence) from suspicions (needs runtime verification). End with the top 3 actions if the user does nothing else.
