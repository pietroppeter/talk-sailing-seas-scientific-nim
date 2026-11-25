## The custom blocks of the talk's pages: the slides (through my.nim), the deep dives and the talk log.
## Pages say *what* they show with these blocks and with nimib's own (nbText, nbCode, nbDiv, ...),
## never with HTML: `nbRawHtml` is a last resort, for a one-off, with a comment saying why.
## The blocks write classes, never styles; the classes are styled in talkstyle.nim (pages) and
## my.nim (slides). See the nimib-blocks skill.
import std / [strformat, strutils, xmltree]
import nimib
import nimib / highlight

func inlineMd(md: string): string =
  ## markdown without the paragraph around it, for a line of text inside a block
  {.cast(noSideEffect).}:
    markdownToHtml(md).strip.replace("<p>", "").replace("</p>", "")

# ------------------------------------------------------------------------------- code shown, not run

newNbBlock(NbShowCode):
  html: string      # the code, highlighted (Nim) or escaped (other languages, highlighted in the browser)
  lang: string
  caption: string   # markdown, e.g. the file and the lines it comes from
  toHtml:
    # Nim is highlighted when the page is built; other languages by highlight.js in the browser
    let cls = if blk.lang == "nim": "nohighlight nim hljs" else: "language-" & blk.lang
    # data-noescape: reveal.js' highlight plugin would escape the html of the highlighted code
    result = &"""<pre><code class="{cls}" data-noescape>{blk.html}</code></pre>"""
    if blk.caption.len > 0:
      result.add &"""
<p class="code-caption">{inlineMd(blk.caption)}</p>"""

const codeLanguageCss* = """
/* a small tag in the top right corner of every code block, saying its language:
   nbCode and nbShowCode (Nim, highlighted when the page is built), and nbShowCode
   with lang = "python" or "julia" (highlighted in the browser) */
pre:has(> code) { position: relative; }
/* the tag gets a line of its own above the code, so it never covers it (also on a phone) */
pre:has(> code.nim), pre:has(> code.language-nim), pre:has(> code.python),
pre:has(> code.language-python), pre:has(> code.language-julia) { padding-top: 1.1em; }
pre:has(> code.nim)::before, pre:has(> code.language-nim)::before,
pre:has(> code.python)::before, pre:has(> code.language-python)::before,
pre:has(> code.language-julia)::before {
  position: absolute; top: 0.2em; right: 0.6em; z-index: 1;
  font-family: system-ui, sans-serif; font-size: 0.7em; line-height: 1.2;
  opacity: 0.6; pointer-events: none;
}
pre:has(> code.nim)::before, pre:has(> code.language-nim)::before { content: "👑 Nim"; }
pre:has(> code.python)::before, pre:has(> code.language-python)::before { content: "🐍 Python"; }
pre:has(> code.language-julia)::before { content: "🤹 Julia"; }
"""
  ## used by the pages (talkstyle.nim) and the slides (my.nim)

proc showCode*(nb: var Nb, code: string, lang = "nim", caption = "") =
  let html = if lang == "nim": highlightNim(code.strip) else: xmltree.escape(code.strip)
  nb.add newNbShowCode(html = html, lang = lang, caption = caption)

template nbShowCode*(code: string, lang = "nim", caption = "") =
  ## code that is shown and not run (a snippet quoted from another project, or read from a file),
  ## highlighted when the page is built; `caption` (markdown) goes under it
  nb.showCode(code, lang, caption)

newNbBlock(NbCodeStage):
  id: string
  html: string      # the code, highlighted
  toHtml:
    &"""<div id="{blk.id}" class="code-stage hljs"><pre><code class="nohighlight nim hljs" data-noescape>{blk.html}</code></pre></div>"""

template nbCodeStage*(stageId: string, code: string) =
  ## Nim code you can drag: shown highlighted, then a script compiled to JavaScript
  ## (nbJsFromCode) turns it into a stage of zogyn, as slides/island6_plant_code.nim does
  nb.add newNbCodeStage(id = stageId, html = highlightNim(code.strip))

