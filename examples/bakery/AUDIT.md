# AUDIT.md — Crumb & Craft v1 (built 2026-10-01)

How this example was built: `product-planning` (PRD.md) → `system-design` (docs/adr/001, 002) → `website-building` (pages) → gates below. Skill outputs below are real runs (working-directory prefix trimmed); exit codes preserved.

## site-check.sh — exit 0

```
8 ok, 0 warn, 0 FAIL
[ok] no broken internal links · meta descriptions · OG tags · canonicals ·
     one h1 per page · sitemap.xml · robots.txt · form endpoint
```

## secrets-scan.sh — exit 0

```
4 ok, 1 warn, 0 FAIL
[warn] .gitignore does not list .env   <- benign here: the repo-root .gitignore
     covers .env and this example ships no secrets; accepted, not fixed.
```

## frontend-check.sh — exit 0

```
5 ok, 0 warn, 0 FAIL (alt, lang, viewport, title, no click-only divs)
```

## test-check.sh — exit 1 (accepted residual, not hidden)

```
[FAIL] no test files found
```

Accepted with reason: a zero-JS static site has no units to test; link/SEO/a11y coverage comes from the three passing checks above. Revisit trigger: the day the site gains JavaScript beyond the form post, ADR-001 is reopened and tests land with it. CI-workflow WARNs are likewise accepted — this example ships as static files, not through the repo pipeline.

## Pre-launch TODOs (owner: shop)

- [ ] Replace `https://forms.example.com/bakery-orders` with the real endpoint; submit once and confirm the inbox (ADR-002 counter-metric).
- [ ] Preview OG cards with a card validator before first share.
- [ ] Swap `bakery.example.com` canonicals/sitemap for the real domain.
