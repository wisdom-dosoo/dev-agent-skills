# Threat modeling (lightweight)

Full STRIDE workshops are for regulated systems. For everything else, 15 minutes of this beats none.

## The four questions

1. **What are we protecting?** List assets: credentials, PII, payment data, admin capabilities, user-generated content that others see.
2. **Who wants it?** Attackers in order of likelihood: opportunistic bots (credential stuffing, scanners), malicious users (IDOR, quota abuse), compromised dependencies (supply chain), insiders (over-broad admin).
3. **Where would they enter?** Draw the trust boundaries: browser ↔ API ↔ DB, webhooks in, file uploads, third-party SDKs, admin panel. Every crossing is a checkpoint that must authenticate, validate, and authorize.
4. **What breaks worst?** Rank paths by (value × exposure). Auth bypass and secret leakage outrank missing security headers. Review in that order.

## Per-flow minimum

For each of login, signup/reset, payments, uploads, and admin actions, write one line each:

- Asset: <what is at stake>
- Boundary: <where untrusted input enters>
- Check: <auth + validation + authz mechanism>
- Abuse case: <what an attacker tries, e.g. "replay the reset token", "enumerate order IDs">

If you cannot fill in "Check" from reading the code, that is a finding (missing control), not an unknown.

## Output

A short table (flow, asset, attacker path, control status: present/missing/weak) that feeds the findings report. Keep it; it becomes the regression list for the next review.
