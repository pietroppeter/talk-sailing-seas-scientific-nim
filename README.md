# Sailing Seas of Scientific Nim

Talk by Pietro Peterlongo at Compute Paris 2026 (end of November 2026).

Slides: https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/

Slides are made with [nimib](https://github.com/pietroppeter/nimib) and [nimiSlides](https://github.com/HugoGranstrom/nimiSlides):

- `index.nim`: the presentation, it imports the slides from `slides/`
- `my.nim`: helpers and AgileLab theme; run it directly for a style test deck
- `slides/`: one file per slide (or group of slides)
- `openspec/`: the talk is prepared with [OpenSpec](https://github.com/Fission-AI/OpenSpec) (see below)

## setup

Dependencies are managed with atlas (requires Nim >= 2.0, e.g. installed with grabnim):

```
atlas install
nim r index.nim   # writes docs/index.html
nim r my.nim      # style test deck, writes docs/my.html
```

Outputs go to `docs/` (set by `homeDir` in `nimib.toml`), which is what gets published on GitHub Pages: the `pages` workflow builds the slides on every push to `main` and deploys `docs/`. Generated html is not committed.

reveal.js and KaTeX are not loaded from CDNs: local copies live in `docs/assets/` (committed) and `my.nim` points the slides to them, so the deck also works offline. `scripts/vendor-assets.sh` downloads them again (change versions there). Images go in `docs/images/`.

nim-markdown needs PCRE at runtime (`libpcre.so.3`, e.g. `apt install libpcre3`).

`scripts/screenshot.sh docs/index.html shots/` renders each slide to a png with headless Chromium.

## OpenSpec

The talk is prepared with spec-driven development using [OpenSpec](https://github.com/Fission-AI/OpenSpec) and a custom `talk` workflow schema:

- `openspec/specs/`: the talk's source of truth (abstract as submitted, audience, format and slot, slides tooling)
- `openspec/changes/`: iterations of the talk in progress, each with proposal → specs (deltas) → outline (sections and slides) → tasks
- `openspec/schemas/talk/`: the custom schema and its templates
- `openspec/reference/`: background notes (conference, slides setup, references)

Install the CLI with `npm install -g @fission-ai/openspec` (cloud sessions do this in a SessionStart hook). In Claude Code: `/opsx:explore`, `/opsx:propose <idea>`, `/opsx:apply`, `/opsx:archive`.
