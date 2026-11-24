# Slides

Status: accepted · Updated 2026-11-24

## Context

The deck is code, built with the tools the talk is partly about, and must be reviewable from screenshots and work offline on the day. Pietro's earlier talks (see [notes/nimib-slides-setup.md](../notes/nimib-slides-setup.md)) set the starting point.

## Decision

- **nimib + nimiSlides.** Slides are Nim, with nimib 0.4.3 and nimiSlides 0.4.0 (reveal.js), on Nim 2.2. `deck.nim` builds the deck (`docs/slides.html`) from one file per section in `slides/`; `my.nim` holds the theme, the layout helpers and the style test deck (`docs/my.html`).
- **Branding.** The AgileLab theme of `my.nim`: off-white background, AgileLab colours, the AgileLab logo fixed bottom-left (bottom-right clashes with reveal's arrows, Pietro rejected it).
- **Two accents for emphasis** (Pietro, 2026-11-24): `*emphasis*` is orange, for personal and Nim things (his name, Nim, nimib); `**strong**` is AgileLab teal, for work and AgileLab. Slides use both. A second `##` heading on a slide (About AgileLab under About me) gets more room above it.
- **Quarto's proportions** (Pietro, 2026-11-24: the talk needs more room per slide): the deck takes the sizes and margins of Quarto's reveal.js theme (`deckLook` in `my.nim`): a 1050x700 slide with margin 0.1, slides aligned top-left (the title slide centered), 40px text, 12px between blocks, headings in normal case, code boxes full width with a thin border and up to 500px tall. Colours, logo and code theme stay AgileLab's. Tables stay centered (Pietro). CSS and reveal.js settings only, nothing to vendor. The earlier centered look is built on the side with `-d:deckLook=centered` (`nim r build.nim looks`, `docs/slides_centered.html`).
- **Layouts are helpers tried in the style test deck** (Pietro, 2026-10-26): a layout is a helper in `my.nim` with demo slides in the style test deck, built and screenshotted before talk slides use it. First one: `imageLeftSlide(url, width)`, an image on the left at full height and a fraction of the width (40% by default), cropped not stretched, text on the right; slides adopt it section by section.
- **Light code theme** (Pietro, 2026-10-27): atom-one-light (highlight.js, chosen by `codeTheme` in `my.nim`; github and stackoverflow-light stay vendored), a near-white box on the off-white slides; code output has a light-blue bar on its left.
- **Little code on a slide**: what fits; an example that deserves more gets a deep dive ([deep-dives.md](deep-dives.md)), linked from the slide.
- **Every code block says its language** (Pietro, 2026-11-24): a small tag in its top right corner, "👑 Nim", "🐍 Python" or "🤹 Julia" (Julia has no official emoji; Pietro likes the juggler some have proposed), on a line of its own above the code; CSS only (`codeLanguageCss` in `blocks.nim`, used by `my.nim` and `talkstyle.nim`), so nbCode and nbShowCode get it on slides and pages without changing a slide.
- **Tables with tabelline** (Pietro, 2026-11-07): tables in slides and pages are made with [tabelline](https://github.com/pietroppeter/tabelline) and `nbTable`, not Markdown or HTML; slides use `slideLook` (deck font and colours) and `highlightCols` to point at a column; pages keep tabelline's default look.
- **Animations are p5nim sketches**, compiled to JavaScript by nimib when the deck is built (p5.js vendored); an animation starts from the beginning whenever its slide is shown.
- **Math with KaTeX.** nimiSlides 0.4.0 breaks LaTeX (and the footer, slide numbers, scroll wheel): `my.nim` works around it. An upstream fix is drafted but on hold.
- **Blocks, not HTML** (Pietro, 2026-11-24): slides use nimib's and the talk's blocks (`blocks.nim`), CSS lives in `my.nim`, no `nbRawHtml`.
- **Every slide change is shown rendered** before review: screenshots with `scripts/screenshot.sh docs/slides.html <dir>` or Playwright.

## Options considered

- Images in the flow of the slide with `nbImg` instead of the image-left layout: stays available for small images.
- Code themes: monokai (dark boxes, the previous default), github (keywords and types both red), stackoverflow-light (close to atom-one-light).
- The reveal.js White theme as is (960x700, centered, 42px, upper-case headings): the earlier look, less room on a slide; two slides overflowed.
- Markdown or HTML tables: no units, no source notes, nothing to point the eye.

## Consequences

- The deck can only be checked by building it, so CI builds it on every PR.
- The LaTeX workaround in `my.nim` must go when nimiSlides is fixed.

## History

- 2026-10-04: nimib + nimiSlides with atlas (PR #5).
- 2026-10-26: GitHub Pages and vendored assets (PR #6), image-left layout (PR #10), p5nim (PR #12).
- 2026-10-27: light code theme (PR #18).
- 2026-11-07: tables with tabelline, nimib 0.4.3 (PR #27).
- 2026-11-24: Quarto's proportions (PR #32).
- 2026-11-24: blocks, not HTML; the deck moves to `deck.nim` and `docs/slides.html`. Moved from the OpenSpec slides-tooling spec and the un-archived change tabelline-tables to this record.
- 2026-11-24: two accents for emphasis (orange `*`, teal `**`), room above a second heading.
- 2026-11-24: a language tag on every code block.
