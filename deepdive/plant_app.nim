import std / [strutils, math]
import nimib
import deepdive # useDeepDive, and the blocks of blocks.nim
import ggplotnim
import ../slides/island6_plant # the curve, the same module the app runs
import ../slides/island6_plant_code # karaxCode, the code of the app you drag

# The deep dive of Island 6 (Interactivity): the plant app, a Shiny for
# Python app ported to Nim and compiled to JavaScript, and what Nim's
# JavaScript backend can and cannot do; the REPL in rocks ahead.
#   nim r deepdive/plant_app.nim
# writes docs/deepdive/plant_app.html. The code shown is read from the
# files of the app when the page is built, so it never goes stale.

const
  appSource = staticRead("../slides/island6_plant_app.nim")
  plantSource = staticRead("../slides/island6_plant.nim")
  codeSource = staticRead("../slides/island6_plant_code.nim")
  shinySource = staticRead("../shiny/plant/app.py")
  shinyOriginal = staticRead("../shiny/plant_original.py")

proc excerpt(source, startMarker, endMarker: string): string =
  ## the lines of `source` from the line starting with `startMarker`
  ## up to (not including) the line starting with `endMarker`
  ## (to the end when `endMarker` is empty)
  let lines = source.splitLines
  var first, last = -1
  for i, line in lines:
    if first < 0 and line.startsWith(startMarker):
      first = i
    elif first >= 0 and endMarker.len > 0 and line.startsWith(endMarker):
      last = i - 1
      break
  if first >= 0 and last < 0: last = lines.high
  doAssert first >= 0 and last >= first,
    "deep dive: code not found from '" & startMarker & "'"
  while last > first and lines[last].strip.len == 0:
    dec last
  lines[first .. last].join("\n")

proc withoutComments(source: string): string =
  ## the Python code without the comment lines on top
  var lines: seq[string]
  for line in source.splitLines:
    if lines.len == 0 and line.startsWith("#"): continue
    lines.add line
  lines.join("\n").strip

nbInit(thisFileRel = "deepdive/plant_app.nim")
const ownSource = staticRead("plant_app.nim")
nb.useDeepDive("plant_app", ownSource)
nb.useLatex

nbText """
# A plant in the browser

Nim compiles to C, and it also compiles to JavaScript.
The same language, the same standard library (most of it),
running in a web page with nothing to install.
This page shows it with a small app: a plant that grows
when you move four sliders.
It first appeared as a [Shiny for
Python](https://shiny.posit.co/py/) app, and here it runs
both ways: Python in the browser with
[shinylive](https://shiny.posit.co/py/docs/shinylive.html),
and Nim compiled to JavaScript.
Then we look at what the JavaScript backend can and cannot
do, and at the interactivity Nim does not have yet:
a REPL.

This is the app in Nim. Move the sliders:
"""
nbApp("plant")
nbText """
This is its page, in [Karax](https://github.com/karaxnim/karax):
grab the line of a slider and drag it up or down,
the sliders of the app follow.
"""
nbCodeStage("plant-code", karaxCode)
nbJsFromCode:
  import ../slides/[island6_plant_app, island6_plant_code]
  plantCode("plant-code", plantApp("plant"))

nbText """
The plant is drawn again on every move of a slider,
in the page: nothing goes to a server, and nothing is
waiting for Python to start.

## The original: a Shiny app

In August 2022 [Nick
Strayer](https://twitter.com/NicholasStrayer/status/1554523619379892225)
shared a small generative art app made with Shiny for
Python and shinylive: "Play with the parameters of this
plot right in your browser".
Shiny is the web framework of R, by Posit, ported to
Python in 2022; shinylive runs a Shiny app with no server
at all: Python itself runs in the browser, with
[Pyodide](https://pyodide.org), CPython compiled to
WebAssembly.

A Shiny app has a UI (four sliders in a sidebar, a plot)
and a server function, which draws the plot again with
matplotlib whenever an input changes:
"""
nbShowCode(withoutComments(shinySource), lang = "python",
  caption = "shiny/plant/app.py")

