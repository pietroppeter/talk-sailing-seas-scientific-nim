# Themes

Status: accepted, the deck wears the nautical chart theme · Updated 2026-11-24

## Context

The deck wears the AgileLab theme of `my.nim`. Following Ines Montani's advice on slides (one theme per talk, consistency is what makes it read as a theme), three themes that carry the voyage were tried on five real slides (talk log: [Dressing the voyage](../devlog/dressing_the_voyage.nim) and [Drawing the map](../devlog/drawing_the_map.nim)).

## Decision

- **The deck wears the nautical chart theme** (Pietro, 2026-11-24), without the heavy contour: the graduated black and white frame around every slide became a thin double neatline. `deckTheme` in `themes.nim` is `chart`; the AgileLab logo and Quarto proportions stay.
- **Three themes explored** (2026-11-07): a pirate adventure game (pixel art, original art only), an old book of sea tales (engraved), a nautical chart. Each is CSS on top of the AgileLab theme (`themes.nim`) plus openly licensed fonts vendored in `docs/assets/fonts` (`scripts/vendor-fonts.sh`). The two not picked, and the plain AgileLab look, are still built on the side with `-d:slideTheme=pirate|book|agile` (`nim r build.nim themes`, `docs/slides_<theme>.html`).
- **One geometry for the map** (Pietro): `maps/geometry.nim` holds the voyage (islands, mainland, route); `maps/base.nim`, `pixel.nim`, `chart.nim` and `engraved.nim` draw it in each style, so a change to the geometry reaches every map.
- **The voyage map is a professional chart** (Pietro, 2026-11-24): Admiralty and NOAA conventions (buff land, a thin coastline, blue tints to 5, 10 and 20 m on white paper, depth contours, soundings, rocks, a magenta rose, course line and light, a title block, a fine graduated border). The sea floor is the distance field stretched by fractal noise, so shelves differ from coast to coast. Each map slide is the chart alone, full width: its title block names the chart ("Chart 3 of 7 · Data Stack").
- **Real islands, Pietro's picks** (Pietro, 2026-11-24): not the famous islands but less recognizable ones he chose, in the order of the sections: Vulcano (Accessible Performance), Lussino/Lošinj (Success Stories), Porquerolles (Data Stack), Milos (Interoperability), Elba (An Expressive Language), Caprera with La Maddalena (Interactivity) and Leros, an island he loves (Notebook). Their coasts are read at build time from the islands story of tabelline (`deps/tabelline/docs/stories/data/isole/islands.csv`: OpenStreetMap outlines, © OpenStreetMap contributors, ODbL, credited on the map), with their real heights (`maps/isole.nim`). Each island is at its own scale, as in the old isolari, and may be turned to fit its place. A line of lore each, in the title block of its chart (proposed, to be rewritten by Pietro). The real names and the lore lines are hidden on the deck's charts, a guessing game for the audience (Pietro, 2026-11-25); `-d:islandNames=true` shows them (`nim r -d:islandNames=true maps/maplab.nim`).
- **The mainland is Istria** (Pietro, 2026-11-24; Istria only, open sea where Trieste and the coast to Monfalcone were, 2026-11-25), turned so the land is south: OpenStreetMap's land polygons (osmdata.openstreetmap.de) from Rovinj up the coast of Istria to the bay of Muggia (the gulf arrangement still goes round Trieste to Monfalcone), simplified to about 40 m so it is as detailed as the islands (Natural Earth's 1:10m was too coarse). Leros sits in the middle, off the gulf; the other six close around it, left, above and right.
- **The course is laid as on a chart** (Pietro, 2026-11-24): straight legs with turns, no bearings, from Portorož to a real port of each island (Porto di Levante, Mali Lošinj, Porquerolles, Adamas, Portoferraio, La Maddalena, Lakki) and into Koper, around the islands clockwise as Pietro sketched it. Turning points are set by hand per arrangement. The course is dashed ahead and solid where sailed; the current island's name is magenta and a magenta anchor marks its port, moved from the real harbour to the most sheltered water near it (`harbour` in `maps/geometry.nim`), so it sits in a bay and not on a point. No lighthouses. Two arrangements are drawn by `nim r maps/maplab.nim` (`docs/maplab.html`): ring (the deck's, Pietro's pick for more sea) and gulf.

- **A map editor** (Pietro, 2026-11-25): a page of the site, `mapeditor.nim` (`docs/mapeditor.html`), built with nimib like the other pages; the editor is Nim compiled to JavaScript (`maps/editor/app.nim`), which draws the chart with the deck's own modules (same coast, islands, depths, soundings), where the coast, the islands (moved, turned, scaled), their names, the anchors, the turning points of the course, the rose and the title block are dragged by hand, and the depths follow. Its JSON is `maps/voyage.json`, which the deck reads at build time (`layoutFromJson` in `maps/isole.nim`) for the ring arrangement: positions are no longer set in code. - **The voyage on the slides** (Pietro, 2026-11-25): a portolano box (sailing directions, a few lines per chart, texts in `maps/voyage.json`) takes the title block's place on the charts, and the title slide's card sits in that box with bigger text. An agenda bar of the seven islands runs along the bottom of every slide but the title, the current one in magenta (the bar belongs to the map); on a map slide its names sail to their places on the chart and back. On a map slide the leg just sailed draws itself and the anchor drops after it; on the first map the whole course draws itself. Without javascript (PDF) the charts show everything at once (`voyageDeckJs` in `themes.nim`).

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
- 2026-11-24: the course from Pietro's sketch, Piran to Koper, on the gulf arrangement (now the deck's); no bearings; a magenta anchor in the current port.
- 2026-11-24: ring arrangement picked (more sea), with the sketched course; no lighthouses; anchors in sheltered water; the voyage sets out from Portorož.
- 2026-11-25: the map slides of the deck draw the chart larger, into the slide margins.
- 2026-11-25: the slides keep the deck's colors (dark and light blue, orange), magenta only on the maps and the title's scale; no diamond before headings; the title slide is the whole chart with the title on a translucent card; real island names hidden.
- 2026-11-25: the mainland cut to Istria, open sea east; the chart fills the screen behind the map slides and the title, its words (names, title block, notes) are html over the drawing (`chartMap(html = true)`).
- 2026-11-25: the map editor; the ring arrangement moved from code to `maps/voyage.json`, which the editor writes; agenda bar, portolano box and route animation previewed in the editor.
- 2026-11-25: Pietro's first map from the editor: islands moved east, Milos mirrored north to south (its port faces south), the course laid again by the editor's router (shortest way by sea, straight legs clear of the coasts), the chart's title block moved to the top left, where the portolano box (bigger) will take its place.
- 2026-11-25: portolano box on the charts and as the title card; agenda bar with names sailing to the map; the course drawing itself.
- 2026-11-25: the map editor became a nimib page of the site, its code ported from JavaScript to Nim (Pietro: the site is built with Nim and nimib), every feature kept.
