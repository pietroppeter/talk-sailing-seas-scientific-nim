import nimib
import nimiSlides except speakerNote # blogpost.nim has its own (my.nim exports it)
import ../my

# 1.5 Playfulness, the last slide of the mainland before the voyage: the word over a p5nim sketch.
# The sketch is p5nim's port of a sketch by Okazz (220919a,
# https://pietroppeter.github.io/p5nim/okazz_220919a.html, original https://openprocessing.org/sketch/1653811):
# rings of dots that pulse, turn and drift. Okazz's sketch is licensed under CC BY-NC-SA 3.0
# (https://creativecommons.org/licenses/by-nc-sa/3.0/), so this file is licensed under
# CC BY-NC-SA 3.0 too, unlike the rest of the repository (MIT).
# It runs in p5's instance mode (the Thank You sketch has the global one), inside a proc:
# instance mode fails to compile at the top level. Its names start with `ok`, since all the
# sketches of the deck are one JavaScript program.

template okazzPlayfulSlide* =
  useP5
  slide: # 1.5
    nbSketch("okazz-sketch")
    nbDiv("playful-word", ""):
      nbText "# playfulness"
    nbJsFromCodeGlobal:
      import p5
      import std / dom
      from std / math import nil
      from std / random as okRandom import nil
    nbJsFromCode:
      const
        okW = 960 # the whole slide
        okH = 700
        okColors = ["#f70640", "#f78e2c", "#fdd903", "#cae509", "#63be93", "#81cfe5",
                    "#299dbf", "#38187d", "#a4459f", "#f654a9", "#2F0A30"]
      type OkForm = object # a ring of n dots that turns, breathes and drifts up and right
        x, y, r0, r, d0, d, a, t, r1, r2, r3: float
        n: int
        col: int
      var okForms: seq[OkForm]
      proc okRand(a, b: float): float = okRandom.rand(b - a) + a
      let okCell = 50.0
      for i in 0 ..< int(okW / okCell):
        for j in 0 ..< int(okH / okCell):
          if (i + j) mod 2 == 0:
            for k in 0 ..< 5:
              okForms.add OkForm(x: i.float * okCell + okCell / 2, y: j.float * okCell + okCell / 2,
                r0: okRand(10, 25), d0: okRand(0, 15) * okRand(0, 1) + 5,
                n: int(okRand(3, 13)), a: okRand(0, 100), t: okRand(0, 10000),
                r1: okRand(0, 0.01), r2: okRand(0, 0.01), r3: okRand(0, 0.01),
                col: okRandom.rand(okColors.high))

      proc okMove(f: var OkForm) =
        f.t += 1
        f.a = math.TAU * math.sin(f.t * f.r1)
        f.r = f.r0 * math.sin(f.t * f.r2)
        f.d = f.d0 * math.sin(f.t * f.r3)
        f.x += 0.5
        f.y -= 0.5
        if f.x > okW: f.x = 0
        if f.y < 0: f.y = okH

      proc okDots(): seq[(float, float, float, int)] =
        ## every dot of every ring, then a step forward
        for f in okForms.mitems:
          for i in 0 ..< f.n:
            let theta = f.a + math.TAU * i.float / f.n.float
            result.add (f.x + f.r * math.cos(theta), f.y + f.r * math.sin(theta), (if f.d < 0: -f.d else: f.d), f.col)
          okMove(f)

      proc okShown(): bool =
        document.querySelector("section.present > #okazz-sketch") != nil

      proc okSketch() =
        instance("okazz-sketch"):
          setup:
            createCanvas(okW, okH)
          draw:
            if not okShown(): return
            clear() # transparent: the slide's background shows through
            noStroke()
            let dots = okDots()
            for k in 0 ..< dots.len:
              let (x, y, d, c) = dots[k]
              fill(cstring(okColors[c]))
              ellipse(x, y, d, d)
      okSketch()
    speakerNote """
Before we leave: why Nim, for me? Playfulness.
Nim is a language I play with. This is a sketch by Okazz,
ported to Nim with p5nim, compiled to JavaScript.
"""