nbText """
The app runs on this site, Python in the browser, offline
like the rest of the talk:
[open the Shiny app](../shiny/plant/index.html)
(it takes a few seconds to start; from your own copy of the
site, serve `docs/` over http, for example with
`python3 -m http.server -d docs`, since shinylive needs a
service worker, which does not run from a file).
"""
nbImg("images/shiny_plant.png",
  caption = "The Shiny app, Python running in the browser with shinylive.",
  alt = "The Shiny plant app: four sliders on the left, a green plant plotted with matplotlib on the right")

nbText """
### Why the shared link stopped working

The link Nick shared opens the shinylive editor with the
code of the app packed in the address (compressed with
lz-string), and it no longer runs.
Shinylive always loads the latest Shiny, and the
original code used `ui.panel_sidebar` and `ui.panel_main`,
which Shiny deprecated in 2023 and removed in 1.0 (2024).
The fix is two lines: the layout is now `ui.page_sidebar`
with a `ui.sidebar` (and the `@output` decorator is not
needed anymore). This was the original layout:
"""
nbShowCode(excerpt(shinyOriginal, "app_ui", "def server"),
  lang = "python", caption = "shiny/plant_original.py")

nbText """
A small lesson in itself: a web app that runs an
interpreter and its packages depends on all of their
versions, and the latest ones move.
The site pins shinylive (0.8.13, with Shiny 1.9 and
Pyodide) in `scripts/shinylive.sh`, which exports the app
with every file it needs, about 50 MB.

## The plant

The curve is a parametric curve: a point that moves with
$t$, from $0$ to $n \pi / 2$, where $n$ is the leafiness.

$$ x = t \cos^3 t $$

$$ y = \ell t \sqrt{|\cos t|} + t \sin(p t) \cos(o t) $$

with $\ell$ the order, $o$ the waviness and $p$ the
simplicity. Each time $\cos t$ goes through zero the point
comes back to the stem: that is a leaf.
In Nim the curve is a few lines that read like the numpy
code of the Shiny app:
"""
nbShowCode(excerpt(plantSource, "type Plant", ""),
  caption = "slides/island6_plant.nim")

nbText """
This module does not know where it runs.
The app imports it and runs it in the browser, compiled to
JavaScript; this page imports it too, compiled to C when
the page is built, and plots the plant with ggplotnim, the
plotting library of the data stack (Island 3):
"""
nbCode:
  let (x, y) = Plant(leafiness: 39, order: 9, waviness: 4,
                     simplicity: 0.2).curve
  echo x.len, " points, as tall as ", y.max.round(1)
  ggplot(toDf(x, y), aes("x", "y")) +
    geom_line(color = "green") +
    ggsave("images/plant_ggplotnim.png", width = 480,
           height = 360)
nbImg("images/plant_ggplotnim.png", width = "480",
  caption = "The plant, plotted with ggplotnim when the page was built.",
  alt = "The plant plotted by ggplotnim")

nbText """
## The app, in Nim

The app is in
[`slides/island6_plant_app.nim`](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim/blob/main/slides/island6_plant_app.nim),
about 90 lines. Its page is made with
[Karax](https://github.com/karaxnim/karax), the framework
for web pages of Nim's author: `buildHtml` describes the
html from the state of the app (the code above), and
Karax renders it again after every event, changing only
what changed in the page.

### Talking to JavaScript

Karax, like Nim's standard library (`std/dom`), has the
browser's document as Nim types: elements, events,
`getElementById`.
Neither has the canvas, so the app binds the few calls it
needs itself, with `importjs`: each line says which JavaScript
to write for a Nim call (`#` is the first argument,
`$1` the name of the proc, `@` all the arguments).
A JavaScript library is wrapped the same way, a call at a
time, and the calls are typed: the compiler checks them.
"""
nbShowCode(excerpt(appSource, "type Context2d", "proc plot"),
  caption = "slides/island6_plant_app.nim")