# ------------------------------------------------------------------------------------------ figures

newNbBlock(NbImg):
  url: string
  width: string
  caption: string
  alt: string
  toHtml:
    let width = if blk.width.len > 0: &""" width="{blk.width}"""" else: ""
    result = &"""<figure>
<img src="{blk.url}" alt="{xmltree.escape(blk.alt)}"{width}>"""
    if blk.caption.len > 0:
      result.add &"""
<figcaption>{inlineMd(blk.caption)}</figcaption>"""
    result.add "\n</figure>"

func img*(nb: var Nb, url: string, width = "", caption = "", alt = "") =
  let blk = newNbImg(url = nb.doc.relToRoot(url), width = width, caption = caption,
    alt = if alt.len == 0: caption else: alt)
  nb.add blk

template nbImg*(url: string, width = "", caption = "", alt = "") =
  ## an image (path relative to docs/) with an optional width and a caption (markdown)
  nb.img(url, width, caption, alt)

type Shot* = object
  ## a picture in a gallery, linked to itself
  url*, alt*: string

newNbBlock(NbGallery):
  shots: seq[Shot]
  toHtml:
    result = """<div class="gallery">"""
    for s in blk.shots:
      result.add &"""
<a href="{s.url}"><img src="{s.url}" alt="{xmltree.escape(s.alt)}"></a>"""
    result.add "\n</div>"

func gallery*(nb: var Nb, shots: openArray[Shot]) =
  var local: seq[Shot]
  for s in shots:
    local.add Shot(url: nb.doc.relToRoot(s.url), alt: s.alt)
  nb.add newNbGallery(shots = local)

template nbGallery*(shots: openArray[Shot]) =
  ## pictures side by side (two per row), each a link to itself (paths relative to docs/)
  nb.gallery(shots)

newNbBlock(NbFrame):
  url: string
  title: string
  caption: string
  toHtml:
    result = &"""<iframe class="frame" src="{blk.url}" title="{xmltree.escape(blk.title)}"></iframe>"""
    if blk.caption.len > 0:
      result.add &"""
<p class="code-caption">{inlineMd(blk.caption)}</p>"""

template nbFrame*(url, title: string, caption = "") =
  ## another page of the site, live inside this one (16:9), with a caption (markdown)
  nb.add newNbFrame(url, title, caption)

newNbBlock(NbDrawing):
  svg: string   # svg (or html) drawn by code, such as the maps of maps/
  class: string
  toHtml:
    &"""<div class="drawing {blk.class}">{blk.svg}</div>"""

template nbDrawing*(svg: string, class = "") =
  ## a drawing made by code (an svg string), in a box with the classes `class`
  nb.add newNbDrawing(svg, class)

type Swatch* = object
  ## a colour of a palette: the colour, the colour of text on it, a label
  color*, text*, label*: string

newNbBlock(NbSwatches):
  swatches: seq[Swatch]
  toHtml:
    result = """<div class="swatches">"""
    for s in blk.swatches:
      # the colours are what the block shows (data), so they are inline and not in the style module
      result.add &"""<span class="swatch" style="background:{s.color};color:{s.text}">{s.label} {s.color}</span>"""
    result.add "</div>"

template nbSwatches*(colors: openArray[Swatch]) =
  ## the colours of a palette, each with its label and hex value
  nb.add newNbSwatches(@colors)

# ------------------------------------------------------------------------------------------- p5nim

newNbBlock(NbSketch):
  id: string
  toHtml:
    &"""<div id="{blk.id}" class="sketch"></div>"""

template nbSketch*(id: string) =
  ## the element a p5nim sketch draws in (the sketch's `parent`), filled by nbJsFromCode
  nb.add newNbSketch(id)

newNbBlock(NbApp):
  id: string
  toHtml:
    &"""<div class="app"><div id="{blk.id}"></div></div>"""

template nbApp*(id: string) =
  ## the box of an app compiled to JavaScript (a sidebar and a canvas, see
  ## slides/island6_plant_app.nim): Karax replaces the inner element `id`, filled by nbJsFromCode
  nb.add newNbApp(id)

