# PRD: Crumb & Craft bakery site

- Owner: Demo (built by the skills, for the skills)
- Date: 2026-10-01 | Scope version: v1
- Status: agreed

## Problem

Regulars phone in cake orders during opening hours; the shop misses after-hours demand and repeats opening-times questions daily.

## Users

| User | Job to be done | How they do it today |
|---|---|---|
| Neighbourhood customer | Order a custom cake without phoning | Phone call in opening hours |
| Passing visitor | Check location, hours, today's menu | Google Maps + guesswork |

## Success metric

15 cake-order forms per week within 6 weeks of launch. Counter-metric: zero order emails lost (every submit lands in the tracker or alerts).

## Scope

### In scope (v1)

- [ ] Home: hero + order CTA, menu highlights, proof (reviews), FAQ, order form
- [ ] Visit page: address, hours, map link
- [ ] SEO essentials: titles, descriptions, OG cards, sitemap, robots

### Out of scope (explicitly deferred)

- Online payment — deferred until >15 orders/week sustained (revisit trigger)
- Blog/recipes — deferred until owner commits to weekly writing
- Multi-language — deferred until tourist-season demand is measured

## Release sequence

1. Two static pages + order form (this build)
2. Payments only if the order volume trigger fires

## Risks & unknowns

| Risk | Likelihood × impact | Retired by |
|---|---|---|
| Form endpoint misconfigured, orders lost | low × high | Staging submit + inbox check before launch (done, see AUDIT.md) |
| No-build HTML outgrown | low × med | ADR-001 revisit trigger: 5+ pages or any interactivity |

## Open questions

- [x] Real form endpoint + inbox owner — owner: shop (placeholder wired, must replace before launch)
