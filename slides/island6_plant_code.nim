## The Karax code of the plant app (island6_plant_app.nim), as code you drag:
## the lines of the sliders are a sortable list of zogyn (declarative dragging,
## github.com/pietroppeter/zogyn), and the app shows its sliders in their order.
## `karaxCode` runs on any backend (the slide shows it, with nbCodeStage);
## `plantCode` is JavaScript only: it turns that code into a stage of zogyn.
import std / strutils

const karaxCode* = block:
  ## the Karax part of the app: the html of the app, from its state
  const source = staticRead("island6_plant_app.nim")
  let lines = source.split("  proc render(): VNode =\n")[1].split("  proc draw()")[0]
  ("  proc render(): VNode =\n" & lines).dedent.strip

when defined(js):
  import std / [dom, math]
  import zogyn, zogyn / stage

  const
    lines = karaxCode.splitLines
    lh = 22.0                                 # a line, in units of the stage
    pad = 6.0
  var html: seq[string]                       # the lines, as highlighted on the page
  let first = block:
    var i = 0
    while not lines[i].strip.startsWith("slider("): inc i
    i                                         # the first line of a slider

  proc lineSvg(i: int, handle: bool): string =
    ## line `i` of the code: text with the classes of the highlighter, as tspans,
    ## and a handle under the lines you can drag
    if handle: result.add "<rect class=\"handle\" x=\"0\" y=\"" & $(-lh + 5) &
      "\" width=\"100%\" height=\"" & $lh & "\" rx=\"4\"/>"
    let tspans = html[i].multiReplace(("<span ", "<tspan "), ("</span>", "</tspan>"))
    result.add "<text x=\"" & $pad & "\" xml:space=\"preserve\">" & tspans & "</text>"

  proc renderCode(order: seq[int]): seq[Item] =
    ## the code with the slider lines in `order`
    for i in 0 ..< lines.len:
      let isSlider = i in first ..< first + order.len
      let at = if isSlider: first + order.find(i - first) else: i
      result.add Item(key: $i, pos: vec(0, pad + lh * float(at + 1)),
                      svg: lineSvg(i, isSlider))

  proc codeSpec(order: seq[int], key: string): Behavior[seq[int]] =
    ## a slider line moves to any place among the slider lines; the others stay
    let i = parseInt(key) - first
    if i in 0 ..< order.len: closest(order.reorderings(i)) else: nil

  # the bounds of the sliders are numbers you scrub, as in Bret Victor's
  # explorable explanations (dry run 1, 2026-11-26): press on a 0 or a 100 in the
  # code and move left or right, the number changes by one and the slider with it
  const
    numSpan = "<span class=\"hljs-number\">"
    sliderStep = [1.0, 1.0, 1.0, 0.01]     # the steps of the sliders, as in the app
  var
    tmpl: seq[string]                       # the lines, with a mark where a bound goes
    bound: array[4, array[2, int]]          # the bounds of each slider, as in the code

  proc fillLine(i: int) =
    html[i] = tmpl[i]
    for k in 0 ..< 4:
      for b in 0 .. 1:
        html[i] = html[i].replace("@" & $k & $b & "@", $bound[k][b])

  proc scrubbable() =
    ## marks the first two numbers of each slider line (its bounds) as scrubbable
    tmpl = html
    for k in 0 ..< 4:
      let i = first + k
      var line = html[i]
      var at = 0
      for b in 0 .. 1:
        at = line.find(numSpan, at)
        let close = line.find("</span>", at)
        bound[k][b] = parseInt(line[at + numSpan.len ..< close])
        let marked = "<span class=\"hljs-number scrub\" data-k=\"" & $k & "\" data-b=\"" & $b & "\">@" & $k & $b & "@"
        line = line[0 ..< at] & marked & line[close .. ^1]
        at += marked.len
      tmpl[i] = line.replace("slider(", "<span class=\"slider-word\">slider</span>(") # orange on hover

  proc closestScrub(e: EventTarget): Element {.importjs: "((e) => e.closest ? e.closest('.scrub') : null)(#)".}
  proc dataInt(e: Element, name: cstring): int {.importjs: "parseInt(#.getAttribute(#))".}

  proc setBound(appId: string, k, b, v: int) =
    ## the k-th slider of the app in the element with id `appId` gets its bound b
    ## (0 min, 1 max) set to v; an input event updates the plant if its value moved
    let inputs = document.querySelectorAll(cstring("#" & appId & " .sidebar input"))
    if k >= inputs.len: return
    let input = inputs[k]
    input.setAttribute(cstring(if b == 0: "min" else: "max"), cstring($int(round(v.float / sliderStep[k]))))
    input.dispatchEvent(newEvent("input"))

  proc plantCode*(id: string, setOrder: proc (order: seq[int]), w = 420.0, appId = "plant") =
    ## the code shown in the element with id `id` (nbCodeStage), made a stage
    ## w units wide: while a slider line is dragged, `setOrder` gets the order
    ## of the sliders on screen, so the sliders move with it; the bounds in the
    ## code scrub the bounds of the sliders of the app in `appId`
    html = ($document.getElementById(cstring(id)).querySelector("code").innerHTML).splitLines
    scrubbable()
    for k in 0 ..< 4: fillLine(first + k)
    let st = mount(id, w, lh * float(lines.len) + 2 * pad, @[0, 1, 2, 3],
                   renderCode, codeSpec, toggle = false)
    st.onMove = proc () = setOrder(st.shown) # the sliders follow the line while it is dragged
    var (sk, sb, x0, v0) = (-1, 0, 0, 0)
    let host = document.getElementById(cstring(id))
    host.addEventListener("pointerdown", proc (ev: Event) =
      let t = closestScrub(ev.target)
      if t.isNil: return
      ev.stopPropagation() # not a line to drag
      ev.preventDefault()
      (sk, sb) = (t.dataInt("data-k"), t.dataInt("data-b"))
      (x0, v0) = (MouseEvent(ev).clientX, bound[sk][sb]), true)
    document.addEventListener("pointermove", proc (ev: Event) =
      if sk < 0: return
      var v = v0 + (MouseEvent(ev).clientX - x0) div 8
      if sb == 0: v = min(v, bound[sk][1] - 1) # negative too (Pietro: what does a negative simplicity do?)
      else: v = max(v, bound[sk][0] + 1)
      if v == bound[sk][sb]: return
      bound[sk][sb] = v
      fillLine(first + sk)
      st.refresh()
      setBound(appId, sk, sb, v))
    document.addEventListener("pointerup", proc (ev: Event) = sk = -1)
