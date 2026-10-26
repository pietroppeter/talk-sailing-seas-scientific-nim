import nimib, nimiSlides
import ../my

# 9.6 Thank you, the last slide on the top row (after the conclusion stack): a p5nim sketch, Nim compiled to JavaScript and drawn with p5.js.
# A grid of colored points flies along curves into the words "Thank You!", one color per letter,
# and back into the grid, in a loop. The animation starts from the grid every time the slide is shown.
#
# Based on a sketch by Okazz, https://openprocessing.org/sketch/3044593 (a grid that morphs into
# packed circles and back), whose palette it uses. Okazz's sketch is licensed under CC BY-NC-SA 3.0
# (https://creativecommons.org/licenses/by-nc-sa/3.0/), so this file is licensed under
# CC BY-NC-SA 3.0 too, unlike the rest of the repository (MIT).

template thankYouSlide* =
  useP5
  nb.addStyle: """
.reveal .slides section:has(> #thank-you-sketch) {
  top: 0 !important;
  height: var(--slide-height);
  padding: 0;
}
#thank-you-sketch {
  position: absolute;
  inset: 0;
}
.thank-you-link {
  position: absolute;
  z-index: 1;
  left: 0;
  right: 0;
  bottom: 12px;
  line-height: 1.3;
}
.thank-you-credit {
  font-size: 0.4em;
  opacity: 0.7;
}
"""
  slide:
    nbRawHtml: """<div id="thank-you-sketch"></div>
<div class="thank-you-link"><small><a href="https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/">pietroppeter.github.io/talk-sailing-seas-scientific-nim</a></small><br>
<span class="thank-you-credit">animation built with <a href="https://github.com/pietroppeter/p5nim">p5nim</a> and inspired by <a href="https://openprocessing.org/sketch/3044593">a sketch by Okazz</a>, <a href="https://creativecommons.org/licenses/by-nc-sa/3.0/">CC BY-NC-SA 3.0</a></span></div>"""
    nbJsFromCodeGlobal:
      import p5
      import std / [dom, jsffi]
    nbJsFromCode:
      const
        W = 960 # the whole slide
        H = 700
        message = "Thank You!"
        font = "bold 100px 'Source Sans Pro'" # the deck's font, for the letters
        # Okazz's palette, one color per letter of "ThankYou!"
        palette = ["#f42464", "#f6a620", "#09aa75", "#58a5fd", "#4629d7", "#f93c1b", "#fbd50c", "#f7acc6", "#251872"]
        step = 7 # distance between points inside a letter
        gridRest = 120 # frames the grid stays still
        letterRest = 180 # frames "Thank You!" stays still
        maxDelay = 70 # frames: each point leaves with a random delay
        travel = 100 # frames to fly between the grid and the letter
        period = gridRest + maxDelay + travel + letterRest + maxDelay + travel

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
        let y0 = H * 0.45 + g.textAscent() * 0.35
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

      proc makeDots() =
        let points = letterPoints()
        # a grid with about 20% more points than the letters need, above the link at the bottom
        let (gw, gh, top) = (W * 0.96, H * 0.74, H * 0.04)
        let rows = ceil(sqrt(points.len * 1.2 * gh / gw)).int
        let cols = ceil(points.len * 1.2 / rows.float).int
        var grid: seq[(float, float)]
        for i in 0 ..< cols:
          for j in 0 ..< rows:
            grid.add ((W - gw) / 2 + gw * (i + 0.5) / cols, top + gh * (j + 0.5) / rows)
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

      proc progress(d: Dot): float =
        ## 0 in the grid, 1 in the letters; the way back retraces the same curve
        let s = t mod period
        let back = gridRest + maxDelay + travel + letterRest
        if s < gridRest:
          0.0
        elif s < back:
          easeInOutCubic(clamp((s - gridRest - d.delay) / travel, 0.0, 1.0))
        else:
          1 - easeInOutCubic(clamp((s - back - d.delay) / travel, 0.0, 1.0))

      proc slideIsShown(): bool =
        document.querySelector("section.present:not(.stack) > #thank-you-sketch") != nil

      setup:
        createCanvas(W, H)
        document.getElementById("thank-you-sketch").appendChild(document.getElementById("defaultCanvas0"))

      draw:
        if not slideIsShown():
          t = -1
          return
        if dots.len == 0: # made the first time the slide is shown, once the deck's bold font is loaded
          let fonts = toJs(document).fonts
          if not fonts.check(font.cstring).to(bool):
            discard fonts.load(font.cstring)
            return
          makeDots()
        inc t
        clear() # transparent, so the slide's background and logo show through
        noStroke()
        for d in dots:
          let e = progress(d)
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

when isMainModule:
  # the slide on its own: `nim r slides/thank_you.nim` writes docs/thank_you.html
  myInit("thank_you.nim")
  thankYouSlide
  nbSave
