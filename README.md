# Sailing Seas of Scientific Nim

Talk by Pietro Peterlongo at Compute! Paris 2026, Thursday 26 November 2026, 14:40-15:10, Room 108 (session "A Babel of Compilers"). In the programme it is titled **Sailing the Seas of Scientific Nim**: [talk page](https://pretalx.com/compute-paris-2026/talk/8EM8ZA/).

Slides: https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/

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

## Slides

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

- `openspec/specs/`: the talk's source of truth (requirements from the abstract above, audience, key messages, format and slot, slides tooling)
- `openspec/outline.md`: the living outline (sections, timing, slides); each change carries an outline delta that archive merges in
- `openspec/changes/`: iterations of the talk in progress, each with proposal → specs (deltas) → outline (sections and slides) → tasks
- `openspec/schemas/talk/`: the custom schema and its templates
- `openspec/reference/`: background notes (conference, slides setup, references)

Install the CLI with `npm install -g @fission-ai/openspec` (cloud sessions do this in a SessionStart hook). In Claude Code: `/opsx:explore`, `/opsx:propose <idea>`, `/opsx:apply`, `/opsx:archive`.
