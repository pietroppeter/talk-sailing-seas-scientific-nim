# Build, CI and publishing

Status: accepted · Updated 2026-11-24

## Context

Pietro builds the talk on his laptop, sometimes on a train with a poor connection, and coding agents build it in cloud sandboxes where some hosts are blocked. Conference wifi can fail. Every page should build with one command and work offline.

## Decision

- **One command** (Pietro, 2026-11-24): `nim r build.nim` builds every page into `docs/`, or a group (`slides`, `deepdives`, `devlog`, `themes`, `check`). Slides, deep dives, talk log and the site index are one program, `all.nim` (one compile, about 30 seconds instead of 100), after the all.nim trick of tabelline and nanuq; each theme is a compile of its own. Deep dives and talk log posts are found by file name.
- **Offline**: no page loads anything from the network. reveal.js, KaTeX, p5.js, highlight.js and its styles, water.css, nimib's assets, plotly.js and the fonts are vendored in `docs/assets/` (`scripts/vendor-assets.sh`, `scripts/vendor-fonts.sh`); pages call `nb.usePage` (`offline.nim` rewrites nimib's head to the local copies).
- **Checks**, run by every build: nothing loaded from another site, no broken link between pages, no `nbRawHtml` in a page.
- **Pinned dependencies** (Pietro, 2026-11-24): atlas, with every dependency at a commit in `atlas.lock`, replayed with `atlas rep atlas.lock` locally and in CI; `deps/atlas.config` overrides the webview package (nim-plotly and ggplotnim need different ones) and a gitlab mirror.
- **Published on GitHub Pages** by CI (`.github/workflows/pages.yml`, on ubuntu-24.04, which still has libpcre3): every PR builds, every push to `main` deploys `docs/`. Generated HTML is not committed. The site root lists everything; the deck is `slides.html`.
- **Nim in sandboxes**: nim-lang.org downloads may be blocked, so `scripts/install-nim.sh` builds Nim from source when it is missing.

## Options considered

- A shell script calling `nim r` once per page: one compile per page, about 100 seconds.
- `atlas install` without a lock: the dependencies drift between machines.

## Consequences

- A new page that forgets `nb.usePage`, or links a CDN, fails the build.
- `docs/assets/` is about 5 MB, mostly plotly.js.
- atlas in some setups writes host-suffixed folders into `nim.cfg`: never commit them (see AGENTS.md).

## History

- 2026-10-26: Pages, `docs/`, vendored reveal.js and KaTeX (PR #6); `scripts/install-nim.sh` (PR #4).
- 2026-11-24: every page offline (PR #29); `build.nim` and `all.nim` (PR #30); link check, pinned dependencies, site index. Moved from the OpenSpec slides-tooling spec and the un-archived change offline-builds to this record.
