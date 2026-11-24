# Themes

Status: accepted, the deck wears the nautical chart theme · Updated 2026-11-24

## Context

The deck wears the AgileLab theme of `my.nim`. Following Ines Montani's advice on slides (one theme per talk, consistency is what makes it read as a theme), three themes that carry the voyage were tried on five real slides (talk log: [Dressing the voyage](../devlog/dressing_the_voyage.nim) and [Drawing the map](../devlog/drawing_the_map.nim)).

## Decision

- **The deck wears the nautical chart theme** (Pietro, 2026-11-24), without the heavy contour: the graduated black and white frame around every slide became a thin double neatline. `deckTheme` in `themes.nim` is `chart`; the AgileLab logo and Quarto proportions stay.
- **Three themes explored** (2026-11-07): a pirate adventure game (pixel art, original art only), an old book of sea tales (engraved), a nautical chart. Each is CSS on top of the AgileLab theme (`themes.nim`) plus openly licensed fonts vendored in `docs/assets/fonts` (`scripts/vendor-fonts.sh`). The two not picked, and the plain AgileLab look, are still built on the side with `-d:slideTheme=pirate|book|agile` (`nim r build.nim themes`, `docs/slides_<theme>.html`).
- **One geometry for the map** (Pietro): `maps/geometry.nim` holds the voyage (islands, mainland, route); `maps/base.nim`, `pixel.nim`, `chart.nim` and `engraved.nim` draw it in each style, so a change to the geometry reaches every map.
- **The voyage map is a professional chart** (Pietro, 2026-11-24): Admiralty and NOAA conventions (buff land, a thin coastline, blue tints to 5, 10 and 20 m on white paper, depth contours, soundings, rocks, a magenta rose, course line and light, a title block, a fine graduated border). The sea floor is the distance field stretched by fractal noise, so shelves differ from coast to coast. Each map slide is the chart alone, full width: its title block names the chart ("Chart 3 of 7 · Data Stack").
- **Real islands** (Pietro, 2026-11-24): each island of the talk is drawn with the coast of an island of the Mediterranean, read at build time from the islands story of tabelline (`deps/tabelline/docs/stories/data/isole/islands.csv`: OpenStreetMap outlines, © OpenStreetMap contributors, ODbL, credited on the map), with its real height and the smaller islands around it where they really are (`maps/isole.nim`). Each island is at its own scale, as in the old isolari. The picks and a line of lore each, shown in the title block of the island's chart: Sicily for Accessible Performance (Etna, Archimedes), Samos for Success Stories (the tunnel of Eupalinos, dug by a small team from both ends), Sardinia for the Data Stack (nuraghi, towers of stacked stones), Malta for Interoperability (a Semitic language in Latin letters), Lesbos for An Expressive Language (Sappho, Aristotle's lagoon), Stromboli for Interactivity (the lighthouse of the Mediterranean, erupting every few minutes), Mallorca for the Notebook (Ramon Llull's paper wheels). `nim r maps/maplab.nim` draws every chart on one page (`docs/maplab.html`) to review a change without building the deck.

## Options considered

- Keeping AgileLab only: the safe default, set aside for the chart (still built as `slides_agile.html`).
- Pirate and book: kept on the side; the chart reads as the most professional and fits a scientific audience.
- Invented islands (wobbly circles, the first maps): replaced by real coasts, which make the chart look real and carry a story each.

- Quarto itself (render the deck with Quarto): not an option, the deck is nimib; only its look is borrowed ([slides.md](slides.md)).

## Consequences

- The other themes are built and published next to the deck, listed on the site index; the talk log posts of 7 November link the chart theme to the deck itself.
- The map needs tabelline's islands data at build time: it comes with the pinned tabelline in `atlas.lock`. A tabelline update that moves or changes `islands.csv` changes or breaks the map.
- The lore lines are short and checked against Wikipedia; anything said on stage about them belongs in the speaker notes.

## History

- 2026-11-07: three themes and the maps explored (PR #26).
- 2026-11-24: Quarto's proportions adopted for the deck (recorded in [slides.md](slides.md)); the themes build on top of them.
- 2026-11-24: themed decks renamed `slides_<theme>.html`; this record created.
- 2026-11-24: the nautical chart adopted for the deck, with a thin frame; the voyage map redrawn as a professional chart on seven real islands, with lore.
