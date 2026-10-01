# Current state snapshot

**Snapshot date: 2026-09-30.** Refresh monthly, and always re-check anything marked VERIFY or SECURITY before it drives a decision.

## SECURITY: check these live every time
- **Next.js:** scheduled security release **2026-09-30** fixes nine vulnerabilities (1 critical, 2 high, 5 medium, 1 low). Official post names patched lines **16.3.8** and **15.5.27** (16.3.7, published 09-29, is a bug-fix release WITHOUT these fixes; some third-party posts wrongly say 16.3.7). Also: out-of-band release 2026-09-22 (16.3.6 / 15.5.26) fixed a critical RCE in the Node.js `ImageResponse` (`next/og`) for versions >=16.2.0 <16.3.6 (GHSA-vcvr-r3jv-pc5j). Edge ImageResponse was not affected. August release was 16.3.3 / 15.5.24. Source: nextjs.org/blog.
- **Express ecosystem:** middleware CVEs land roughly monthly. Minimums as of Aug 31, 2026: multer >= 2.3.0 (three High CVEs), morgan >= 1.12.0, hbs >= 4.3.0, multiparty >= 4.3.0. Express blog also lists a Sept 9 security post: read it. Source: expressjs.com/en/blog.
- Django: check djangoproject.com/weblog/ for the monthly security releases.

## Runtimes
- **Node.js:** 24 (Krypton) is Active LTS, latest 24.21.0. **26 is Current (26.10.0) and enters LTS 2026-10-28**. 22 is Maintenance LTS. From Node 27 on: one major per year (April), every release becomes LTS. Use 24 in production today; move to 26 after 10-28. Source: nodejs.org/en/about/previous-releases, endoflife.date/nodejs.
- **Python:** 3.14 is the stable line. **3.15.0 final is scheduled for 2026-10-01** (RC2 shipped 09-01). Free-threaded build is supported since 3.14 but still a separate opt-in build. Django 6.1 officially supports 3.12 to 3.14 only, so stay on 3.14 for Django until Django announces 3.15 support.

## JavaScript frontend/tooling
- **React 19.3.0** released 2026-09-09 (19.2.x before it). React Compiler 1.0 is stable.
- **TypeScript 7.0** (native Go compiler, ~8-12x faster full builds) is stable since Aug 2026. It ships **no programmatic API until 7.1**: tools such as typescript-eslint need the `@typescript/typescript6` side-by-side package. Reported breakage: `moduleResolution: node10` and `esModuleInterop: false` are removed. Code that compiles clean on 6.0 should compile the same on 7.0.
- **Vite 8.3.1** (2026-09-24). Requires a modern Sass compiler API if you use Sass.
- **Next.js 16.3** line: 16 is the supported LTS line, 15.5.x is Maintenance LTS. 16.3 (Aug 2026) added Instant Navigations.

## Backend frameworks
- **Express 5.2.1** is latest 5.x (Dec 2025); Express 4 still gets fixes (4.22.3 on 2026-09-14). No Express 6 exists in endoflife.date as of 2026-09-15; ignore blog posts that claim one.
- **Mongoose 9** is the current major (released 2025-11-21). VERIFY the latest 9.x on npm.
- **Django 6.1.1** (2026-09-02); 6.1 released 2026-08-05 (adds model-field "fetch modes"). 6.0 lost mainstream support 2026-08-04, security fixes to April 2027. 5.2 is the LTS line. Django moves to an annual release cycle in January 2028 (DEP 20).
- **FastAPI 0.141.1** (2026-07-29, per third-party tracker; VERIFY on PyPI). Still 0.x with multiple releases a month: always pin an exact version.
- **Flask 3.1.3** (Feb 2026).

## Databases
- **PostgreSQL 18.6** is current stable (2026-08-13), supported to Nov 2030. **PostgreSQL 19 is in beta (Beta 4, 2026-09-24)**; release candidate expected early October, GA likely later in October. Six features were reverted in Beta 4 (including SQL/PGQ graph queries). JIT is disabled by default in 19. Do not use 19 in production before GA.
- **MongoDB 8.3** (2026-06-03; 8.3.11 on 2026-09-11) and **8.0** are supported. **8.2 security support ended 2026-07-31**: do not pin `mongo:8.2`. MongoDB's lifecycle page lists a **9.0** for September 2026, but I could not confirm GA notes: VERIFY before recommending it. 7.0 end-of-life dates conflict between sources (2026-08-31 vs 2027-08-31): VERIFY.

## Changelog

- 2026-09-30: snapshot created (Next.js 16.3.8/15.5.27 pending 09-30, Node 24 LTS, Django 6.1.1, PG 18.6 / PG 19 beta, Mongo 8.3/8.0).
- 2026-10-01: preflight hardened (browser-secret FAIL, NoSQL/plaintext-password WARNs, helmet/rate-limit WARNs, Flask checks); thresholds unchanged.
- Next review due: 2026-10-30. Refresh SECURITY sections first; CI fails past 60 days stale.
