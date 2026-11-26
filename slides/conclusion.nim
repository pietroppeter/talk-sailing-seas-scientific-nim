import nimib, nimiSlides
import tabelline
import ../my

# Section 9: Conclusion: back on land (see outline.md)
# Takeaways and an opinionated reflection on why Nim is still niche. Carries K1, K3 and K4.

# the table of slide 9.4, made in procs and not in the templates below,
# so that tabelline's names stay out of the deck's templates (as in island3_datastack.nim)
proc nicheTable*(): Tabella =
  let views = @[
    (area: "🧬 Language", view: "stable: 1.0 in 2019, 2.0 in 2023, ready for more than it is used for"),
    (area: "🛠️ Tooling", view: "editor support and compile times behind Rust's; Nimony and NIF are the way to catch up"),
    (area: "📦 Ecosystem", view: "small: libraries depend on a few people, users wait for libraries"),
    (area: "🤝 Community", view: "friendly and small: one person can make a difference"),
    (area: "🏛️ Governance", view: "**the main shortcoming**: few people decide, the direction is hard to read from outside")]
  tabella(views, rownameCol = "area")
    .colsLabel({"view": "My view"})
    .fmtMarkdown("view")
    .highlightRows(@[4])
    .tabStyle(style.text(whitespace = "nowrap"), loc.stub())
    .slideLook(fontSize = "0.7em")

template beginnerSlide* =
  slide: # 9.2
    nbText "## For the beginner"
    columns:
      column:
        nbText """
### ⛵ Fair winds

- reads like Python, with a compiler
  that checks your types
- a small community: easy to find
  something to contribute and make your own
- room to experiment, also with AI
"""
      column:
        nbText """
### 🪨 Rocks ahead

- a niche: it will not help you find a job
- fewer libraries: things take more work
- fewer answers online
"""
    nbTextSmall """
Where to start: [the playground](https://play.nim-lang.org),
[Nim for Python programmers](https://github.com/nim-lang/Nim/wiki/Nim-for-Python-Programmers),
[Exercism](https://exercism.org/tracks/nim),
[SciNim getting started](https://scinim.github.io/getting-started/)
"""
    speakerNote """
If you are new, or just curious. Fair winds: it reads like Python,
and the compiler teaches you what types are about.
The community is small, so it is much easier to find something
you want to contribute and make it your own.
And it is a good place to experiment with AI: in a big ecosystem
you have to go slower with AI; in a small one you can try more.
Rocks ahead: it is a niche, it will not help you find a job,
and things are harder to do: fewer libraries, fewer answers online.
Start in the browser with the playground. Advent of Code starts in a few days.
"""

template builderSlide* =
  slide: # 9.3
    nbText "## For the builder"
    columns:
      column:
        nbText """
### ⛵ Fair winds

- prototype and fast code in one language
- C and C++ libraries one line away
- a Python package with wheels, the browser for free
- macros for your own notation (units)
"""
      column:
        nbText """
### 🪨 Rocks ahead

- a tiny ecosystem: you will write more code
- a few maintainers carry each library
- bridges and packaging of uneven maturity
- no REPL; macros can be hard to read
"""
    speakerNote """
If you build tools: the left column is what we saw on the islands,
the right column is the rocks we collected along the way.
Pioneers did real science with it (Island 2), and Vindaar says
he learned way more than he would have otherwise.
Write the algorithm in Nim, and ship it to Python users as a wheel:
that is the path naffprop took (Island 4).
"""

template nicheSlide* =
  slide: # 9.4
    nbText "## Why still niche?"
    nbTable nicheTable()
    nbLede """
Fun, exciting, and with more potential
than the impact it had so far
"""
    speakerNote """
My opinionated view. The language is stable and ready:
1.0 in 2019, 2.0 in 2023 with ARC/ORC memory management.
On tooling: editor support and compile times are behind Rust's;
Nimony, the next compiler, and NIF, its intermediate format,
are meant to bring incremental compilation and better tooling.
The ecosystem is the chicken and egg of every small language.
The community is friendly, and small enough that one person
makes a difference (most of scientific Nim is a handful of people).
Last, the main shortcoming is governance: decisions rest with very few
people, and it is hard to know from outside where the language goes.
Still: it is fun, exciting, and has more potential than impact so far.
"""

