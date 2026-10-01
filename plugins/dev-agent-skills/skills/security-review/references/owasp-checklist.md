# OWASP review checklist

Work top-down. Stop and report Criticals immediately; do not save them for the end.

## A01 Broken access control (the most common real-world finding)

- Every resource access checks "can *this* user touch *this* record?" — object-level, not just route-level. Test with two accounts: can user A fetch user B's `/orders/{id}` by guessing IDs?
- Admin endpoints verify role server-side on every request. Hidden UI buttons are not access control.
- CORS: explicit origin allowlist from config. `*` + credentials is a finding.

## A02 Cryptographic failures

- Passwords: argon2id/bcrypt via maintained library. No plaintext, no MD5/SHA-fast-hashes, no homegrown KDF.
- Transport: HTTPS everywhere, HSTS, `Secure` cookies. Secrets in URLs (query params, logs) are findings.
- Sensitive data encrypted at rest where the platform offers it; keys in a secret manager, never in repo or client bundle.

## A03 Injection

- SQL: parameterized queries / ORM only. String-concatenated queries are findings.
- NoSQL: never pass request data into a filter; cast through a schema, enable `sanitizeFilter`. `findOne(req.body)` is the canonical finding.
- XSS: framework escaping by default; `dangerouslySetInnerHTML` / `{!! !!}` / `mark_safe` only with a sanitizer. No user HTML without one.
- Command/LDAP/EL injection: no shell-out with interpolated input; no `$where`, no `eval`.

## A04 Insecure design

- Threat model exists for auth, payments, and PII flows (see `threat-modeling.md`). Missing rate limiting on login, no account lockout/backoff, password reset tokens without expiry: all findings.

## A05 Misconfiguration

- Debug off in production, generic error pages (no stack traces), security headers (`helmet` or equivalent, CSP at least blocking untrusted inline script).
- Storage buckets / upload locations: no public-list, no execution permission, random storage keys.

## A06 Vulnerable components

- `npm audit --omit=dev` / `pip-audit` clean on High/Critical, or exceptions written down with dates. Pin exact versions in lockfiles. Every middleware package is attack surface.

## A07 Auth failures

- Session IDs rotate on login; cookies `HttpOnly; Secure; SameSite=Lax/Strict`. Tokens: short-lived access + rotating refresh, verify signature/`exp`/audience.
- MFA offered on privileged accounts. Credential stuffing defenses (rate limit + breach-password screening) on login.

## A08 Integrity failures (supply chain + updates)

- Lockfiles committed; CI verifies them. No unpinned `latest` images in production. In-app/OTA updates only from signed sources; native changes never ship via OTA.

## A09 Logging failures

- Auth events, access-control failures, and input-validation failures are logged — without secrets, tokens, or full auth headers. Logs have an owner and a retention policy, or they are write-only noise.

## A10 SSRF / request forgery

- Server-side fetches of user-supplied URLs are allowlisted or proxied with egress controls. Webhook receivers verify signatures. File uploads verified by magic bytes, size/count-limited, stored in object storage.
