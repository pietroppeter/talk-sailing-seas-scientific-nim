# Sailing Seas of Scientific Nim

Talk by Pietro Peterlongo at Compute Paris 2026 (end of November 2026).

Slides are made with [nimib](https://github.com/pietroppeter/nimib) and
[nimiSlides](https://github.com/HugoGranstrom/nimiSlides):

- `index.nim`: the presentation, it imports the slides from `slides/`
- `my.nim`: helpers and AgileLab theme; run it directly for a style test deck
- `slides/`: one file per slide (or group of slides)

## setup

Dependencies are managed with atlas (requires Nim >= 2.0, e.g. installed with grabnim):

```
atlas install
nim r index.nim   # writes index.html
nim r my.nim      # style test deck, writes my.html
```

nim-markdown needs PCRE at runtime (`libpcre.so.3`, e.g. `apt install libpcre3`).

`scripts/screenshot.sh index.html shots/` renders each slide to a png with headless
Chromium, using local copies of reveal.js and KaTeX (for environments where the CDNs are blocked).
