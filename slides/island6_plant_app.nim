## The plant app of Island 6: Nick Strayer's Shiny for Python app
## (shiny/plant/app.py), ported to Nim with Karax and compiled to JavaScript.
## JavaScript only: the slides and the deep dive import it inside nbJsFromCode
## and call `plantApp` with the id of an nbApp block.
import std / [strutils, math]
include karax / prelude # Karax: buildHtml, its tags, setRenderer
import karax / kdom
import island6_plant

# ------------------------------------------------------- the canvas, from Nim
# Karax has no canvas API: the calls the app needs, bound with importjs

type Context2d = ref object
proc getContext2d(canvas: Element): Context2d {.importjs: "#.getContext('2d')".}
proc clearRect(ctx: Context2d, x, y, w, h: float) {.importjs: "#.$1(@)".}
proc beginPath(ctx: Context2d) {.importjs: "#.$1()".}
proc moveTo(ctx: Context2d, x, y: float) {.importjs: "#.$1(@)".}
proc lineTo(ctx: Context2d, x, y: float) {.importjs: "#.$1(@)".}
proc stroke(ctx: Context2d) {.importjs: "#.$1()".}
proc `strokeStyle=`(ctx: Context2d, color: cstring) {.importjs: "#.strokeStyle = #".}
proc `lineWidth=`(ctx: Context2d, width: float) {.importjs: "#.lineWidth = #".}

proc plot(canvas: Element, w, h: float, x, y: seq[float]) =
  ## the curve, stretched to fill the canvas (w x h pixels), in green
  let pad = 8.0
  let ctx = canvas.getContext2d
  ctx.clearRect(0, 0, w, h)
  let (x0, x1, y0, y1) = (min(x), max(x), min(y), max(y))
  proc px(v: float): float = pad + (v - x0) / max(x1 - x0, 1e-9) * (w - 2 * pad)
  proc py(v: float): float = h - pad - (v - y0) / max(y1 - y0, 1e-9) * (h - 2 * pad)
  ctx.strokeStyle = "green"
  ctx.lineWidth = 1.5
  ctx.beginPath()
  ctx.moveTo(px(x[0]), py(y[0]))
  for i in 1 ..< x.len:
    ctx.lineTo(px(x[i]), py(y[i]))
  ctx.stroke()

# ----------------------------------------------------------------- the app
# like Shiny: a sidebar of sliders and a plot. Karax renders the html
# from the state and renders it again after every event

proc slider(name: string, value, min, max: float, step: float,
            update: proc (v: float)): VNode =
  ## a labelled slider that shows its value and calls `update` when moved.
  ## The range counts steps (0 to 100 for 0 to 1 by 0.01): Karax sets the
  ## value of an input before its type, so a range would round 0.2 to 0.
  ## The value is the node's text, not an attribute: an attribute that
  ## changes makes Karax set all the attributes again, type included,
  ## which stops a slider that is being dragged
  let steps = proc (v: float): cstring = cstring($int(round(v / step)))
  let range = buildHtml(input(`type` = "range", min = steps(min), max = steps(max))):
    proc oninput(ev: Event, n: VNode) = update(parseFloat($n.value) * step)
  range.text = steps(value)
  buildHtml(label):
    span: text name
    span: text (if step < 1: value.formatFloat(ffDecimal, 2) else: $value.int)
    range

template slider(field: untyped, min, max: float, step = 1.0): VNode =
  ## a slider for a field of the plant (`p.order`), named after it, that sets it
  slider(astToStr(field).split('.')[^1].capitalizeAscii, field.float, min, max, step,
         proc (v: float) = field = typeof(field)(v))

proc setOrder(e: Element, i: int) {.importjs: "#.style.order = #".}

proc plantApp*(id: string, w = 640.0, h = 440.0): proc (order: seq[int]) =
  ## the app, inside the element with id `id`, with a plot of w x h pixels.
  ## It returns a proc that shows the sliders in another order (`@[1, 0, 2, 3]`
  ## puts Order first): the code you drag on the slide (island6_plant_code.nim)
  var p = Plant(leafiness: 39, order: 9, waviness: 4, simplicity: 0.2)
  var sliders = @[0, 1, 2, 3]
  let plotId = cstring(id & "-plot")
  let (pw, ph) = (cstring($w.int), cstring($h.int)) # the plot, in pixels
  proc render(): VNode =
    buildHtml(tdiv):
      tdiv(class = "sidebar"):
        slider(p.leafiness, 0, 100)
        slider(p.order, 0, 20)
        slider(p.waviness, 0, 10)
        slider(p.simplicity, 0, 1, 0.01)
      canvas(id = plotId,
             width = pw, height = ph)
  proc draw() =
    let (x, y) = p.curve
    getElementById(plotId).plot(w, h, x, y)
    for i, e in document.querySelectorAll(cstring("#" & id & " .sidebar > label")):
      e.setOrder(sliders.find(i)) # its place in the flex column of the sidebar
  setRenderer(render, root = id, clientPostRenderCallback = draw)
  result = proc (order: seq[int]) =
    sliders = order
    draw()
