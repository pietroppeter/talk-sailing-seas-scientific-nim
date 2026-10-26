import std / [strutils, strformat]
import nimib
import nimib / highlight

# A nimib document that explains the code of the Thank You slide (slides/thank_you.nim),
# step by step: `nim r slides/thank_you_explainer.nim` writes docs/thank_you_explainer.html.
# The code shown is read from slides/thank_you.nim when the page is built, so it never goes stale;
# a step whose code markers are not found anymore stops the build.
#
# It quotes slides/thank_you.nim, which is licensed under CC BY-NC-SA 3.0
# (https://creativecommons.org/licenses/by-nc-sa/3.0/), so this file is licensed under
# CC BY-NC-SA 3.0 too, unlike the rest of the repository (MIT).

const source = staticRead("thank_you.nim")

proc excerpt(startMarker, endMarker: string): tuple[code: string, first, last: int] =
  ## the lines of slides/thank_you.nim from the line starting with `startMarker`
  ## up to (not including) the line starting with `endMarker`, dedented
  let lines = source.splitLines
  var first, last = -1
  for i, line in lines:
    if first < 0 and line.startsWith(startMarker):
      first = i
    elif first >= 0 and line.startsWith(endMarker):
      last = i - 1
      break
  doAssert first >= 0 and last >= first, "explainer: code not found between '" & startMarker & "' and '" & endMarker & "'"
  while last > first and lines[last].strip.len == 0:
    dec last
  result = (lines[first .. last].join("\n").dedent, first + 1, last + 1)

proc codeHtml(startMarker, endMarker: string): string =
  let (snippet, first, last) = excerpt(startMarker, endMarker)
  result = &"""<pre><code class="nohighlight nim hljs">{highlightNim(snippet)}</code></pre>
<p class="lines">slides/thank_you.nim, lines {first}–{last}</p>"""

template step(n: int, title, startMarker, endMarker, text: string) =
  nbText "### " & $n & ". " & title & "\n\n" & text
  nbRawHtml codeHtml(startMarker, endMarker)

nbInit(thisFileRel = "thank_you_explainer.nim")
nbRawHtml("<style>\n" & """
pre { overflow-x: auto; }
.lines { font-size: 0.8em; color: #6b7280; margin-top: -0.5em; }
.sketch { width: 100%; aspect-ratio: 16 / 9; border: 1px solid #ddd; border-radius: 6px; }
.note { border-left: 4px solid #02A4BD; padding-left: 1em; }
""" & "</style>")

nbText """
# How the Thank You slide works

The last slide of the talk [Sailing Seas of Scientific Nim](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/) is an animation: a grid of colored points flies into the words "Thank You!", one color per letter, and back, in a loop. It is written in [Nim](https://nim-lang.org) with [p5nim](https://github.com/pietroppeter/p5nim), the Nim bindings for [p5.js](https://p5js.org), compiled to JavaScript by [nimib](https://github.com/pietroppeter/nimib) when the slides are built. It is inspired by [a sketch by Okazz](https://openprocessing.org/sketch/3044593), where a grid morphs into packed circles and back, and it uses Okazz's palette.

Below, after some background, this page walks through the code of [`slides/thank_you.nim`](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim/blob/main/slides/thank_you.nim), top to bottom. p5nim keeps p5.js names, so it reads close to the JavaScript of a p5.js sketch.
"""
nbRawHtml """<iframe class="sketch" src="thank_you.html" title="The Thank You slide, live"></iframe>
<p class="lines">The slide, live (<a href="thank_you.html">open it on its own</a>).</p>"""

nbText """
## Creative coding, Processing, p5.js and p5nim

**Creative coding** is programming to make something expressive rather than something functional: generative art, animations, interactive installations, data art, visuals for music. The code is the artist's material, and the result is often a small program (a *sketch*) that you can run, tweak and share. Communities like [OpenProcessing](https://openprocessing.org), where Okazz publishes, and yearly challenges like [Genuary](https://genuary.art) collect thousands of sketches with their source code, so learning by reading and remixing other people's work is part of the culture.

[**Processing**](https://processing.org) started this tradition in 2001: Casey Reas and Ben Fry, then at the MIT Media Lab, made a language, a library and an editor to teach programming to artists and designers in a visual context. A sketch is two functions: `setup`, run once, and `draw`, run at every frame; inside them, simple calls like `fill`, `ellipse` or `translate` draw on a canvas. Processing was built on Java, which back then ran in the browser as applets.

[**p5.js**](https://p5js.org), started in 2013 by Lauren Lee McCarthy, reinterprets Processing for the web in JavaScript, with the same `setup` / `draw` model and the same names. It is developed by the Processing Foundation with a strong focus on making coding accessible and inclusive for artists, designers, educators and beginners.

[**p5nim**](https://github.com/pietroppeter/p5nim) gives Nim bindings to p5.js: the sketch is written in Nim with the same names (`setup:` and `draw:` are Nim templates), and Nim's JavaScript backend compiles it to JavaScript that calls p5.js. It also comes with [examples](https://pietroppeter.github.io/p5nim/), including ports of Okazz's sketches, and helpers to use it with nimib, which is how this slide puts a sketch inside a nimiSlides deck. A sketch written this way gets Nim's static types and compile-time checks, while still running in the browser like any p5.js sketch: a small example of one of Nim's superpowers, the JavaScript backend.
"""

