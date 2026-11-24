# Themes

Status: accepted, the deck wears the nautical chart theme · Updated 2026-11-24

## Context

The deck wears the AgileLab theme of `my.nim`. Following Ines Montani's advice on slides (one theme per talk, consistency is what makes it read as a theme), three themes that carry the voyage were tried on five real slides (talk log: [Dressing the voyage](../devlog/dressing_the_voyage.nim) and [Drawing the map](../devlog/drawing_the_map.nim)).

## Decision

- **The deck wears the nautical chart theme** (Pietro, 2026-11-24), without the heavy contour: the graduated black and white frame around every slide became a thin double neatline. `deckTheme` in `themes.nim` is `chart`; the AgileLab logo and Quarto proportions stay.
- **Three themes explored** (2026-11-07): a pirate adventure game (pixel art, original art only), an old book of sea tales (engraved), a nautical chart. Each is CSS on top of the AgileLab theme (`themes.nim`) plus openly licensed fonts vendored in `docs/assets/fonts` (`scripts/vendor-fonts.sh`). The two not picked, and the plain AgileLab look, are still built on the side with `-d:slideTheme=pirate|book|agile` (`nim r build.nim themes`, `docs/slides_<theme>.html`).
- **One geometry for the map** (Pietro): `maps/geometry.nim` holds the voyage (islands, mainland, route); `maps/base.nim`, `pixel.nim`, `chart.nim` and `engraved.nim` draw it in each style, so a change to the geometry reaches every map.
- **The voyage map is a professional chart** (Pietro, 2026-11-24): Admiralty and NOAA conventions (buff land, a thin coastline, blue tints to 5, 10 and 20 m on white paper, depth contours, soundings, rocks, a magenta rose, course line and light, a title block, a fine graduated border). The sea floor is the distance field stretched by fractal noise, so shelves differ from coast to coast. Each map slide is the chart alone, full width: its title block names the chart ("Chart 3 of 7 · Data Stack").
- **Real islands, Pietro's picks** (Pietro, 2026-11-24): not the famous islands but less recognizable ones he chose, in the order of the sections: Vulcano (Accessible Performance), Lussino/Lošinj (Success Stories), Porquerolles (Data Stack), Milos (Interoperability), Elba (An Expressive Language), Caprera with La Maddalena (Interactivity) and Leros, an island he loves (Notebook). Their coasts are read at build time from the islands story of tabelline (`deps/tabelline/docs/stories/data/isole/islands.csv`: OpenStreetMap outlines, © OpenStreetMap contributors, ODbL, credited on the map), with their real heights (`maps/isole.nim`). Each island is at its own scale, as in the old isolari, and may be turned to fit its place. A line of lore each, in the title block of its chart (proposed, to be rewritten by Pietro). The names will go in the end, a guessing game for the audience: `-d:islandNames=false` hides the names and the lore lines.
- **The mainland is the Gulf of Trieste** (Pietro, 2026-11-24), turned so the land is south: OpenStreetMap's land polygons (osmdata.openstreetmap.de) from Rovinj up the coast of Istria, round Trieste to Monfalcone, simplified to about 40 m so it is as detailed as the islands (Natural Earth's 1:10m was too coarse). Leros sits in the middle, off the gulf; the other six close around it, left, above and right.
- **The course is laid as on a chart** (Pietro, 2026-11-24): straight legs with turns, from the port of Trieste to a real port of each island (Porto di Levante, Mali Lošinj, Porquerolles, Adamas, Portoferraio, La Maddalena, Lakki) and back, rounding capes and entering bays by turning points set by hand per arrangement. Two arrangements are drawn by `nim r maps/maplab.nim` (`docs/maplab.html`): ring (the deck's) and gulf.

## Options considered

- Keeping AgileLab only: the safe default, set aside for the chart (still built as `slides_agile.html`).
- Pirate and book: kept on the side; the chart reads as the most professional and fits a scientific audience.
- Invented islands (wobbly circles, the first maps): replaced by real coasts, which make the chart look real and carry a story each.
- Famous islands (Sicily, Sardinia, Malta, Lesbos, Stromboli, Mallorca, Samos: the first real-island map): Pietro preferred less recognizable islands of his own choice.

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
- 2026-11-24: Pietro's islands (Leros in the middle) and the Gulf of Trieste as the mainland, in three arrangements.
- 2026-11-24: the gulf from OpenStreetMap; Milos for Chios and the new order; islands closer; a course of straight legs between real ports; names can be hidden.
- 2026-11-24: the names of the sections larger on the chart, the current one in magenta, a sailing boat in its port.