# ------------------------------------------------------------------------------------------ the map editor

newNbBlock(NbMapEditor):
  toHtml:
    """<div class="map-editor">
<div class="bar">
  <nav class="tabs" role="tablist">
    <button id="tab-edit" class="tab on" role="tab" aria-selected="true">Edit</button>
    <button id="tab-preview" class="tab" role="tab" aria-selected="false">Preview the slides</button>
  </nav>
  <div class="tools">
    <button id="undo" title="Undo (Ctrl+Z)">Undo</button>
    <button id="redo" title="Redo (Ctrl+Shift+Z)">Redo</button>
    <button id="reset" title="Back to the deck's map (maps/voyage.json)">Reset</button>
  </div>
</div>

<div class="layout">
  <section class="stage-wrap">
    <div id="stage" class="chart-stage editor-stage">
      <svg id="chart" class="voyage-map chart-map" viewBox="0 0 960 540" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <clipPath id="clip"><rect width="960" height="540"/></clipPath>
          <mask id="sea"><rect width="960" height="540" fill="white"/><g id="sea-mask"></g></mask>
        </defs>
        <g clip-path="url(#clip)">
          <rect class="paper" width="960" height="540"/>
          <g id="layer-depth"></g>
          <g id="layer-land"></g>
          <g id="layer-soundings" class="soundings"></g>
          <g id="layer-course" mask="url(#sea)"></g>
          <g id="layer-anchor"></g>
          <g id="layer-rose"></g>
        </g>
        <g id="layer-border"></g>
        <g id="layer-handles"></g>
      </svg>
      <div id="words"></div>
      <div id="portolano" class="portolano"><div class="pt-title">SEAS OF SCIENTIFIC NIM</div><div class="pt-head"></div><div class="pt-body"></div><span class="pt-resize" title="Drag to resize"></span></div>
      <div id="busy" class="busy" hidden>sounding…</div>
    </div>
    <div id="preview-controls" class="preview-controls" hidden>
      <button id="pv-prev" aria-label="Previous slide">◀</button>
      <div id="pv-steps" class="pv-steps"></div>
      <button id="pv-next" aria-label="Next slide">▶</button>
      <button id="pv-play">Play the voyage</button>
    </div>
    <p id="hint" class="hint"></p>
  </section>

  <aside class="panel">
    <section id="inspector" class="card">
      <h2 id="ins-title">Nothing selected</h2>
      <div id="ins-body"><p class="muted">Click an island, the coast, a turning point, an anchor or a name on the chart.</p></div>
    </section>

    <section class="card">
      <h2>Show</h2>
      <label class="check"><input type="checkbox" id="show-handles" checked> Handles</label>
      <label class="check"><input type="checkbox" id="show-soundings" checked> Soundings and rocks</label>
      <label class="check"><input type="checkbox" id="show-agenda"> Agenda bar</label>
      <label class="check"><input type="checkbox" id="show-portolano" checked> Portolano box (in place of the title block)</label>
      <label class="row">Current island
        <select id="current">
          <option value="0">0 · the whole map</option>
        </select>
      </label>
    </section>

    <section class="card">
      <h2>Portolano and agenda</h2>
      <label class="row">Text for <span id="pt-for">island 1</span></label>
      <textarea id="pt-text" rows="5" placeholder="A few lines to introduce this island"></textarea>
      <label class="row">Agenda bar height <input type="range" id="agenda-y" min="420" max="535" step="1"></label>
    </section>

    <section class="card">
      <h2>JSON</h2>
      <p class="muted">Copy it and paste it in the thread: it becomes <code>maps/voyage.json</code>, the map of the deck.</p>
      <div class="btns">
        <button id="copy" class="primary">Copy JSON</button>
        <button id="load">Load pasted JSON</button>
      </div>
      <textarea id="json" rows="10" spellcheck="false"></textarea>
      <p id="json-msg" class="muted" role="status"></p>
    </section>
  </aside>
</div>
</div>"""

