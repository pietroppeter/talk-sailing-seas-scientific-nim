# Working on the talk

Notes for coding agents (and people) changing this repository. What the talk says and why is in `openspec/` (specs, the living outline, background notes); how the repository is laid out and built is in README.md. This file holds the working rules that are easy to miss.

## The repository is public

Everything committed (code, specs, notes, commit messages, PR descriptions) is public. Keep private notes, personal details and drafts not meant to be published out of it.

## Setup and build

- Dependencies are pinned in `atlas.lock`: `atlas rep atlas.lock` clones them into `deps/` (not committed), and `nim.cfg` (committed) puts them on the path. Never commit a `nim.cfg` that atlas rewrote with host-suffixed folders (`deps/tabelline.pietroppeter.github.com`): use plain names, as in `atlas.lock`. To change a dependency, see README.md (Setup).
- Runtime libraries: libpcre3 (nimib's markdown), libcairo2 (ggplotnim), libblas3 and liblapack3 (Arraymancer). On Debian/Ubuntu run `apt-get update` first. In a sandbox without Nim, `scripts/install-nim.sh` builds it.
- `nim r build.nim` builds every page into `docs/` and runs the checks; `nim r build.nim slides|deepdives|devlog|themes|check` builds one group. Slides, deep dives, talk log and the site index are one compile (`all.nim`), about 30 seconds. A single page still builds on its own (`nim r deepdive/operators.nim`).
- The checks fail when a page loads anything from the network (vendor it in `docs/assets/` with `scripts/vendor-assets.sh`), when a link between pages is broken, or when a page uses `nbRawHtml`. Keep them green.
- Generated HTML is not committed: CI (`.github/workflows/pages.yml`) builds on every PR and deploys `docs/` from `main`.

## Pages

- The site: `index.nim` (docs/index.html) lists everything; the deck is `deck.nim` (docs/slides.html), its slides are in `slides/`; deep dives in `deepdive/`; the talk log in `devlog/`.
- Every nimib page that is not a deck starts, after `nbInit`, with `nb.usePage(ownSource)` (`page.nim`: local assets, the talk's style, the review mode, Show Source), or `nb.useDeepDive(slug, ownSource)` for a deep dive, `nb.useDevlogPost(slug, ownSource)` for a talk log post.
- **Blocks, not HTML.** A page is Markdown in `nbText`, nimib's blocks and the blocks of `blocks.nim`. No HTML, CSS or colours in a page: what is needed a second time becomes a block in `blocks.nim`, its CSS goes in `talkstyle.nim` (pages) or `my.nim` (slides), using the tokens. The nimib-blocks skill (enabled in `.claude/settings.json`) has the details.
- A new deep dive: add it to `deepdive/deepdive.nim`, create `deepdive/<slug>.nim`, link it from its slide as `deepdive/<slug>.html`. A new talk log post: add it to `devlog/devlog.nim`. `all.nim` finds both; the indexes check that every listed page was built.
- Avoid module names that clash with a dependency's (`units`, `penguins`).
- Text inside `nbText` strings is wrapped at about 60 characters, so Show Source needs no horizontal scrolling; never start a wrapped line with `* ` or `- ` (Markdown reads it as a list). Markdown files (`.md`) are not hard-wrapped: one line per paragraph or bullet.
- No live demos in the talk: examples are code and output rendered by nimib when the page is built.

## Showing the work

- Every change to a page or a slide is shown rendered: build it and take screenshots (Playwright and Chromium; `scripts/screenshot.sh docs/slides.html <dir>` for slides). Check pages at 390px wide too.
- A review export pasted in the chat (`format: nimib-review/...`) comes from a page's review mode: apply it with the `nimib-review` skill (`.claude/skills/nimib-review`).

## Changes

- One PR per concern.
- Open decisions and loose ends go in `OPEN-POINTS.md`, the one list of them.
- Deviations from the submitted abstract go in README.md, "Changes from the submitted abstract"; the abstract itself stays verbatim.
