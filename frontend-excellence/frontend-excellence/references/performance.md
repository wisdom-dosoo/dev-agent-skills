# Performance

## Budgets (mobile, throttled 4G — enforce in CI)

| Metric | Budget |
|---|---|
| LCP (largest paint) | < 2.5 s |
| INP (interaction latency) | < 200 ms |
| CLS (layout shift) | < 0.1 |
| Total JS transferred | < 200 KB (landing), < 350 KB (app) |
| Lighthouse performance | ≥ 90 on key pages |

Blow the budget → shrink or justify in the PR. Budgets ratchet down, never up without a reason.

## Fix order (biggest pain per effort)

1. **Images (usually 50%+ of bytes):** modern formats (AVIF/WebP with fallback), responsive `srcset`/`sizes`, explicit `width`/`height` (kills CLS), lazy-load below the fold, never ship a 4K source to a 400px slot.
2. **JS weight:** code-split by route, defer non-critical hydration, kill duplicate dependencies (`npm why <pkg>`), tree-shake icons/locales. Framework first, then your code — measure the bundle breakdown before editing.
3. **Fonts:** `font-display: swap`, subset to used glyphs, self-host (no render-blocking third-party CSS), at most 2 families.
4. **Render path:** inline critical CSS, `defer` scripts, `preconnect` to unavoidable origins, streaming SSR (`loading.tsx`/suspense boundaries) for Next.js. Test with `next build && next start`, never dev mode.
5. **Caching:** immutable hashes on static assets (1-year cache), short TTL on HTML, CDN in front of public pages. Verify with response headers, not assumptions.

## React-specific

- React Compiler 1.0 is stable: enable via preset, then remove manual memoization gradually — never mass-delete in the same commit as enablement.
- Data fetching via a cache (TanStack Query / route cache), not per-render fetches. Waterfalls show up in traces; fix the request graph, not the spinner.
- Virtualize lists over ~100 rows; paginate over ~1,000. Rendering 10k DOM nodes is not a framework bug.

## What NOT to do

- Do not micro-optimize unmeasured code. Profile → fix the top frame → re-measure.
- Do not add a second framework, animation library, or icon set to fix a weight problem.
- Do not lazy-load LCP content (hero image, headline font). Lazy loading the thing the metric measures is self-sabotage.
