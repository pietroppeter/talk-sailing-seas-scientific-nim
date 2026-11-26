import nimib, nimiSlides
import ../my
import island6_plant_code # karaxCode

const dragVariant {.booldefine.} = true
  ## slide 7.3 with the slider lines of the code you drag (zogyn): a secret, nothing
  ## on the slide shows it; `-d:dragVariant=false` builds the plain slide

# Section 7: Island 6: Interactivity (see outline.md)
# Nim compiles to JavaScript: a snappy port of a fun Shiny app. Carries K2 (JavaScript backend superpower).
# The deep dive deepdive/plant_app.nim goes further: the code, the numbers, the JavaScript backend, the REPL.

template shinyPlantSlide* =
  slide: # 7.2
    nbText "## 🌱 A Shiny plant"
    nbTextSmall """
[Nick Strayer's](https://twitter.com/NicholasStrayer/status/1554523619379892225)
Shiny for Python app (2022), Python in the browser with shinylive (Pyodide):
16 MB to download, 8 s to the first plot, 0.4 s per slider move
([live](shiny/plant/index.html))
"""
    imageAside("images/shiny_plant.png", "The Shiny plant app: four sliders and a plant plotted by matplotlib"):
      nbText """
$$ \begin{gathered}
x = t \cos^3 t \\\\
y = \ell t \sqrt{|\cos t|} + t \sin(p t) \cos(o t) \\\\
t \in [0, n \pi / 2]
\end{gathered} $$
"""
    speakerNote """
Something I am crazy about, and that I think no other
language of scientific computing has: a kind of
interactivity. Not the kind you are thinking of, a REPL:
Nim does not have one, yet. I mean producing artifacts
that are interactive, because with the JavaScript
backend we are native on the web, with that native feel.
This was clear to me years ago, when I ran into this
Shiny app that plots a curve that looks like a fern,
and I wanted to do it in Nim. Back then it needed a
server; now with WASM it does not, but it is clunky
and it takes more time.

Nick Strayer shared this in 2022: a generative plant,
four sliders, matplotlib. The plant is a parametric curve:
n is the leafiness, ℓ the order, o the waviness, p the simplicity;
each time cos t is zero the curve comes back to the stem, a leaf. Shinylive runs it with no server:
CPython compiled to WebAssembly, numpy and matplotlib included.
The shared link no longer runs: Shiny removed the layout it used,
a two-line fix. Numbers measured locally, no network counted.
"""

template nimPlantSlide* =
  slide: # 7.3
    nbText "## 🌿 The Nim plant"
    columns:
      column:
        when dragVariant: nbCodeStage("plant-code", karaxCode)
        else: nbShowCode karaxCode
      column:
        nbApp("plant")
    when dragVariant:
      nbJsFromCode:
        import ../slides/[island6_plant_app, island6_plant_code]
        plantCode("plant-code", plantApp("plant", 330, 360), 350)
    else:
      nbJsFromCode:
        import ../slides/island6_plant_app
        discard plantApp("plant", 330, 360)
    nbTextSmall """
Nim and [Karax](https://github.com/karaxnim/karax) (a reactive framework:
metaprogramming again), compiled to JavaScript: first plot in 30 ms, 250× sooner than Shiny (8 s);
300 KB, 50× lighter (16 MB) ·
🐋 [the code, explained](deepdive/plant_app.html)
"""
    speakerNote """
If it is JavaScript you can interact with it, and you
really get the feeling of interaction. And when you can
interact on a page you can do crazy stuff: press on a
bound in the code (0, 20, 100...) and move left or right,
the number changes and the slider with it, as in
Bret Victor's explorable explanations.
Karax is another example of metaprogramming:
a reactive framework in Nim.

Move the sliders: the same plant, the same curve,
written in Nim and compiled to JavaScript when the deck is built.
Easter egg, not said on the slide: drag a slider line in the code,
the sliders follow (zogyn; the trick is explained in the deep dive).
The page is Karax: buildHtml describes the sidebar and the canvas
from the state, Karax renders it again after every slider move,
and the canvas is bound with importjs in a few lines.
About 250 times faster to the first plot, 50 times lighter,
and each move is drawn on the next frame instead of 0.4 s later.
Not a fair fight: shinylive brings all of Python;
Nim translates the program into the language of the browser,
and draws its own plot, since ggplotnim needs Cairo (C).
"""

template island6RocksSlide* =
  slide: # 7.4
    nbText "## 🪨⚠️ Rocks ahead"
    nbText """
- no REPL yet, only experiments: nim secret, INim, jupyternim, cicak
- a REPL fits interpreted or JIT languages; Nim is statically typed and compiled ahead of time
- so no Jupyter- or Marimo-style interactivity in Nim (nimib goes another way: next island)
"""
    speakerNote """
The interactivity that is not there is the REPL.
cicak is my recent AI-driven explainer on providing one.

The interactivity scientists use most is the REPL and the notebook cell.
Nim has no real one. nim secret runs code in the compiler's VM,
INim keeps the session in a file and compiles it again at each line,
jupyternim is a beta kernel not maintained since 2022, cicak is my experiment.
Static types and ahead-of-time compilation make it hard;
incremental compilation (Nimony, NIF) may help.
nimib goes the other way: the document is a program you run again (next island).
"""

template island6InteractivitySection* =
  slide:
    mapSlide(6) # 7.1
    shinyPlantSlide # 7.2
    nimPlantSlide # 7.3
    island6RocksSlide # 7.4

when isMainModule: # this part of the deck on its own: docs/slides_island6.html
  buildDeckPart("island6", "slides/island6_interactivity.nim"):
    island6InteractivitySection
