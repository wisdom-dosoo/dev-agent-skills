# SEO essentials (launch checklist)

Search and social cards run on static markup — crawlers don't wait for hydration, which is why this skill is static-first.

## Every indexable page

- Unique `<title>` (≤ 60 chars, primary keyword + brand) and meta description (≤ 160 chars, written to earn the click, not stuffed).
- Canonical URL (`<link rel="canonical">`) — one per page, absolute, self-referencing unless consolidation is intended.
- Open Graph + Twitter cards: `og:title`, `og:description`, `og:image` (1200×630, absolute URL), `og:url`. Verify with a card validator before launch, not after someone shares a gray box.
- Exactly one `h1` matching the page's promise; subsections nest `h2`/`h3` without skipping. Headings describe content, not design ("Pricing", not "Section 3").
- Semantic landmarks (`header/nav/main/footer`), `lang` attribute, descriptive `alt` — same bar as `frontend-excellence`, checked at build time.

## Site level

- `sitemap.xml` listing canonical URLs only (no drafts, no 404s, no parameterized duplicates), referenced from `robots.txt`. Regenerate on content change — in CI for CMS-driven sites.
- `robots.txt` allowing crawlers on launch (staging must `Disallow: /` — launching with staging's robots file is a classic outage).
- Custom 404 page returning real 404 status with links to live content — never a soft-404 homepage redirect.
- Structured data (`JSON-LD`) for the entities you are: Organization/LocalBusiness on the homepage, Article on posts, FAQPage where FAQs exist. Validate, don't hand-wave.

## Performance is SEO

Core Web Vitals are ranking inputs: run Lighthouse on the production build (mobile, throttled) and hand misses to `frontend-excellence` with numbers. The usual marketing-site killers: unoptimized hero images, third-party embeds (chat widgets, video players — facade them), and webfont chains.

## What the script enforces

`scripts/site-check.sh` FAILs on broken internal links and WARNs on missing description/OG/canonical/sitemap/robots/single-h1/form-endpoint. Rankings themselves, card rendering, and crawler behavior stay manual — check them before launch, not after traffic arrives.
