---
name: frontend-excellence
description: Make web frontends fast, accessible, and polished. Covers Core Web Vitals and bundle budgets, image strategy, accessibility (WCAG, keyboard, screen readers), SEO basics, and design-system consistency. Use this skill whenever the user mentions performance, slow page, Core Web Vitals, Lighthouse, bundle size, accessibility, a11y, WCAG, keyboard navigation, screen reader, SEO, responsive, or asks "why is my site slow", even if they only say "the page feels janky" or "Google ranks us low". Not for backend logic or APIs (see stack skills), visual brand design from scratch, or native mobile UI.
---

# Frontend excellence

You own what the user feels: speed, access, polish. Measure with Lighthouse/field data, fix in budget order — biggest user pain per effort first.

## Workflow

1. **Run `scripts/frontend-check.sh`** in the project root for static hygiene (alt text, lang, viewport). Fix FAILs; they are trivial and non-negotiable.
2. **Measure before touching:** Lighthouse (mobile, throttled) + bundle analysis. Record LCP, INP, CLS and the top 3 byte contributors. No optimization without a baseline number.
3. **Apply `references/performance.md`** in budget order: images → JS weight → fonts → render-blocking → caching. Re-measure after each change; keep what moves the number.
4. **Apply `references/accessibility.md`** as a keyboard-and-reader pass: tab order, focus visibility, names/roles, contrast, reduced motion. Automated checks catch ~30% — the manual pass is the skill.
5. **Lock it in:** budgets in CI (bundle size, Lighthouse scores), a11y lint (`eslint-plugin-jsx-a11y` or equivalent), and the residual list (what is still slow/inaccessible and why it is accepted).

## Hard rules

- Every image has `alt` (empty only for decorative), a size to prevent layout shift, and a modern format. An `img` without `alt` is a defect, not a nit.
- Every interactive element is keyboard-reachable with a visible focus state. Click-only `div`s are defects.
- No layout shift from late content: reserve space for images, embeds, and dynamic slots.
- Performance budgets are CI gates (bytes + scores), not wiki aspirations. A PR that blows the budget says why or shrinks.
- State plainly what you did not test (e.g. "no screen-reader pass: no license available", "desktop only").

## Output style

Numbers first (metric → cause → expected gain), then exact code/config. Separate proven wins (measured) from standard practice (unmeasured here). End with the residual list.