nbText """
### A plot without matplotlib

The Shiny app plots with matplotlib, which Pyodide brings
to the browser compiled to WebAssembly.
In Nim, ggplotnim draws with Cairo, a C library, which
the JavaScript backend cannot use.
So the app draws on a canvas: it stretches the curve to
the canvas and draws one green line through the 1000
points. No axes: the plant does not need them.
"""
nbShowCode(excerpt(appSource, "proc plot", "# ---"),
  caption = "slides/island6_plant_app.nim")

nbText """
### Sliders, and drawing again

A slider is a label, the value and an `<input>` of type
range, in `buildHtml`; when it moves, it calls a closure
that updates the plant, and Karax renders the page again
and calls `draw`, which plots the plant.
A template makes a slider from a field of the plant
(`slider(p.order, 0, 20)`): its name is the name of the
field, and moving it sets the field.
The four sliders mirror the Shiny ones, with the same
ranges and defaults.
"""
nbShowCode(excerpt(appSource, "proc slider", ""),
  caption = "slides/island6_plant_app.nim")

nbText """
### Code you drag

The code at the top of the page is not a picture: its
slider lines are a sortable list of
[zogyn](https://github.com/pietroppeter/zogyn), Pietro's
library of declarative dragging, a Nim port of
[Dragology](https://github.com/declarative-dragging/dragology)
(Horowitz, Blinn and Heer, UIST 2026).
You do not write drag handlers: for the element you grab,
you list the states the drag can reach (here every place
of that line among the slider lines), zogyn draws each
one without showing it, and shows the one that puts the
line closest to the pointer.
When the line is dropped, the app gets the new order of
the sliders.
The code is the page's own highlighted code block, which
`plantCode` turns into an svg stage when the page opens.
"""
nbShowCode(excerpt(codeSource, "  proc renderCode", ""),
  caption = "slides/island6_plant_code.nim")

nbText """
The page calls the app inside an `nbJsFromCode` block of
[nimib](https://github.com/pietroppeter/nimib): when the
page is built, nimib compiles the block with
`nim js` and puts the JavaScript in the page.
The slide does the same.
"""
nbShowCode("""
nbApp("plant")
nbCodeStage("plant-code", karaxCode)
nbJsFromCode:
  import ../slides/[island6_plant_app, island6_plant_code]
  plantCode("plant-code", plantApp("plant"))""", caption = "deepdive/plant_app.nim")

