import nimib, nimiSlides
import ../my

# 9.6 Thank you: a p5nim sketch, Nim compiled to JavaScript and drawn with p5.js.
# A grid of colored points moves into the words "Thank You!", one color per letter,
# and back into the grid, in a loop.
# Inspired by a sketch by Okazz (https://openprocessing.org/sketch/3044593), where a grid
# morphs into packed circles and back: same palette, easing and translucent colors.
# The animation starts from the grid every time the slide is shown.

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
  bottom: 20px;
}
"""
  slide:
    nbRawHtml: """<div id="thank-you-sketch"></div>
<div class="thank-you-link"><small><a href="https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/">pietroppeter.github.io/talk-sailing-seas-scientific-nim</a></small></div>"""
    nbJsFromCodeGlobal:
      import p5
      import std / [dom, jsffi]
    nbJsFromCode:
      const
        W = 960 # the whole slide
        H = 700
        message = "Thank You!"
        # Okazz's palette, one color per letter of "ThankYou!"
        palette = ["#f42464", "#f6a620", "#09aa75", "#58a5fd", "#4629d7", "#f93c1b", "#fbd50c", "#f7acc6", "#251872"]
        step = 9 # distance between points inside a letter
        gridRest = 90 # frames the grid stays still
        letterRest = 180 # frames "Thank You!" stays still
        wave = 60 # frames: points leave in a wave from left to right
        move = 70 # frames: move of one point
        period = gridRest + wave + move + letterRest + wave + move

      type Dot = object
        x0, y0, size0: float # in the grid
        x1, y1, size1: float # in the letter
        delay: float
        col: Color

      var
        dots: seq[Dot]
        t = -1 # frames since the slide was shown, -1 while it is not shown

      proc easeInOutQuad(x: float): float =
        if x < 0.5: 2 * x * x else: 1 - pow(-2 * x + 2, 2) / 2

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

      proc makeDots() =
        var points = letterPoints()
        # a full grid with as many cells as points, in 85% x 75% of the slide:
        # the few points that do not fit in the grid are dropped from the letters
        let (gw, gh) = (W * 0.85, H * 0.75)
        let rows = round(sqrt(points.len * gh / gw)).int
        let cols = points.len div rows
        let gap = gw / cols.float
        for i in countdown(points.high, 1): # shuffle, so each point goes to a random letter
          let j = int(random(float(i + 1)))
          swap(points[i], points[j])
        for i in 0 ..< cols:
          for j in 0 ..< rows:
            let (px, py, letter) = points[i * rows + j]
            let gx = (W - gw) / 2 + gap * (i + 0.5)
            let gy = (H - gh) / 2 + gh / rows.float * (j + 0.5)
            var c = color(palette[letter mod palette.len].cstring)
            discard toJs(c).setAlpha(int(random(150.0, 255.0)))
            dots.add Dot(x0: gx, y0: gy, size0: gap * 0.45, x1: px, y1: py, size1: step * 1.3,
              delay: gx / W * wave, col: c)

      proc progress(d: Dot): float =
        ## 0 in the grid, 1 in the letters
        let s = t mod period
        if s < gridRest:
          0.0
        elif s < gridRest + wave + move:
          easeInOutQuad(clamp((s - gridRest - d.delay) / move, 0.0, 1.0))
        elif s < gridRest + wave + move + letterRest:
          1.0
        else:
          1 - easeInOutQuad(clamp((s - gridRest - wave - move - letterRest - d.delay) / move, 0.0, 1.0))

      proc slideIsShown(): bool =
        document.querySelector("section.present:not(.stack) > #thank-you-sketch") != nil

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
        clear() # transparent, so the slide's background and logo show through
        blendMode(MULTIPLY)
        noStroke()
        for d in dots:
          let e = progress(d)
          fill(d.col)
          ellipse(d.x0 + (d.x1 - d.x0) * e, d.y0 + (d.y1 - d.y0) * e, d.size0 + (d.size1 - d.size0) * e)
