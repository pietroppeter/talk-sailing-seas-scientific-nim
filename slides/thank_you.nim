import nimib, nimiSlides
import ../my

# 9.6 Thank you: a p5nim sketch, Nim compiled to JavaScript and drawn with p5.js.
# A grid of colored points flies into the words "Thank You!", one color per letter.
# Inspired by a sketch by Okazz: https://openprocessing.org/sketch/3044593
# The animation starts every time the slide is shown.

template thankYouSlide* =
  useP5
  slide:
    nbRawHtml: """<div id="thank-you-sketch"></div>"""
    nbTextSmall: "[pietroppeter.github.io/talk-sailing-seas-scientific-nim](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/)"
    nbJsFromCodeGlobal:
      import p5
      import std / [dom, jsffi]
    nbJsFromCode:
      const
        W = 960
        H = 560
        message = "Thank You!"
        palette = ["#f70640", "#f78e2c", "#fdd903", "#63be93", "#299dbf", "#38187d", "#a4459f", "#f654a9", "#2F0A30"]
        step = 7 # distance between points inside a letter
        hold = 60 # frames the grid stays still before moving
        maxDelay = 70 # frames: each point leaves the grid with a random delay
        travel = 100 # frames to fly from the grid to the letter

      type Dot = object
        x0, y0, x1, y1: float # position in the grid and in the letter
        delay, size, phase, bend: float
        col: cstring
        inLetter: bool # grid points left over shrink away

      var
        dots: seq[Dot]
        t = -1 # frames since the slide was shown, -1 while it is not shown

      proc easeInOutCubic(x: float): float =
        if x < 0.5: 4 * x * x * x else: 1 - pow(-2 * x + 2, 3) / 2

      proc letterPoints(): seq[(float, float, int)] =
        ## points inside each letter of `message`: draws the letters offscreen,
        ## letter i in red (i + 1) * 20, then samples the pixels every `step`
        let g = createGraphics(W, H)
        discard toJs(g).pixelDensity(1)
        discard toJs(g).textFont("Source Sans Pro".cstring) # the deck's font
        g.textStyle(BOLD)
        g.textSize(100)
        g.textSize(100 * 0.92 * W / g.textWidth(message))
        g.noStroke()
        let x0 = (W - g.textWidth(message)) / 2
        let y0 = H / 2 + g.textAscent() * 0.35
        var letter = 0
        for i, c in message:
          if c == ' ': continue
          inc letter
          g.fill(letter * 20, 0, 0)
          g.text(cstring($c), x0 + g.textWidth(message[0 ..< i].cstring), y0)
        g.loadPixels()
        for y in countup(step div 2, H - 1, step):
          for x in countup(step div 2, W - 1, step):
            let k = 4 * (y * W + x)
            if g.pixels[k + 3] > 200:
              result.add (x.float, y.float, round(g.pixels[k] / 20).int - 1)

      proc slideIsShown(): bool =
        document.querySelector("section.present:not(.stack) > #thank-you-sketch") != nil

      proc makeDots() =
        let points = letterPoints()
        # a grid with about 20% more points than the letters need
        let rows = ceil(sqrt(points.len * 1.2 * H / W)).int
        let cols = ceil(points.len * 1.2 / rows.float).int
        var grid: seq[(float, float)]
        for i in 0 ..< cols:
          for j in 0 ..< rows:
            grid.add (W * (i + 0.5) / cols, H * (j + 0.5) / rows)
        for i in countdown(grid.high, 1): # shuffle, so each point flies to a random place
          let j = int(random(float(i + 1)))
          swap(grid[i], grid[j])
        for i, (gx, gy) in grid:
          var d = Dot(x0: gx, y0: gy, x1: gx, y1: gy, delay: random(maxDelay.float),
            size: step * 1.25, phase: random(TAU), bend: random(-80.0, 80.0))
          if i < points.len:
            let (px, py, letter) = points[i]
            d.x1 = px
            d.y1 = py
            d.col = palette[letter mod palette.len].cstring
            d.inLetter = true
          else:
            d.col = palette[int(random(palette.len.float))].cstring
          dots.add d

      setup:
        createCanvas(W, H)
        document.getElementById("thank-you-sketch").appendChild(document.getElementById("defaultCanvas0"))

      draw:
        if not slideIsShown():
          t = -1
          return
        if dots.len == 0: # made the first time the slide is shown, when the deck's font is loaded
          makeDots()
        inc t
        clear()
        noStroke()
        for d in dots:
          let e = easeInOutCubic(clamp((t - hold - d.delay) / travel, 0.0, 1.0))
          let (dx, dy) = (d.x1 - d.x0, d.y1 - d.y0)
          let len = float(sqrt(dx * dx + dy * dy)) + 0.001
          let arc = sin(PI * e) * d.bend # fly along a curve, not a straight line
          let x = d.x0 + dx * e - dy / len * arc
          let y = d.y0 + dy * e + dx / len * arc
          var size = d.size * (1 + 0.2 * sin(t * 0.08 + d.phase))
          if not d.inLetter:
            size *= 1 - e
          fill(d.col)
          ellipse(x, y, size, size)
