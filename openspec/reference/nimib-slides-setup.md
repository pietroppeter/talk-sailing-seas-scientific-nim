# Jumpstarting a nimib + nimiSlides talk

Context gathered on 2026-10-04 from Pietro's past talk repos, to bootstrap the slides for "Sailing Seas of Scientific Nim" (Compute Paris 2026). Updated 2026-10-26 for publishing on GitHub Pages (PR #6).

## Current setup (this repo)

- nimib 0.4.1 + nimiSlides 0.4.0 on Nim 2.2.12, dependencies with atlas (PR #5).
- Main files at the repo root (`index.nim`, `my.nim`, `nimib.toml`, `nim.cfg`, `.nimble`), individual slide files in `slides/`.
- Outputs go to `docs/`: `nimib.toml` sets `homeDir = "docs"`, so `nim r index.nim` writes `docs/index.html` and `nim r my.nim` writes `docs/my.html`. Images live in `docs/images/`.
- Generated html is not committed (`docs/*.html` is gitignored). The `pages` GitHub Actions workflow builds both decks and deploys `docs/` to GitHub Pages on every push to `main`; PRs only build. Pages source must be set to "GitHub Actions" in the repo settings.
- No CDNs: reveal.js 5.0.4 and KaTeX 0.16.47 are vendored in `docs/assets/` (committed, refreshed with `scripts/vendor-assets.sh`), and `my.nim` overrides nimiSlides' `revealCSS`/`revealJS` partials and the KaTeX path to use them. The deck works offline (good for flaky conference wifi).
- CI runs on `ubuntu-24.04` because newer runner images no longer ship `libpcre3`, which nim-markdown loads at runtime.
- Previews: `scripts/screenshot.sh docs/index.html <outdir>` renders each slide to png with headless Chromium.

## Past talk repos (newest first)

| repo | when | notes |
|---|---|---|
| [hola-talk](https://github.com/pietroppeter/hola-talk) | Nov 2025 | atlas, `slides/my.nim`, `slides/index.nim`, AgileLab theme + logo |
| [ai-a-blast-from-the-past](https://github.com/pietroppeter/ai-a-blast-from-the-past) | Apr 2025 | single `index.nim`, no my.nim, heavy use of `speakerNote`; added `.nojekyll` to speed up Pages deploy |
| [nim-for-pythonistas](https://github.com/pietroppeter/nim-for-pythonistas) | 2023–Feb 2025 | multi-file talk (one module per section), `fosdem/` subfolder for a re-delivery, `.gitignore` has `*.html` (html added explicitly) |
| [domain-driven-data-science](https://github.com/pietroppeter/domain-driven-data-science) | Nov 2024 | same `my.nim` as hola-talk, one module per section imported by `index.nim` |
| [nimib-land/nimconf24](https://github.com/nimib-land/nimconf24) | Oct 2024 | uses `our.nim` (shared helper for the NimibLand talk) |
| [nimiSlides docsrc/nimconf2026.nim](https://github.com/HugoGranstrom/nimiSlides/blob/main/docsrc/nimconf2026.nim) | Jul 2026 | not Pietro's, but the best reference for nimiSlides on nimib 0.4 (custom blocks with `newNbBlock`) |

`regex-is-ai-change-my-mind` (Apr 2026) only has title and abstract so far.

Past talks committed the generated html and served the default branch root with GitHub Pages, with no CI (e.g. https://pietroppeter.github.io/nim-for-pythonistas/). This talk switched to a CI build into `docs/` (see above).

## What my.nim provides

Ported from hola-talk (identical to domain-driven-data-science):

- AgileLab palette constants: `agileLightBlue #02A4BD`, `agileDarkBlue #0e1f53`, `agileWhite`, `witboostOrange #ee961a`, plus `softWhite #F7F7F4` used as background.
- `agileTheme()`: `setSlidesTheme(White)` + CSS variables (off-white background, dark blue text, light blue links), left-aligned lists, `strong` in light blue / `em` in orange (bold, non-italic).
- `nbTextSmall` (text wrapped in `<small>`) and `reference` (alias, used for the repo link on the title slide).
- `nbImg(url, width, caption, alt)`: image block with explicit width.
- `myInit(sourceFileRel)`: `nbInit(theme=revealTheme)`, the LaTeX workaround, vendored reveal.js/KaTeX, theme, and the AgileLab logo fixed bottom-right.
- `testSlide` + `when isMainModule` so `my.nim` renders a style-check deck.

Talk modules follow the pattern: `template xxxSlide* = slide: ...`, then `template presentation* = titleSlide; ...` and `when isMainModule: myInit("index.nim"); presentation; nbSave`. Bigger talks put each section in its own module imported by `index.nim`.

## Porting notes from nimib 0.3 to 0.4

nimib 0.4.0/0.4.1 (May–June 2026) rewrote the block/rendering backend (no more mustache), and nimiSlides 0.4.0 (July 2026) requires `nimib >= 0.4.1`. hola-talk's `my.nim` used 0.3 APIs and had to be ported.

- Unchanged: `nbInit(theme = revealTheme)`, `setSlidesTheme`, `nb.addStyle`, `nbText`, `nbRawHtml`, `slide`, `speakerNote`, `columns`/`column`, `fragment*`, `animateCode`, `cornerImage`, `footer`.
- Custom blocks use `newNbBlock` (e.g. `newNbBlock(NbTextSmall of NbText)`); `addNbTextSmall` / `addNbImg` registration is gone.
- `nb.partials[...]` → `nb.backend.partials[...]`, and partials are Nim funcs `(blk: JsonNode, nb: Nb): string` instead of strings.
- Logo: the `document` partial no longer exists; override `nb.backend.funcs["NbDoc"]` with a copy of `revealNbDocToHtml` that appends the logo div.
- `import nimiSlides` needs that exact casing: `import nimislides` fails on Linux.
- Template params can't share names with block fields: `url` vs `blk.url` breaks `nbImg`.
- nim-markdown needs `libpcre.so.3` at runtime.
- **Known issue:** LaTeX doesn't load out of the box. `useLatex` stores an html string, but nimiSlides 0.4 checks it with `getBool`. `my.nim` works around it: it sets `context["latex"] = true` and adds `RevealMath.KaTeX` to the reveal plugins.
- nimiSlides' own `[nimislides] localReveal = "path"` option was not used for local assets: it writes an absolute filesystem path into the html, which breaks on Pages.
- Cloud env: nim-lang.org and cdnjs are blocked; `scripts/install-nim.sh` builds Nim from git source there (`build_all.sh` also builds atlas), and uses the nim-lang.org tarball in CI.

## Decisions (Pietro)

- Theme: keep the AgileLab logo and colors (2026-10-04).
- Layout: main files at the repo root, individual slide files in `slides/` (2026-10-04).
- Tooling: atlas again (2026-10-04).
- LaTeX: workaround in my.nim for now (2026-10-04).
- Publishing: CI builds into `docs/` and deploys to GitHub Pages, assets vendored locally, no html committed (2026-10-26).
