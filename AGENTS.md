# Working on the talk

Notes for coding agents (and people) changing this repository. What the talk says and why is in `decisions/` (one decision record per domain), the plan of the talk in `outline.md`, background notes in `notes/`; how the repository is laid out and built is in README.md. This file holds the working rules that are easy to miss.

## The repository is public

Everything committed (code, specs, notes, commit messages, PR descriptions) is public. Keep private notes, personal details and drafts not meant to be published out of it.

## Setup and build

- Dependencies are pinned in `atlas.lock`: `atlas rep atlas.lock` clones them into `deps/` (not committed), and `nim.cfg` (committed) puts them on the path. Never commit a `nim.cfg` that atlas rewrote with host-suffixed folders (`deps/tabelline.pietroppeter.github.com`): use plain names, as in `atlas.lock`. To change a dependency, see README.md (Setup).
- Runtime libraries: libpcre3 (nimib's markdown), libcairo2 (ggplotnim), libblas3 and liblapack3 (Arraymancer). On Debian/Ubuntu run `apt-get update` first. In a sandbox without Nim, `scripts/install-nim.sh` builds it.
- `nim r build.nim` builds every page into `docs/` and runs the checks; `nim r build.nim slides|deepdives|devlog|themes|check` builds one group. Slides, deep dives, talk log and the site index are one compile (`all.nim`), about 30 seconds. A single page still builds on its own (`nim r deepdive/operators.nim`).
- The checks fail when a page loads anything from the network (vendor it in `docs/assets/` with `scripts/vendor-assets.sh`), when a link between pages is broken, when a page uses `nbRawHtml`, or (in CI) when a `#>` note for Claude is left. Keep them green.
- Generated HTML is not committed: CI (`.github/workflows/pages.yml`) builds on every PR and deploys `docs/` from `main`.

## Pages

- The site: `index.nim` (docs/index.html) lists everything; the deck is `deck.nim` (docs/slides.html), its slides are in `slides/`; deep dives in `deepdive/`; the talk log in `devlog/`.
- The names of the islands are in `islandnames.nim`, the one place to rename one (the map slides, the agenda bar, the deep dives' labels and the map tools read them from there).
- **One template per slide.** Every slide of the deck is a template of its own (`mainlandSlide`, `island3RocksSlide`: exported, with names unique across the deck). Each module of `slides/` has one template listing its slides in order (`introSection`, ...), and `deck.nim` lists the parts: reorder there, nowhere else. Each module ends with `when isMainModule: buildDeckPart(...)` (`my.nim`), which builds its part on its own; a new module adds itself to `deckParts` in `build.nim`.
- Every nimib page that is not a deck starts, after `nbInit`, with `nb.usePage(ownSource)` (`page.nim`: local assets, the talk's style, the review mode, Show Source), or `nb.useDeepDive(slug, ownSource)` for a deep dive, `nb.useDevlogPost(slug, ownSource)` for a talk log post.
- **Blocks, not HTML.** A page is Markdown in `nbText`, nimib's blocks and the blocks of `blocks.nim`. No HTML, CSS or colours in a page: what is needed a second time becomes a block in `blocks.nim`, its CSS goes in `talkstyle.nim` (pages) or `my.nim` (slides), using the tokens. The nimib-blocks skill (enabled in `.claude/settings.json`) has the details.
- A new deep dive: add it to `deepdive/deepdive.nim`, create `deepdive/<slug>.nim`, link it from its slide as `deepdive/<slug>.html`. A new talk log post: add it to `devlog/devlog.nim`. `all.nim` finds both; the indexes check that every listed page was built.
- Speaker notes are also the text of the blog post (`blog.nim`, `docs/blog.html`): write them so they read as prose too, or mark them `speakerNote("...", blog = false)`; `blogNote` is text for the blog post only. A module that calls `speakerNote` (or expands slides that do) imports `nimiSlides except speakerNote`: `blogpost.nim` has its own, exported by `my.nim`.
- Avoid module names that clash with a dependency's (`units`, `penguins`).
- Text inside `nbText` strings is wrapped at about 60 characters, so Show Source needs no horizontal scrolling; never start a wrapped line with `* ` or `- ` (Markdown reads it as a list). Markdown files (`.md`) are not hard-wrapped: one line per paragraph or bullet.
- No live demos in the talk: examples are code and output rendered by nimib when the page is built.

## Showing the work

- To show one island, build only its part of the deck: `nim r build.nim island1` (or `nim r slides/island1_performance.nim`: every module of `slides/` builds its part with `when isMainModule`) writes `docs/slides_island1.html` in the deck's look. Publish it, or a deep dive, as a claude.ai artifact: `python3 scripts/bundle-page.py docs/slides_island1.html /mnt/user-data/outputs/island1` copies the page and the files it loads and prints the files list for `publish_files` (which only takes files under `/mnt/user-data/outputs`). Republish to the same artifact when the page changes; attach few screenshots and no raw HTML.
- Every change to a page or a slide is shown rendered: build it and take screenshots (Playwright and Chromium; `scripts/screenshot.sh docs/slides.html <dir>` for slides). Check pages at 390px wide too.
- A review export pasted in the chat (`format: nimib-review/...`) comes from a page's review mode: apply it with the `nimib-review` skill (`.claude/skills/nimib-review`).

## Changes

- One PR per concern.
- A change that changes a decision updates its record in `decisions/` in the same PR: the bullet under Decision, and a line in History (see `decisions/README.md`). A change to sections, slides or timing updates `outline.md`. Records are updated in place, not added per decision.
- Open decisions and loose ends go in `OPEN-POINTS.md`, the one list of them.
- Deviations from the submitted abstract go in README.md, "Changes from the submitted abstract"; the abstract itself stays verbatim.

## The local-changes branch and notes for Claude

- Pietro keeps a long-lived `local-changes` branch, pushed from his laptop when he has a connection. Each push becomes a PR into `main` with his commits unchanged, plus a commit on top that handles the notes. Merge it with a merge commit, never squash or rebase, so that `git rebase origin/main` on `local-changes` replays only what is new.
- The remote `local-changes` follows `main`: after every push to `main`, `.github/workflows/local-changes.yml` fast-forwards it when it has no commit of its own (once its batch PR is merged). Pietro updates his copy with `git pull --rebase`.
- A note for Claude is a run of lines starting (after indentation) with `#>`, the first one `#> Claude: ...`. It works the same in Nim code, inside `nbText` strings and in `.md` files (`#>` is not a Markdown heading). Do what it asks, then delete the whole note.
- No note reaches `main`: the build lists any line starting with `#>` and fails on it in CI (`build.nim`, `noAgentNotes`). Never start a line with `#>` for anything else.