template nbMapEditor*() =
  ## the map editor's chart, handles and panels (mapeditor.nim), empty: maps/editor/app.nim,
  ## compiled to JavaScript by nbJsFromCode, draws the chart and wires the controls by their ids;
  ## styled by `useMapEditorStyle` (talkstyle.nim)
  nb.add newNbMapEditor()

# -------------------------------------------------------------------------------------------- text

newNbBlock(NbLede):
  text: string
  class: string
  toHtml:
    &"""<p class="lede {blk.class}">{inlineMd(blk.text)}</p>"""

template nbLede*(text: string, class = "") =
  ## the paragraph that opens a page or a slide, larger (or smaller) than the text: markdown,
  ## one paragraph (a line ending with two spaces breaks the line)
  nb.add newNbLede(text, class)

newNbBlock(NbEyebrow):
  text: string
  toHtml:
    &"""<p class="eyebrow">{inlineMd(blk.text)}</p>"""

template nbEyebrow*(text: string) =
  ## the small line above a title (markdown), such as "Talk log · 7 November 2026"
  nb.add newNbEyebrow(text)

newNbBlock(NbQuote):
  text: string
  cite: string
  toHtml:
    &"""<figure class="quote"><blockquote>{inlineMd(blk.text)}</blockquote>
<figcaption>{inlineMd(blk.cite)}</figcaption></figure>"""

template nbQuote*(text, cite: string) =
  ## a quote (markdown) and who said it
  nb.add newNbQuote(text, cite)

const githubMark* = """<svg class="gh-mark" viewBox="0 0 16 16" aria-hidden="true"><path fill="currentColor" d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.28.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"/></svg>"""

newNbBlock(NbGithubTitle):
  title: string
  url: string
  label: string
  toHtml:
    &"""<h3>{blk.title} · <a href="{blk.url}">{githubMark}{blk.label}</a></h3>"""

template nbGithubTitle*(title, repo: string, label = "") =
  ## a title followed by a link to a GitHub profile or repository (`repo`: "brentp",
  ## "jcosborn/qex") with GitHub's logo; the link reads `label`, by default "@repo"
  nb.add newNbGithubTitle(title, "https://github.com/" & repo,
    if label.len > 0: label else: "@" & repo)

# ------------------------------------------------------------------------------------- navigation

type PageLink* = object
  ## a link to another page; an empty url means there is none
  url*, title*: string

newNbBlock(NbPager):
  prev: PageLink
  middle: PageLink
  next: PageLink
  toHtml:
    result = """<nav class="pager"><span>"""
    if blk.prev.url.len > 0: result.add &"""← <a href="{blk.prev.url}">{blk.prev.title}</a>"""
    result.add "</span><span>"
    if blk.middle.url.len > 0: result.add &"""<a href="{blk.middle.url}">{blk.middle.title}</a>"""
    result.add "</span><span>"
    if blk.next.url.len > 0: result.add &"""<a href="{blk.next.url}">{blk.next.title}</a> →"""
    result.add "</span></nav>"

template nbPager*(prev, middle, next: PageLink) =
  ## the links at the bottom of a page: previous, one in the middle, next
  nb.add newNbPager(prev, middle, next)

type PageItem* = object
  ## a page in a list of pages
  url*, title*, eyebrow*, summary*: string

newNbBlock(NbPageList):
  items: seq[PageItem]
  toHtml:
    result = """<ol class="page-list">"""
    for p in blk.items:
      result.add &"""
<li><span class="eyebrow">{p.eyebrow}</span><a href="{p.url}">{p.title}</a>
<p>{inlineMd(p.summary)}</p></li>"""
    result.add "\n</ol>"

template nbPageList*(items: openArray[PageItem]) =
  ## a list of pages (an index): title as a link, a small line above it and a summary (markdown)
  nb.add newNbPageList(@items)

newNbBlock(NbNote):
  text: string
  toHtml:
    {.cast(noSideEffect).}:
      result = """<div class="note">""" & markdownToHtml(blk.text) & "</div>"

template nbNote*(text: string) =
  ## an aside (markdown), set apart from the text with a coloured bar
  nb.add newNbNote(text)
