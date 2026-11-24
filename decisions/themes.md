# Themes

Status: open, a theme is not picked yet · Updated 2026-11-24

## Context

The deck wears the AgileLab theme of `my.nim`. Following Ines Montani's advice on slides (one theme per talk, consistency is what makes it read as a theme), three themes that carry the voyage were tried on five real slides (talk log: [Dressing the voyage](../devlog/dressing_the_voyage.nim) and [Drawing the map](../devlog/drawing_the_map.nim)).

## Decision

- **Default: AgileLab**, unchanged.
- **Three themes explored** (2026-11-07), built on the side with `-d:slideTheme=pirate|book|chart` (`nim r build.nim themes`, `docs/slides_<theme>.html`): a pirate adventure game (pixel art, original art only), an old book of sea tales (engraved), a nautical chart. Each is CSS on top of the AgileLab theme (`themes.nim`) plus openly licensed fonts vendored in `docs/assets/fonts` (`scripts/vendor-fonts.sh`).
- **One geometry for the map** (Pietro): `maps/geometry.nim` holds the voyage (islands, mainland, route); `maps/base.nim`, `pixel.nim`, `chart.nim` and `engraved.nim` draw it in each style, so a change to the geometry reaches every map.
- **Picking one** is open (see [OPEN-POINTS.md](../OPEN-POINTS.md)); adopting it is a change of its own, recorded here.

## Options considered

- Keeping AgileLab only: the safe default, still on the table.

## Consequences

- Until a theme is picked, the themed decks are built and published next to the default one, listed on the site index.

## History

- 2026-11-07: three themes and the maps explored (PR #26).
- 2026-11-24: themed decks renamed `slides_<theme>.html`; this record created.
