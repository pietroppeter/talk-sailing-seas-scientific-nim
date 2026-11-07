import std / [strutils, json]
import nimib
import nimib / highlight
import ../my

# A nimib document, a research post: three themes for the slides,
# tried on a few real slides before one is picked:
#   scripts/build-themes.sh   (docs/index_<theme>.html, screenshots in docs/images/themes)
#   nim r slides/themes_explainer.nim
# writes docs/themes_explainer.html.

# this path writes the page to docs/, not docs/slides/
nbInit(thisFileRel = "themes_explainer.nim")
# but with it nimib cannot find this file,
# so give the "Show Source" button its source here
const ownSource = staticRead("themes_explainer.nim")
nb.doc.source = ownSource
nb.doc.context["source"] = %nb.doc.source
nb.doc.context["source_highlighted"] = %highlightNim(nb.doc.source)
nbRawHtml("<style>\n" & """
pre { overflow-x: auto; }
figure { margin: 1em 0; }
figure img { width: 100%; border: 1px solid #ddd; }
figcaption { font-size: 0.85em; color: #6b7280; }
.shots { display: grid; grid-template-columns: 1fr 1fr; gap: 0.6em; }
.shots img { width: 100%; border: 1px solid #ddd; }
.swatches { display: flex; flex-wrap: wrap; gap: 0.4em; margin: 0.5em 0 1em; }
.swatch { font-size: 0.75em; padding: 0.4em 0.6em; border-radius: 4px; border: 1px solid #ccc; }
.bare-map .voyage-map { width: 100%; height: auto; background: #fff; }
.bare-map .voyage-map * { display: inline !important; }
.bare-map .sea { fill: #f0f6fa; }
.bare-map .grid { fill: none; }
.bare-map .island, .bare-map .land { fill: #eee; stroke: #333; }
.bare-map .island-hatch, .bare-map .land-hatch { opacity: 0.3; }
.bare-map .hatch-line, .bare-map .grid-line { stroke: #999; }
.bare-map .contour { fill: none; stroke: #9ab; }
.bare-map .route, .bare-map .route-done { fill: none; stroke: #c33; stroke-dasharray: 6 4; }
.bare-map .route-done { stroke-dasharray: none; stroke-width: 3; }
.bare-map .waves path { fill: none; stroke: #69c; }
.bare-map .x-mark { stroke: #c33; stroke-width: 4; }
.bare-map .light { fill: #c0c; }
.bare-map .compass-point { fill: #fff; stroke: #333; }
.bare-map .compass-point.long { fill: #333; }
.bare-map .compass-ring { fill: none; stroke: #333; }
.bare-map text { font-family: sans-serif; font-size: 15px; }
.bare-map .soundings text { font-size: 11px; fill: #69c; }
""" & "</style>")

proc shots(theme: string) =
  ## the five slides of the experiment, in one theme, as a grid of screenshots
  var html = "<div class=\"shots\">\n"
  for s in ["0", "5.0", "5.1", "5.3", "4.4"]:
    html.add "<a href=\"images/themes/" & theme & "-" & s & ".jpg\"><img src=\"images/themes/" &
      theme & "-" & s & ".jpg\" alt=\"" & theme & " theme, slide " & s & "\"></a>\n"
  html.add "</div>"
  nbRawHtml html

proc swatches(colors: openArray[(string, string, string)]) =
  ## color swatches: (background, text color, label)
  var html = "<div class=\"swatches\">"
  for (bg, fg, label) in colors:
    html.add "<span class=\"swatch\" style=\"background:" & bg & ";color:" & fg & "\">" & label & " " & bg & "</span>"
  html.add "</div>"
  nbRawHtml html

nbText """
# Dressing the voyage: three themes for the slides

The talk [Sailing Seas of Scientific
Nim](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/)
is a sea voyage: we leave the mainland of scientific computing
and visit seven islands, one per strength of Nim.
So far the slides wear the AgileLab theme,
clean and corporate.
This post is an experiment:
what if the look of the slides told the voyage too?

It is a research proof of concept.
We study how Ines Montani designs her slides,
then try three themes on five real slides of the deck:

1. **A pirate adventure game**: a treasure map, parchment,
a chunky display font, colored dialogue lines.
2. **An old book of sea tales**: 19th century printing,
chapters, red ink, an engraved map.
3. **A nautical chart**: soundings, depth contours,
a graduated border and chart magenta for the hazards.

Nothing changes in the deck yet:
the themes are built on the side,
and one (or a mix) will be picked and adopted later.
"""