template playfulSlide* =
  useP5
  slide: # 9.5: the last word of the mainland, over a p5nim sketch
    nbSketch("playful-sketch")
    nbDiv("playful-word", ""):
      nbText "# playfulness"
    nbJsFromCodeGlobal:
      import p5
      import std / [dom, algorithm, strutils]
      from std / math import nil
    nbJsFromCode:
      const
        sphereW = 960 # the whole slide
        sphereH = 700
        sphereR = 250.0 # the sphere's radius
        nBalls = 500 # points on the sphere
        # Okazz's ballColors, as in the Thank You slide
        ballColors = ["#f42464", "#f6a620", "#09aa75", "#58a5fd", "#4629d7",
                   "#f93c1b", "#fbd50c", "#f7acc6", "#251872"]
      type SphereBall = tuple[z, x, y: float, col: int]
      proc hexChannel(c: string, k: int): float = float(parseHexInt(c[1 + 2 * k .. 2 + 2 * k]))
      var spherePoints: seq[(float, float, float)] # a Fibonacci sphere: points evenly spread
      for i in 0 ..< nBalls:
        let y = 1 - 2 * (i.float + 0.5) / nBalls.float
        let r = math.sqrt(1 - y * y)
        let a = i.float * 2.399963 # the golden angle
        spherePoints.add (math.cos(a) * r, y, math.sin(a) * r)

      proc sphereTurned(sphereT: int): seq[SphereBall] =
        ## the sphere turned by frame sphereT, around a tilted axis, back to front
        let (a, tilt) = (sphereT.float * 0.006, 0.4 + 0.15 * math.sin(sphereT.float * 0.004))
        for i, (x, y, z) in spherePoints:
          let x1 = x * math.cos(a) + z * math.sin(a)
          let z1 = z * math.cos(a) - x * math.sin(a)
          let y2 = y * math.cos(tilt) - z1 * math.sin(tilt)
          let z2 = y * math.sin(tilt) + z1 * math.cos(tilt)
          result.add (z: z2, x: x1, y: y2, col: (i + sphereT div 40) mod ballColors.len)
        result.sort()

      proc sphereShown(): bool =
        document.querySelector("section.present > #playful-sketch") != nil

      var sphereT = 0
      proc sphereSketch() = # in a proc: p5nim's instance mode fails to compile at the top level
        instance("playful-sketch"):
          setup:
            createCanvas(sphereW, sphereH)
          draw:
            if not sphereShown(): return
            inc sphereT
            clear() # transparent: the slide's background shows through
            noStroke()
            let sphereBalls = sphereTurned(sphereT)
            for k in 0 ..< sphereBalls.len:
              let b = sphereBalls[k]
              let d = 6 + 9 * (b.z + 1) # the near side bigger
              let c = ballColors[b.col]
              fill(hexChannel(c, 0), hexChannel(c, 1), hexChannel(c, 2), 120 + 135 * (b.z + 1) / 2)
              ellipse(sphereW / 2 + sphereR * b.x, sphereH / 2 + sphereR * b.y, d, d)
      sphereSketch()
    speakerNote """
And one last word, the one that sums up Nim for me: playfulness.
The sphere is a p5nim sketch, Nim compiled to JavaScript,
in the colors of Okazz, like the one at the end.
"""

template conclusionSection* =
  slide:
    mapSlide(8) # 9.1
    beginnerSlide
    builderSlide
    nicheSlide
    playfulSlide

when isMainModule: # this part of the deck on its own: docs/slides_conclusion.html
  buildDeckPart("conclusion", "slides/conclusion.nim"):
    conclusionSection
