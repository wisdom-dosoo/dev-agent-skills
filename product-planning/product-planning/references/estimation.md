# Estimation

## Ranges, not dates

All estimates are ranges with a confidence note: "3–5 days (medium confidence; drops to high once the auth spike lands)." Single numbers are lies with good formatting. Never commit to a calendar date for work with unresolved unknowns — commit to a *date for re-estimation* after the spike instead.

## Sizing scale

- Use t-shirt sizes for roadmap horizons (S < 1 week, M 1–2 weeks, L 3–6 weeks, XL = split it, you have no idea).
- Use days (ranges) only for the next 1–2 weeks of sequenced work. Anything estimated in days beyond that horizon is fiction.
- Re-estimate when scope changes. An estimate is a function of a specific scope doc version; scope drift voids it — say so explicitly.

## Handling unknowns

- Unknown → time-boxed spike (1–2 days) with a concrete question ("can library X handle 10k rows?"), not padding. Padding hides risk; spikes retire it.
- Name the top 3 risks with (likelihood × impact) in one line each, plus the spike or decision that retires each.
- External dependencies (approvals, third-party APIs, app-store review) get their own line with owner and latest-acceptable date. They slip more often than code does.

## What to say when pressed for a date

"At current scope: 4–7 weeks (low-medium confidence). To get to high confidence we need: the auth decision (ADR) and one design review. If you need a hard date, tell me the date and I will tell you what scope fits it." Date-driven scoping is legitimate — scope flexes, quality does not.
