# Deep dives

Status: accepted · Updated 2026-11-24

## Context

Slides have little room for code and the talk is shallow by design ([tone.md](tone.md)), but some examples and stories deserve more, for people who want to explore further.

## Decision

- **A deep dive for what the slides only sketch** (Pietro, 2026-10-27): a nimib page, more thorough than the slide, linked from it, with code that runs when the page is built. Pietro likes the word "explainer" too; the pages are called deep dives since 2026-11-24 and could go back.
- **The folder** (Pietro, 2026-11-24): `deepdive/<slug>.nim` builds `docs/deepdive/<slug>.html`; the list is `deepdive/deepdive.nim`, shown by `deepdive/index.nim` and the site index. A deep dive starts with `nb.useDeepDive(slug, ownSource)`, which adds a header back to the list and the slides.
- **Today**: beyond_science, brentp, vindaar, qex (Island 2), penguins_data_stack (Island 3), operators, units_macros (Island 5), thank_you_sketch (Thank you). Short names, since they are public URLs (Pietro).
- **Offline and reviewable** like every page ([build-ci.md](build-ci.md), [review.md](review.md)).

## Options considered

- Longer code on the slides, or links to the source on GitHub.
- An explainer only in the README or a blog post.
- Keeping the pages next to the slides (`slides/*_explainer.nim`): slides and pages were mixed.

## Consequences

- A new code-heavy slide asks for a deep dive (tracked in [OPEN-POINTS.md](../OPEN-POINTS.md)).
- `thank_you_sketch` quotes the Thank You slide's code, so it is CC BY-NC-SA 3.0 like it.

## History

- 2026-10-26: first explainer, the Thank You slide (PR #14).
- 2026-10-27: explainers as a principle; operators and units (PR #17), Island 2 stories (PR #19), penguins (PR #20).
- 2026-10-28: QEX (PR #25).
- 2026-11-24: moved to `deepdive/` and renamed deep dives; this record created.
