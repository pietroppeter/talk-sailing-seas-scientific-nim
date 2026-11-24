## The plant app of Island 6: Nick Strayer's Shiny for Python app
## (shiny/plant/app.py), ported to Nim and compiled to JavaScript.
## JavaScript only: the slides and the deep dive import it inside nbJsFromCode
## and call `plantApp` with the id of an nbApp block.
import std / [dom, strutils]
import island6_plant

# ------------------------------------------------------- the canvas, from Nim
# std/dom has no canvas: the five calls the app needs, bound with importjs

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
# like Shiny: a sidebar of sliders and a plot; moving a slider draws again

proc slider(parent: Element, label: string, min, max, value: float,
            step = 1.0, onInput: proc (v: float)) =
  ## a labelled slider that shows its value and calls `onInput` when moved
  let box = document.createElement("label")
  let name = document.createElement("span")
  let shown = document.createElement("output")
  let input = document.createElement("input")
  name.innerText = cstring(label)
  shown.innerText = cstring(if step < 1: $value else: $value.int)
  input.setAttr("type", "range")
  input.setAttr("min", cstring($min))
  input.setAttr("max", cstring($max))
  input.setAttr("step", cstring($step))
  input.value = cstring($value)
  input.addEventListener("input", proc (e: Event) =
    shown.innerText = input.value
    onInput(parseFloat($input.value)))
  box.appendChild(name)
  box.appendChild(shown)
  box.appendChild(input)
  parent.appendChild(box)

proc plantApp*(id: string, w = 640.0, h = 440.0) =
  ## the app, inside the element with id `id`, with a plot of w x h pixels
  let app = document.getElementById(cstring(id))
  let sidebar = document.createElement("div")
  let canvas = document.createElement("canvas")
  canvas.setAttr("width", cstring($w.int))
  canvas.setAttr("height", cstring($h.int))
  sidebar.classList.add("sidebar")
  app.appendChild(sidebar)
  app.appendChild(canvas)
  var p = Plant(leafiness: 39, order: 9, waviness: 4, simplicity: 0.2)
  proc draw() =
    let (x, y) = p.curve
    canvas.plot(w, h, x, y)
  sidebar.slider("Leafiness", 0, 100, 39, onInput = proc (v: float) =
    p.leafiness = v.int; draw())
  sidebar.slider("Order", 0, 20, 9, onInput = proc (v: float) =
    p.order = v.int; draw())
  sidebar.slider("Waviness", 0, 10, 4, onInput = proc (v: float) =
    p.waviness = v.int; draw())
  sidebar.slider("Simplicity", 0, 1, 0.2, step = 0.01, onInput = proc (v: float) =
    p.simplicity = v; draw())
  draw()
