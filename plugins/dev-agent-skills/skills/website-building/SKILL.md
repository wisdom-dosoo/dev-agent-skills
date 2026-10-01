---
name: website-building
description: Build marketing websites, landing pages, portfolios, small-business sites, blogs, and docs sites. Covers static-first stacks (Astro, static export), page structure and copy outlines, contact forms, lightweight CMS choices, SEO essentials (meta, Open Graph, sitemap), and static hosting. Use this skill whenever the user mentions landing page, marketing site, homepage, portfolio site, business website, brochure site, blog, docs site, SEO pages, coming-soon page, or asks for a website that presents content and captures leads, even if they only say "make a website for my bakery" or "I need an online presence". Not for web apps with accounts, dashboards, or databases (see web-app-development), mobile apps (see cross-platform-mobile), or visual brand/logo design from scratch.
---

# Website building

You build sites that *present and persuade* — one conversion action per page, static-first, measurable. Anything with logins, dashboards, or a database is a web app: hand it to `web-app-development` and say so in one line.

## Workflow

1. **Clarify the job.** One conversion action (book a call, join the list, buy, apply)? Who reads it, what proof do they need? Ask at most two questions; a site without a conversion action is a brochure nobody measures.
2. **Pick the stack** from `references/stacks.md` (default: Astro for content sites; static export when it lives next to an app). Confirm the scaffolder's current version live for greenfield builds — no snapshot file here by policy, the tooling moves too slowly to justify one and too fast to trust memory.
3. **Outline before building** with `templates/landing-outline.md`: sections in order, one message each, proof placed before the ask. Get the outline agreed before writing code — reordering sections is cheap, rebuilding pages is not.
4. **Run `scripts/site-check.sh`** once pages exist. Fix FAILs (broken internal links); work through WARNs (meta/OG/canonical/sitemap/robots).
5. **Forms and dynamic bits:** every form posts to a real endpoint with spam protection (never `mailto:` as the only path); comments/search/newsletters are services, not hand-rolled backends.
6. **Verify like a visitor:** production build served locally, all links clicked, social-card preview checked, Lighthouse run (then hand deep perf/a11y work to `frontend-excellence` with the numbers).

## Hard rules

- Static-first: content pages ship zero client JS framework by default. Reach for islands/hydration only for the interactive widget, never the page.
- One page, one conversion action, stated above the fold. Every section earns its place by moving the reader toward it.
- Never publish without: unique `<title>` + meta description, OG title/image, canonical URL, `sitemap.xml`, `robots.txt`, and a 404 page.
- Images get `alt`, dimensions (no layout shift), and modern formats — same bar as `frontend-excellence`, applied at build time.
- Copy is part of the build: no lorem ipsum in committed pages, no stock claims without proof (numbers, names, logos you may use).
- State plainly what you did not verify (e.g. "social cards not previewed", "CMS preview not tested with an editor").

## Output style

Outline first (sections + one-line message each), then code. Exact deploy commands for the chosen host. Separate decided content (approved copy) from placeholder (clearly marked TODO with an owner).
