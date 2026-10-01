# Stacks for content sites

Opinionated defaults. Confirm the scaffolder version live for greenfield work (`create astro`, provider docs) — this file names directions, not pin numbers.

## Default: Astro (content-driven sites)

Landing pages, marketing sites, blogs, portfolios, docs. Islands architecture: static HTML by default, framework components only where interactive. Content collections for typed Markdown/MDX; image optimization built in.

```bash
npm create astro@latest my-site
```

Move off Astro when: the site lives inside an existing Next.js app (use static export there instead), or editors need a visual page builder Astro doesn't offer.

## Next.js static export (app-adjacent sites)

Marketing pages that share code/design-system with a Next.js product. `output: 'export'`, no server features on those routes, same SEO checklist. Never mix server actions into static pages "temporarily" — that is how a landing page becomes an app server.

## Simple alternatives (small, honest sites)

- **11ty / Hugo:** fine for blogs and docs when the team knows them. No shame in boring.
- **No-build HTML:** fine for a single coming-soon page. Add a build tool the day you repeat yourself twice.

## CMS decision

- Markdown/MDX in git while the editors are technical. Reviewable, diffable, free.
- Headless CMS (or hosted MDX platform) when non-technical editors publish weekly. The trigger is editor pain, not feature lists.
- Never build a custom CMS for a marketing site. That project has no end.

## Forms, search, newsletters (services, not backends)

- Contact/quote forms: a form endpoint service with spam protection + a success page (analytics event on submit). `mailto:` links are a fallback, never the only path.
- Search: client-side index (Pagefind or equivalent) under ~1k pages; hosted search above that.
- Newsletter: an email provider's embed + double opt-in. No hand-rolled subscriber database.

## Hosting

Static hosts with preview deploys (Cloudflare Pages, Netlify, Vercel, GitHub Pages): push-to-preview on PRs, instant rollback, custom domain + TLS handled. One command or one merge to publish — deployment steps beyond that are a smell for a content site.

## Anti-recommendations

- Do not start a marketing site as a Vite SPA (no SSR/SSG out of the box — crawlers and social cards suffer).
- Do not add auth, a database, or an admin panel "for later". That is a web app wearing a landing page costume — use `web-app-development`.
- Do not install three animation libraries for a hero section (see `frontend-excellence` eval 8 for the full sermon).