nbText """
## What Ines Montani teaches about slides

[Ines Montani](https://ines.io/), co-founder of Explosion
(the makers of spaCy and Prodigy), is known for talks
with very distinctive slides.
She wrote a seven part series on how she makes them,
which starts with
[a beginner's guide](https://ines.io/blog/beginners-guide-beautiful-slides-talks)
and continues with
[aesthetics](https://ines.io/blog/beautiful-slides-talks-part-2-aesthetics),
[technical content](https://ines.io/blog/beautiful-slides-talks-part-3-technical-content),
[design elements](https://ines.io/blog/beautiful-slides-talks-part-4-design-elements),
[sharing](https://ines.io/blog/beautiful-slides-talks-part-5-sharing-presentations),
a [community showcase](https://ines.io/blog/beautiful-slides-talks-part-6-community-showcase)
and a [resources and tools list](https://ines.io/blog/beautiful-slides-talks-part-7-resources-tools-list).
There is also a short version as a lightning talk,
[Beautiful Slides for Beginners](https://speakerdeck.com/inesmontani/lightning-talk-beautiful-slides-for-beginners)
(2024).
The ideas below are my summary of the series:
read the originals, they are full of examples.

**One theme per talk.**
She picks one aesthetic for each talk
(glitchy analog, 80s, paper collage, Y2K, historic paintings...)
and carries it through every slide:
the headline fonts, the colors, the backgrounds and the graphics.
Consistency is what makes a theme read as a theme.

**Fonts are the strongest lever.**
A good font makes a world of difference,
and it is the first thing she recommends to change.
She browses free libraries like Google Fonts
for a display font that carries the mood,
pairs it with a readable font for the text,
and keeps a monospace font for the code.
A font you keep using can become your signature.

**Aesthetics bring dry topics to life.**
Her approach is openly aesthetics driven:
technical talks are abstract,
and a strong look gives the audience something to hold on to.
Textures and gradients add "pop" to plain backgrounds,
with boxes, panels or shadows to keep the text readable.

**Start small, subtle and simple.**
A font, a color, a theme: that is already a lot.
One accent color per slide goes a long way,
and decoration should not be overdone.

**Recurring visual metaphors.**
For technical ideas she uses custom graphics
that come back across the talk
(for example a blob or a cube for kinds of models),
plus highlight colors, boxes and speech bubbles
to point at what matters in a chart.

**Code is there to explain.**
Show the code that explains what happens:
leaving out boilerplate or using ellipses is fine
if it makes the code simpler,
and arrows or speech bubbles can annotate it.
Diagrams and flowcharts made of boxes and arrows
explain processes better than prose.

**Tools do not matter much.**
She uses Keynote, but her tools list
also has code based tools like Marp (Markdown) and Beamer (LaTeX).
Our slides are Nim code with nimib and nimiSlides,
and everything here is css, svg and fonts, so it fits.

### What we take from it

For this talk the theme is already there in the story:
a voyage across islands.
So each theme below carries the voyage
through a display font, a palette, a background texture
and one recurring graphic, **the map of the voyage**,
the visual metaphor that comes back at every section.
The map replaces the list of islands
that the section slides show today.
"""

nbText """
## The starting point

The five slides of the experiment, in the AgileLab theme of the deck:
the title, the section slide of Island 3 (the map),
a table (the data stack), code with its output (Datamancer)
and two quotes (the rocks ahead of Island 2).
They cover most of what the deck has:
headings, text, tables, code, quotes and the map.
"""
shots("agile")

nbText """
## How the themes are built

Each theme is css on top of the AgileLab theme,
so every slide of the deck gets it for free,
plus openly licensed fonts and one map.
Pick a theme when building the deck:
`nim r -d:slideTheme=pirate index.nim`,
with `pirate`, `book` or `chart`
(`scripts/build-themes.sh` builds all three).
Without the define the deck is unchanged.
The whole deck in each theme:
[pirate](index_pirate.html),
[book](index_book.html),
[chart](index_chart.html).

All fonts are from Google Fonts, under the SIL Open Font License,
and are vendored in `docs/assets/fonts`
(`scripts/vendor-fonts.sh` takes them from the @fontsource npm packages),
so the slides still work offline at the venue.
Textures are svg noise filters written in the css,
so there are no image files either.

The map is drawn by code, in `themes.nim`:
seven wobbly islands (circles with a few sine waves on the radius,
smoothed with Catmull-Rom splines),
depth contours around them, the mainland, a dashed route,
a compass rose, waves and soundings.
One svg has every layer,
and each theme's css decides which layers to show and how they look.
Here it is with every layer visible and no theme:
"""
nbCode:
  let svg = voyageMap(islands, 3, id = "bare")
  echo svg.len, " characters of svg, ", svg.count("<path"), " paths"
nbRawHtml "<div class=\"bare-map\">" & svg & "</div>"

