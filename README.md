# Sailing Seas of Scientific Nim

Talk by Pietro Peterlongo at [Compute! Paris 2026](https://compute.events/paris2026/), Thursday 26 November 2026, 14:40-15:10, Room 108 (session "A Babel of Compilers"). In the programme it is titled **Sailing the Seas of Scientific Nim**: [talk page](https://pretalx.com/compute-paris-2026/talk/8EM8ZA/).

Site: https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/ (lists everything: slides, deep dives, talk log). Slides: https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/slides.html

## Abstract

Programming languages used in Scientific Computing have evolved from Fortran to Python, but many languages are still actively used and are important in the ecosystem (C, C++, R). New languages made specifically for solving problems of the scientific ecosystem have been created (Julia). Is there space for one more? Why is Nim, a general purpose statically typed and compiled language, a good fit for Scientific Computing? We will make a quick travel around seven islands that represent important themes where Nim shows its powers. The talk will not hide where Nim falls short.

### Description

Talking about a niche programming language is a bit like traveling to an exotic land, where most people will feel like strangers. That is why, after a brief introduction motivating why there are so many programming languages in the scientific computing ecosystem, the talk will be structured around a quick hop through seven different "islands" that will showcase the unique capability of Nim programming language and its ecosystem.

The talk targets the scientific computing beginner and the ecosystem builder. For the beginner, we aim to have a first introduction to a language that is accessible, fun to play with, and possibly useful in the day to day work (at the very least as a learning tool). The builder should be able to evaluate the pros and cons of building scientific computing tools in Nim. Programming languages enthusiasts and community builders might also find the talk interesting.

The agenda of the talk:

- **Intro**: motivates why there are so many programming languages in scientific computing and that there is still space for more.
- **Accessible Performance without Ceiling** (first island): at a high level, Nim is as easy to write as Python and as fast as C.
- **Success stories** (second island): even with a niche language and in a tiny ecosystem, pioneers have been using Nim successfully in Scientific Computing. A couple of stories to inspire us.
- **Data Stack** (third island): a quick go through the basic building blocks of the ecosystem (tensor library, dataframe library, plotting library) explained with a Data Exploration of the classical penguins dataset.
- **An Expressive Language** (fourth island): two language features that make Nim good for scientific use. Defining custom operators (easy to use feature) and metaprogramming (advanced feature).
- **Interoperability** (fifth island): Nim is easy to interoperate with various languages. It is very easy to wrap existing libraries in C, C++ in case you need them. The ecosystem also provides two way bridges to Python, R, Julia (of varying degrees of maturity). What you build in Nim can be very easily used in Python (almost like Rust).
- **Interactivity** (sixth island): interactivity is very important for scientific computing, we will showcase one of Nim superpowers (compiling to Javascript) using a snappy port of a fun Shiny app. No, interactivity as in a Jupyter or Marimo notebook is not yet there.
- **Notebook** (seventh island): Jupyter showed how central the literate programming/computing paradigm is to scientific computing. An interesting option in Nim ecosystem goes in an unexpected direction.
- **Conclusion**: we touch back land. We give takeaways for beginner and builder and reflect why Nim is still a niche language. A brief and opinionated view about the language, the ecosystem, the community and the governance.

The talk will use examples from the ecosystem to showcase the power of Nim but it will NOT contain a tutorial of the language. This is possible because Nim reads like Python and the examples should be easy enough understand without knowing the language. Of course if you look up a tutorial of the language before the talk you might be in a better position to appreciate it, but it is not a requirement.

## Changes from the submitted abstract

The abstract and description above are kept verbatim as submitted. While preparing the talk, a few things changed:

- The title slide says **Sailing Seas of Scientific Nim**, without "the", so the title fits on one line.
- The islands have short names: **Performance** (for Accessible Performance without Ceiling), **Science** (Success stories), **Ecosystem** (Data Stack) and **Expressivity** (An Expressive Language); Interoperability, Interactivity and Notebook stay.
- **Interoperability** comes before **Expressivity**: Interoperability is the fourth island and Expressivity the fifth.
- The **Ecosystem** island adds a fourth block, display tables (tabelline), a second dataframe library (nanuq, Polars for Nim) and a deep learning example, besides the tensor, dataframe and plotting libraries.

## Slides

Slides are made with [nimib](https://github.com/pietroppeter/nimib) and [nimiSlides](https://github.com/HugoGranstrom/nimiSlides):

- `deck.nim`: the presentation (`docs/slides.html`): the order of its parts, one module of `slides/` each
- `index.nim`: the site index (`docs/index.html`), which lists the slides, the deep dives and the talk log
- `my.nim`: helpers and AgileLab theme; run it directly for a style test deck (deployed with pages: https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/my.html)
- `slides/thank_you.nim`: the animated Thank You slide (a p5nim sketch); run it directly to build the slide on its own (deployed with pages: https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/thank_you.html)
- `deepdive/`: the deep dives, see below
- `themes.nim` and `maps/`: the deck wears the nautical chart theme; two other themes were explored (pirate adventure game, old book of sea tales); `maps/geometry.nim` is the one geometry of the voyage map, drawn by `maps/pixel.nim`, `maps/chart.nim` and `maps/engraved.nim`, with the coasts of real islands from tabelline's islands story (`maps/isole.nim`, © OpenStreetMap contributors, ODbL) and the Gulf of Trieste as the mainland (OpenStreetMap); `nim r build.nim themes` builds the deck in the other themes (`docs/slides_<theme>.html`); `nim r maps/maplab.nim` draws the arrangements of the map and every chart on one page (`docs/maplab.html`); the map editor (`mapeditor.nim`, a page of the site, `docs/mapeditor.html`; the editor itself is Nim compiled to JavaScript, `maps/editor/app.nim`) writes `maps/voyage.json`, the positions of the deck's map
- `devlog/`: the talk log, see below
- `slides/`: one module per part of the deck (title, about, intro, island1 to island7, conclusion, thank you), and the helpers they share. Every slide is a template; each module has a template that lists its slides in order (`introSection`, `island1PerformanceSection`, ...), so reordering slides happens there and reordering parts in `deck.nim`. Each module builds its part on its own with `when isMainModule`: `nim r slides/intro.nim` writes `docs/slides_intro.html`
- `shiny/`: the Shiny for Python app of Island 6 (the plant), which `scripts/shinylive.sh` exports to `docs/shiny/` to run in the browser with shinylive (about 50 MB, not committed; `build.nim` exports it when missing, which needs the network once; deployed with pages: https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/shiny/plant/)
- `decisions/`, `outline.md`, `notes/`: how the talk is prepared (see below)

## Deep dives

A slide has room for little, so a topic the slides only sketch gets a deep dive: a nimib page in `deepdive/`, linked from its slide, whose code runs when the page is built. The list is in `deepdive/deepdive.nim`; `deepdive/index.nim` lists them all (https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/deepdive/).

- [Nim success stories beyond science](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/deepdive/beyond_science.html) (`deepdive/beyond_science.nim`, Island 2)
- [Nim in bioinformatics](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/deepdive/bioinformatics.html) (`deepdive/bioinformatics.nim`, Island 2)
- [Vindaar's thesis in plain words](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/deepdive/vindaar.html) (`deepdive/vindaar.nim`, Island 2)
- [Lattice QCD and QEX in plain words](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/deepdive/qex.html) (`deepdive/qex.nim`, Island 2)
- [Penguins with the Nim data stack](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/deepdive/penguins_data_stack.html) (`deepdive/penguins_data_stack.nim`, Island 3)
- [Penguins with nanuq and tabelline](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/deepdive/penguins_polars.html) (`deepdive/penguins_polars.nim`, Island 3)
- [Interoperability: Nim with other languages](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/deepdive/interoperability.html) (`deepdive/interoperability.nim`, Island 4)
- [Custom operators: points, lines and planes](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/deepdive/operators.html) (`deepdive/operators.nim`, Island 5)
- [Units with unchained](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/deepdive/units_macros.html) (`deepdive/units_macros.nim`, Island 5)
- [A plant in the browser](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/deepdive/plant_app.html) (`deepdive/plant_app.nim`, Island 6)
- [How the Thank You slide works](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/deepdive/thank_you_sketch.html) (`deepdive/thank_you_sketch.nim`, the Thank You slide)

## Talk log

The repository holds the slides of the talk, the deep dives that go deeper into what they only sketch, and a talk log: posts on how the talk evolves, built with nimib from `devlog/` (the list of posts is in `devlog/devlog.nim`). Index: https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/devlog/

- [Setting sail](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/devlog/2026-11-07-setting-sail.html) (7 November 2026): how the talk got from an accepted abstract to a deck with seven islands
- [Dressing the voyage](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/devlog/2026-11-07-dressing-the-voyage.html) (7 November 2026): what Ines Montani teaches about slides, and three themes tried on real slides
- [Drawing the map](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/devlog/2026-11-07-drawing-the-map.html) (7 November 2026): one geometry for the map of the voyage, drawn as pixel art, as a nautical chart and as a hand-drawn chart

## setup

Dependencies are managed with atlas (requires Nim >= 2.0, e.g. installed with grabnim) and pinned in `atlas.lock`: every dependency at the commit the pages were last built with, the same on every machine and in CI:

```
atlas rep atlas.lock
```

To change a dependency: edit the `.nimble` file (or `atlas update <name>`), `atlas install`, build, then `atlas pin` to write the new commits to `atlas.lock`. Check that its `dir` entries and `nim.cfg` keep plain names (`deps/tabelline`, not `deps/tabelline.pietroppeter.github.com`): some atlas setups add the host to a folder name.

[nanuq](https://github.com/pietroppeter/nanuq) (Polars for Nim, Island 3) links a prebuilt static library: the first compile that imports it downloads it from nanuq's GitHub releases (about 64 MB, needs `curl` and `tar`) into `~/.cache/nanuq`.

nim-markdown needs PCRE at runtime (`libpcre.so.3`, e.g. `apt install libpcre3`). ggplotnim needs Cairo (`apt install libcairo2`, or `brew install cairo` on macOS, where `nim.cfg` links it from `/opt/homebrew/lib`).

## Build

`build.nim` builds the pages into `docs/`:

```
nim r build.nim                     # everything, as the pages workflow does
nim r build.nim slides              # the deck (docs/slides.html), the style test deck (docs/my.html), the Thank You slide, the easter egg
nim r build.nim deepdives           # every deepdive/*.nim, then the deep dives index (docs/deepdive/)
nim r build.nim devlog              # every talk log post, then the talk log index (docs/devlog/)
nim r build.nim themes              # the deck in the other themes (docs/slides_<theme>.html: pirate, book, agile)
nim r build.nim check               # only the checks: nothing loaded from the network, no broken link between pages, no nbRawHtml
nim r build.nim island1             # one part of the deck on its own (docs/slides_island1.html), with its module's isMainModule: intro, island1 to island7, conclusion, ...
nim r build.nim slides deepdives    # groups combine; flags after -- go to nim: nim r build.nim deepdives -- -d:release
```

Slides, deep dives, the talk log and the site index are built by one program, `all.nim`: one compile however many pages (about 30 seconds instead of 100 with a compile per page). Each theme is a compile of its own, since the theme is chosen at compile time. Every build ends with the offline check. Explainers (`slides/*_explainer.nim`) and talk log posts (`devlog/*.nim`) are found by name, so a new one needs no change to `all.nim`, to the workflow or here. A single page still builds on its own with `nim r <file>`, e.g. `nim r index.nim` for the deck or `nim r slides/island5_units_explainer.nim` for one explainer.

Outputs go to `docs/` (set by `homeDir` in `nimib.toml`), which is what gets published on GitHub Pages: the `pages` workflow runs `nim r build.nim` on every push to `main` and deploys `docs/`. Generated html is not committed.

## Offline

Every page works offline: nothing is loaded from a CDN. Local copies of what the pages need live in `docs/assets/` (committed): reveal.js, KaTeX, p5.js and the code themes for the slides (`my.nim` points the slides to them), water.css and nimib's highlight.js for the deep dives, the indexes and the talk log (`offline.nim`, through `nb.usePage`), plotly.js for the interactive plots (`slides/nbplotly.nim`), and the fonts of the explored themes. `scripts/vendor-assets.sh` and `scripts/vendor-fonts.sh` download them again (change versions there). `nim r build.nim check` (run at the end of every build) fails when a page still loads something from the network.

## Blocks, not HTML

Pages say what they show with nimib's blocks and the talk's own, never with HTML (see the nimib-blocks skill of [pietroppeter/skills](https://github.com/pietroppeter/skills), enabled for this repository in `.claude/settings.json`):

- `blocks.nim`: the custom blocks (`nbShowCode` for code shown and not run, `nbImg`, `nbGallery`, `nbFrame`, `nbDrawing`, `nbSwatches`, `nbSketch`, `nbLede`, `nbEyebrow`, `nbQuote`, `nbNote`, `nbGithubTitle`, `nbPager`, `nbPageList`), shared by slides, deep dives and the talk log
- `talkstyle.nim`: the CSS and colours of the deep dives, the indexes and the talk log; the slides' style is in `my.nim` (and `themes.nim`)
- `page.nim`: a deep dive (via `nb.useDeepDive`), an index or a talk log post starts with `nb.usePage(ownSource)` after `nbInit` (assets, style, "Show Source")

`nim r build.nim check` also fails when a page uses `nbRawHtml`: make a block instead. Images go in `docs/images/`.

## Review mode

Every deep dive, talk log page and index has a review mode (`review.nim` and `docs/assets/review.js`, ported from [tabelline](https://github.com/pietroppeter/tabelline)): under the title, the page's version (the commits that changed its source) and a **✎ Review** button. In review mode, select words and comment on them, or add a note on the whole page; comments stay in the browser. **Export** gives one text, Markdown with a YAML block, to paste in a Claude Code chat: the `nimib-review` skill (`.claude/skills/nimib-review`) applies each comment to the page's source. `nb.usePage(ownSource, withReview = false)` leaves it out. The slides have no review mode.

`scripts/screenshot.sh docs/slides.html shots/` renders each slide to a png with headless Chromium.

## Decisions and outline

- `decisions/`: lightweight decision records (after [MADR](https://adr.github.io/madr/)), one per domain (the talk, tone and key messages, the islands, slides, themes, deep dives, talk log, build and CI, review, agents and skills), updated in place: what holds today, the options set aside, and a history line per change.
- `outline.md`: the living plan of the talk: sections, timing and slides.
- `notes/`: background notes (the conference, how the slides are set up, references).
- `OPEN-POINTS.md`: open decisions and loose ends.

## License

MIT (see `LICENSE`), except `slides/thank_you.nim` and `deepdive/thank_you_sketch.nim` (which quotes it): the animation of the Thank You slide is based on [a sketch by Okazz](https://openprocessing.org/sketch/3044593), licensed under [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/), so those files are licensed under CC BY-NC-SA 3.0 too.