nbText """
## Side by side

The same app, measured on one machine in a
headless Chromium, with the site served locally (so the
network is not counted), on 24 November 2026:

| | Shiny (shinylive) | Nim (JavaScript) |
|---|---|---|
| files on the site | about 48 MB | 300 KB of JavaScript |
| downloaded by the page | about 16 MB | 300 KB |
| first plot after opening | about 8 s | about 30 ms |
| plot again after a slider moves | about 0.4 s | the next frame |

The 300 KB are the app, Karax and zogyn, as nimib writes
them (180 KB minified); the plain app, with no framework
and no dragging, was 96 KB.
Drawing the plant takes under 1 ms: Karax waits for the
next frame of the browser (16 ms) to render.

This is not a fair fight, and it is not meant as one.
Shinylive brings a whole Python, numpy and matplotlib to
the browser: anything you can do in Python runs, with the
libraries you know, and the code is the code you would run
on a server.
The Nim app is a program written for the browser: small
and fast, but it draws its own plot because the plotting
library of Nim does not run there.
Different tradeoffs: to bring the language you know to the
browser (Python, R with webR) you bring its runtime;
Nim translates your program into the language of the
browser.

## Nim's JavaScript backend

`nim js app.nim` writes one `app.js` file: Nim translated
to JavaScript, not an interpreter compiled to WebAssembly.
The JavaScript garbage collector manages memory, a Nim
`string` or `seq` becomes a JavaScript value, and the file
carries only the parts of the standard library you use.

What works: the language (types, generics, templates,
macros, which run in the compiler and leave plain
JavaScript), and the pure Nim parts of the standard
library (`strutils`, `math`, `sequtils`, `tables`, `json`,
`algorithm`, ...), plus modules made for the browser:
[`std/dom`](https://nim-lang.org/docs/dom.html),
[`std/jsffi`](https://nim-lang.org/docs/jsffi.html) to call
any JavaScript object,
[`std/asyncjs`](https://nim-lang.org/docs/asyncjs.html)
for promises, `std/jsfetch`.
What does not (from the [backends
guide](https://nim-lang.org/docs/backends.html#backends-the-javascript-target)):
threads, files and the operating system, manual memory
management, `cast` and other unsafe operations, and any
library that wraps C (Arraymancer's BLAS and LAPACK,
ggplotnim's Cairo).
Since Nim 2.0, `int64` is a JavaScript BigInt, so it
keeps its 64 bits; `int` is a JavaScript number.

The same module can run on both backends, as the curve
above does; `when defined(js)` picks code for one of them.
So a project can share its logic between a server (C)
and its web front-end (JavaScript), in one language.

What people build with it:

- [Karax](https://github.com/karaxnim/karax), a framework
  for single page applications by Nim's author, with a
  virtual DOM; [the Nim forum](https://forum.nim-lang.org)
  is written in it, and so is the app above. The [first
  version of this
  app](https://nimib.land/nblog/drafts/plant_app.html), in
  Pietro's nblog, used Karax with a few slider widgets.
- [zogyn](https://github.com/pietroppeter/zogyn), the
  dragging of the code above: its engine is pure Nim, so
  its tests run natively, and its stage runs in the browser.
- [p5nim](https://github.com/pietroppeter/p5nim), Nim
  bindings for p5.js: the animation of [the last
  slide](thank_you_sketch.html) of this talk is one.
- nimib itself: `nbJsFromCode` and `nbKaraxCode` put
  Nim compiled to JavaScript in a page, as this one does.
- the search of Nim's own documentation, compiled from
  Nim with the JavaScript backend.

## Rocks ahead: no REPL

The interactivity that scientists use most is not a web
app: it is a REPL, a notebook cell you run again and
again, a variable you look at, a plot you change.
Python, R and Julia have it at their core; Jupyter is
named after the three.
Nim does not have it, yet, and that is no accident: a REPL
fits well an interpreted language, or one with a JIT
compiler like Julia, while Nim is statically typed and
compiled ahead of time, through a C compiler.
Each line you type has to be type checked against all the
lines before it, compiled, and run, and a compiled program
does not keep its state between two compiles.

The attempts so far:

- `nim secret`, a REPL hidden in the compiler, which runs
  the code in the compiler's virtual machine (the one that
  runs macros): no imports of C libraries, and not
  maintained as a user tool.
- [INim](https://github.com/inim-repl/INim), an
  interactive shell, still maintained: it keeps your
  session in a file, and compiles and runs it again for
  every line you type. It works, but each line costs a
  compile.
- [jupyternim](https://github.com/stisa/jupyternim), a
  Jupyter kernel in beta, that runs prior cells again;
  hot code reloading, which would avoid that, is
  experimental in Nim and in the kernel. Its last commit is
  from 2022: it may still work, it is not maintained.
- [cicak](https://github.com/pietroppeter/cicak), Pietro's
  current experiment, in research: each input becomes a
  Nim module, which a long-running process loads with hot
  code reloading, while incremental compilation (`nim ic`)
  keeps each step cheap. Its [dev
  log](https://pietroppeter.github.io/cicak/) has the
  research and a first proof of concept.

nimib goes the other way: no REPL, the document is a Nim
program that you run again (Island 7).
The compiler work on incremental compilation, around
Nimony and NIF, may make a fast REPL more realistic in the
future.
"""
nbSave