step 1, "A slide that runs Nim in the browser", "  slide:", "    nbJsFromCode:", """
`thankYouSlide` is a [nimiSlides](https://github.com/HugoGranstrom/nimiSlides) template. Before the slide, `useP5` (from `my.nim`) loads p5.js from a local copy in the page head, so the deck works without network, and some CSS makes the slide fill the whole screen, so the canvas can use all of it. The slide itself is an empty `div` where the canvas will go, plus the link and the credits at the bottom.

`nbJsFromCodeGlobal` and `nbJsFromCode` are nimib blocks whose Nim code is not run when the slides are built: nimib compiles it with `nim js` and puts the resulting JavaScript in the page. `import p5` brings in p5nim.
"""

step 2, "Knobs: size, palette and timing", "      const", "      type Dot", """
The canvas covers the whole 960×700 slide. Each of the 9 letters of *ThankYou!* gets one of the 9 colors of Okazz's palette. Times are in frames, at 60 frames per second: 2 s on the grid, up to 1.2 s of random departure delay, 1.7 s of flight, 3 s on the letters, then the same way back. `period` is one full loop, about 11 s.
"""

step 3, "One record per point", "      type Dot", "      proc letterPoints", """
Each `Dot` knows where it sits in the grid (`x0, y0`) and in the text (`x1, y1`), plus its own departure delay, a `phase` for its pulse and a `bend` for how curved its flight is. `t` counts the frames since the slide was shown. `easeInOutCubic` makes each flight start and end slowly.
"""

step 4, "Where do the points of the letters go?", "      proc letterPoints", "      proc makeDots", """
This is the interesting part: Okazz's circles go to random free spots, but here they must draw text. The sketch writes the text on an offscreen canvas (`createGraphics`), in the deck's bold font, sized to 92% of the width and centered with `textWidth`. Each letter is drawn on its own, in a red level that encodes its index (20 for the first, 40 for the second, and so on). Then the sketch reads the pixels on a lattice every 7 pixels: each opaque pixel becomes a target point, and its red level tells which letter, and so which color, it belongs to.
"""

step 5, "The grid, shuffled", "      proc makeDots", "      proc progress", """
The grid is a full rectangle with about 20% more points than the letters need. It is shuffled (a Fisher–Yates loop), so each grid point gets a random target and the points cross each other on the way, which is what makes the flight look busy. The first points get a letter target and its color. The others get a random palette color and no target: their target is their own grid position.
"""
nbText """
<p class="note"><strong>Where do the extra grid points go?</strong> Nowhere. While the others fly to the letters, each extra point shrinks in place to nothing, with the same delay and easing as a flying point. On the way back it grows again, so the grid is full whenever it rests. On screen, they fade out of the grid as the flight starts.</p>
"""

step 6, "The timeline", "      proc progress", "      proc slideIsShown", """
`progress` turns the frame count into a number between 0 (grid) and 1 (letters) for each point, and `t mod period` makes it loop. On the way there each point waits its own `delay` and then eases from 0 to 1. On the way back it goes from 1 to 0 with the same delay, so it retraces its curve.
"""

step 7, "Start when the slide is shown", "      proc slideIsShown", "      draw:", """
p5's `setup` creates the canvas once and moves it into the slide. `slideIsShown` asks reveal.js, through the DOM, whether this slide is the current one.
"""

step 8, "Draw a frame", "      draw:", "when isMainModule", """
While the slide is hidden, nothing is drawn and `t` is reset, so the animation starts again from the grid every time you come to the slide. The points are made on the first frame the slide is shown, once the deck's bold font is loaded (otherwise the letters would come out in a fallback font).

Each frame clears the canvas (transparent, so the slide's background and logo show through) and draws every point. A point moves on the straight line from grid to letter, pushed sideways by `sin(PI * e) * bend`: that push is zero at both ends and largest halfway, so the line becomes an arc. Every point pulses a little with its own phase, and the extra grid points shrink as `e` goes to 1 (`size *= 1 - e`) and grow back as it returns to 0.
"""

nbText """
---

The slide and this page are licensed under [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/), like [Okazz's sketch](https://openprocessing.org/sketch/3044593) that inspired them.
"""
nbSave
