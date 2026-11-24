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
  import std / dom
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

  proc plantCode*(id: string, setOrder: proc (order: seq[int]), w = 420.0) =
    ## the code shown in the element with id `id` (nbCodeStage), made a stage
    ## w units wide: while a slider line is dragged, `setOrder` gets the order
    ## of the sliders on screen, so the sliders move with it
    html = ($document.getElementById(cstring(id)).querySelector("code").innerHTML).splitLines
    let st = mount(id, w, lh * float(lines.len) + 2 * pad, @[0, 1, 2, 3],
                   renderCode, codeSpec, toggle = false)
    st.onMove = proc () = setOrder(st.shown) # the sliders follow the line while it is dragged