nbText """
## Theme 1: a pirate adventure game

**The mood**: the point-and-click pirate adventures of the 90s,
like The Secret of Monkey Island:
a hand-drawn treasure map, warm parchment, a tropical sea,
a red X on the island we are visiting,
and characters who speak in colored lines of pixel text.
The theme borrows the mood, not the game:
the map is drawn from scratch and the fonts are open,
no logo, art or font from any game is used.

**Fonts**:
[Germania One](https://fonts.google.com/specimen/Germania+One)
for the headings, a chunky blackletter-flavored display face
that reads at a glance;
[Alegreya](https://fonts.google.com/specimen/Alegreya)
for the text, a lively book serif;
[Pixelify Sans](https://fonts.google.com/specimen/Pixelify+Sans)
for quotes, as dialogue lines of a game;
[JetBrains Mono](https://fonts.google.com/specimen/JetBrains+Mono)
for code.

The first try had Pirata One, the most "pirate" font,
but its D reads like a V ("Vata Stack"):
a heading font must be readable from the back of the room.
These are the candidates I compared (all OFL):
"""
nbRawHtml """<figure><img src="images/themes/pirate-heading-fonts.jpg" alt="heading font candidates">
<figcaption>Heading font candidates on parchment: Germania One won for readability, New Rocker was the runner up.</figcaption></figure>"""
swatches([("#ecd9a8", "#3b2412", "parchment"), ("#5a1a0c", "#fff", "headings"),
  ("#b3261e", "#fff", "strong, X, route"), ("#11747a", "#fff", "emphasis"),
  ("#8fc9c0", "#3b2412", "sea"), ("#1c1228", "#8fe3e8", "dialogue")])
nbText """
**Details**: bullets are little ✗ marks,
code sits in parchment boxes with a hard shadow,
the title slide floats over a faded map,
and the "rocks ahead" quotes become dialogue lines,
one color per speaker, on a dark box.
"""
shots("pirate")

nbText """
## Theme 2: an old book of sea tales

**The mood**: a 19th century book of voyages,
the kind with an engraved map folded in the front.
Each section is a chapter,
"Chapter IV, The Island of Data Stack",
printed in black with red ink for what matters
(rubrication, as old printers did),
a fleuron ❧ under every title
and a double rule framing the page.

**Fonts**: the
[IM Fell](https://fonts.google.com/specimen/IM+Fell+English) family,
Igino Marini's digital revival of the Fell types,
cast in the 17th century and bequeathed to Oxford by John Fell,
which still look exactly like an old printed book:
IM Fell English SC (small caps) for headings
and IM Fell English for text;
[Courier Prime](https://fonts.google.com/specimen/Courier+Prime)
for code, as a typewriter would set it.
"""
swatches([("#efe5cf", "#241a12", "paper"), ("#241a12", "#efe5cf", "ink"),
  ("#8e1b17", "#fff", "red ink")])
nbText """
**Details**: tables are set like a printed table,
with rules only at the top, below the header and at the bottom;
code has rules above and below instead of a box;
quotes get a big red opening quote mark
and their source in small caps;
the map is engraved, with hatched land and ripples around the islands;
the AgileLab logo is toned down to sepia.
The title gets a subtitle, "A Tale in Seven Islands".
"""
shots("book")

nbText """
## Theme 3: a nautical chart

**The mood**: this is my own proposal.
A nautical chart is the scientific instrument of the sea:
it measures depths, marks hazards and gives a scale.
That fits a talk about scientific computing.
The slides become chart sheets: "Chart 3 of 7",
a black and white graduated border like the edge of a chart,
a light grid, depth soundings and dashed depth contours on the map.
Charts print lights and cautions in magenta,
so magenta marks the current island (a light),
the route, the emphasis,
and the "rocks ahead" quotes get a CAUTION label.
The title is a chart's title block,
with its scale: 1 : 30 minutes.

**Fonts**: [Space Grotesk](https://fonts.google.com/specimen/Space+Grotesk)
for headings, labels and tables, a technical grotesque;
[Spectral](https://fonts.google.com/specimen/Spectral)
for text, a screen-first serif with a nice italic for the soundings;
JetBrains Mono for code.
"""
swatches([("#f6f3ea", "#13334c", "chart paper"), ("#13334c", "#fff", "navy ink"),
  ("#d7e9f2", "#13334c", "water"), ("#1f6fa3", "#fff", "depth blue, strong"),
  ("#b0167a", "#fff", "chart magenta, emphasis"), ("#f2e3b3", "#13334c", "land")])
nbText """
**Details**: headings start with a magenta diamond,
tables have a navy header row,
code sits in white boxes with a thin navy border,
and the output has a pale water background.
It is the most readable of the three
and the closest to the current deck.
"""
shots("chart")

nbText """
## Side by side

| | Pirate game | Old book | Nautical chart |
|---|---|---|---|
| Mood | playful, nostalgic | literary, warm | precise, scientific |
| Readability | good, headings are loud | good, text is old-style | best |
| Code | fine on parchment | typewriter, quiet | crisp |
| Fits "scientific" | least | middle | most |
| Fun | most | middle | middle |
| Risk | can feel like a costume | small caps headings get long | can feel plain |

The three are not exclusive:
the book's chapter headings, the pirate's X and dialogue quotes,
and the chart's CAUTION boxes are small pieces
that could move from one theme to another.

## Next steps

Pick a theme (or a mix), then adopt it in the deck
as a change of its own: move the css into `my.nim`,
show it in the style test deck,
and redo the slides that need it, section by section,
starting from the map slides.
"""

nbSave
