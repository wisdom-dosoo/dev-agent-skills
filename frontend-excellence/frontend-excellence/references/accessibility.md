# Accessibility (WCAG 2.2 AA target)

Automated checks catch ~30% of issues. The keyboard + reader pass below is the other 70%.

## Non-negotiables (script-enforced)

- `lang` on `<html>`, unique `<title>` per page, `viewport` meta. Missing any of these fails the static check.
- Every `img` has `alt`: descriptive for content, empty (`alt=""`) only for decorative. No exceptions, no "TODO alt".
- Form inputs have associated `label`s (visible preferred; `aria-label` only when the design truly has no room). Errors announced via `aria-describedby`/`aria-live`, not color alone.

## Keyboard pass (manual, every interactive page)

1. Unplug the mouse. Tab through everything: logical order, nothing skipped, nothing trapped, skip-link first.
2. Every control activates with Enter/Space; menus and dialogs follow APG patterns (Escape closes, focus returns to the trigger).
3. Focus is always visible (never `outline: none` without a replacement). Focus never disappears into `body` after a dialog closes or a list updates.

## Screen-reader pass (manual, critical flows)

- Landmarks (`header/nav/main/footer`) and one `h1` per page; headings nest without skipping levels.
- Live regions (`aria-live="polite"`) for async updates: form errors, cart counts, toast confirmations. Silent UI updates are invisible updates.
- Tables use `th` + `scope`; data never conveyed by color alone (contrast ≥ 4.5:1 text, 3:1 large/UI).

## Motion and preference

- Honor `prefers-reduced-motion`: disable parallax, autoplay, and non-essential animation. No autoplaying video with sound, ever.
- Touch targets ≥ 24×24 CSS px (44 recommended); content usable at 200% zoom and 320px width.

## Lock-in

- `eslint-plugin-jsx-a11y` (or equivalent) in CI with zero warnings on new code.
- A manual keyboard pass is part of the definition of done for every interactive change — state in the PR what was covered.
