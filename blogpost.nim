## A deck as a blog post: every slide, then what is said over it (its speaker notes), as a
## page to read. Written for nimiSlides and kept free of the talk's own code (it needs only
## nimib and nimiSlides), so it can move upstream as it is.
##
## In the slides:
##
##   speakerNote """..."""                # in the deck's notes and in the blog post
##   speakerNote("...", blog = false)     # in the deck's notes only
##   blogNote """..."""                   # in the blog post only (nothing in the deck)
##   blogNote("...", "After the talk")   # set apart, under a small label
##
## `blogNote` also works between slides, outside any `slide:`, for text between two slides.
## Then, after the deck is built (and saved), with the deck's `nb`:
##
##   nbSaveAsBlogPost("blog.nim", title = "My talk", deckUrl = "slides.html"):
##     discard # the setup of the page: a theme, a style, an opening paragraph...
##
## builds a second nimib page (here `blog.nim`, written next to the deck as blog.html): the
## title, what the setup adds, then for every slide the slide itself and its notes. A slide
## is shown as a frame with the deck at that slide (reveal.js reads its settings from the
## address: no controls, every fragment shown), or as a screenshot: `slideImages` names a
## folder (relative to the page) with one `<h>-<v>.webp` (or .jpg, .png) per slide (reveal.js indices from 0,
## as in the deck's address `#/h/v`), and a slide with no screenshot falls back to the frame.
##
## Every note on the page says where it was written: `data-origin="slides/intro.nim:42"`, the
## file and line of its `speakerNote` or `blogNote` call, and every slide says which it is
## (`data-where`), so a review of the blog post (a review mode that reads these attributes)
## points back to the speaker notes in the slides' sources.
##
## Until it is in nimiSlides, a slide module that uses `speakerNote` imports
## `nimiSlides except speakerNote`, since nimiSlides' own `speakerNote` takes the same name.
import std / [strutils, strformat, os, json]
import nimib
import nimiSlides except speakerNote
import markdown

func esc(s: string): string =
  s.multiReplace(("&", "&amp;"), ("<", "&lt;"), (">", "&gt;"), ("\"", "&quot;"))

proc sourceOf(file: string, line: int, root: string): string =
  ## `file:line`, the file relative to `root` (the folder of nimib.toml) when it is inside it
  let rel = if root.len > 0 and file.isAbsolute and file.startsWith(root): file.relativePath(root) else: file
  rel.replace('\\', '/') & ":" & $line

# ------------------------------------------------------------------------------ in the deck

newNbBlock(NbSpeakerNote):
  text: string     ## markdown
  file: string     ## where `speakerNote` was called, for the blog post's review
  line: int
  inBlog: bool
  toHtml:
    # what nimiSlides' speakerNote writes: reveal.js shows it in the speaker view
    {.cast(noSideEffect).}: # markdown is not marked free of side effects
      "<aside class=\"notes\">\n  " & markdown(blk.text) & "\n</aside>\n"

template speakerNote*(ttext: string, blog = true) =
  ## the speaker notes of the slide (markdown), shown in reveal.js' speaker view (press `s`)
  ## and, unless `blog = false`, as the text of the slide in the blog post
  const at = instantiationInfo(-1, fullPaths = true)
  nb.add newNbSpeakerNote(text = ttext, file = at.filename, line = at.line, inBlog = blog)

newNbBlock(NbBlogNote):
  text: string
  label: string
  file: string
  line: int
  toHtml:
    "" # nothing in the deck

template blogNote*(ttext: string, tlabel = "") =
  ## text (markdown) for the blog post only, after the notes written before it in the slide;
  ## outside a slide, between the slides it is written between. With a label (such as
  ## "After the talk") it is set apart from the notes, under that label
  const at = instantiationInfo(-1, fullPaths = true)
  nb.add newNbBlogNote(text = ttext, label = tlabel, file = at.filename, line = at.line)

# ------------------------------------------------------------------------------ the slides

type
  BlogText* = object
    text*, source*: string ## markdown, and `file:line`
    label*: string         ## a blogNote's label: set apart under it
  BlogSlide* = object
    h*, v*: int            ## reveal.js indices: the deck's address is `#/h/v`
    n*: int                ## its number in the deck, from 1
    title*: string         ## the slide's first heading, if it has one
    texts*: seq[BlogText]  ## its notes for the blog, in order
    between*: bool         ## true: not a slide, the text between two slides

proc firstHeading(blocks: seq[NbBlock]): string =
  for b in blocks:
    if b of NbSlide: continue
    if b of NbText:
      for line in NbText(b).text.strip.splitLines:
        if line.startsWith("#"):
          return line.strip(chars = {'#', ' '}).replace("*", "").replace("`", "")
    if b of NbContainer:
      let t = firstHeading(NbContainer(b).blocks)
      if t.len > 0: return t

proc collectTexts(blocks: seq[NbBlock], root: string, into: var seq[BlogText]) =
  ## the notes of a slide, nested blocks (columns, fragments) included, not those of its own slides
  for b in blocks:
    if b of NbSlide: continue
    if b of NbSpeakerNote:
      let n = NbSpeakerNote(b)
      if n.inBlog: into.add BlogText(text: n.text, source: sourceOf(n.file, n.line, root))
    elif b of NbBlogNote:
      let n = NbBlogNote(b)
      into.add BlogText(text: n.text, label: n.label, source: sourceOf(n.file, n.line, root))
    elif b of NbContainer:
      collectTexts(NbContainer(b).blocks, root, into)

proc blogSlides*(deck: NbDoc, root = ""): seq[BlogSlide] =
  ## the slides of a deck in order, with their notes for the blog. A slide that holds slides
  ## is a vertical stack: its own notes go with its first slide.
  var h, n = 0
  for b in deck.blocks:
    if b of NbSlide:
      let s = NbSlide(b)
      var outer: seq[BlogText]
      collectTexts(s.blocks, root, outer)
      var v = 0
      for inner in s.blocks:
        if inner of NbSlide:
          let i = NbSlide(inner)
          var texts = (if v == 0: outer else: @[])
          collectTexts(i.blocks, root, texts)
          inc n
          result.add BlogSlide(h: h, v: v, n: n, title: firstHeading(i.blocks), texts: texts)
          inc v
      if v == 0:
        inc n
        result.add BlogSlide(h: h, v: 0, n: n, title: firstHeading(s.blocks), texts: outer)
      inc h
    elif b of NbBlogNote:
      let n = NbBlogNote(b)
      result.add BlogSlide(h: h, between: true,
                           texts: @[BlogText(text: n.text, label: n.label, source: sourceOf(n.file, n.line, root))])

# ------------------------------------------------------------------------------ on the page

const blogPostCss* = """
/* a deck as a blog post (blogpost.nim): a slide, at the deck's proportions, then its notes */
.blog-slide { margin: 2.2rem 0; }
.blog-slide figure { margin: 0 0 .8rem; }
.blog-slide .slide-view { display: block; width: 100%; aspect-ratio: var(--slide-ratio, 3 / 2); border: 1px solid #ccc;
  border-radius: 4px; background: #fff; }
.blog-slide img.slide-view { height: auto; object-fit: contain; }
.blog-slide figcaption { font-size: .85rem; opacity: .75; margin-top: .3rem; }
/* a blogNote with a label (After the talk): set apart from what was said */
.blog-aside { margin: 1.2rem 0; padding: .2rem 1rem .4rem; border-left: 4px solid currentColor; background: rgba(127, 127, 127, .08); }
.blog-aside-label { margin: .5rem 0 .2rem; font-size: .8rem; font-weight: 700; letter-spacing: .08em; text-transform: uppercase; opacity: .75; }
"""

## the deck's settings in its address, read by reveal.js over its own: the slide as it is at its
## last fragment, nothing to click, no keys taken from the page
const frameQuery* = "?controls=false&progress=false&slideNumber=false&fragments=false" &
  "&keyboard=false&touch=false&overview=false&help=false&mouseWheel=false&hash=false&history=false"

newNbBlock(NbBlogSlide of NbContainer):
  deckUrl: string
  image: string    ## the screenshot, or "" for the frame
  h: int
  v: int
  n: int
  title: string
  toHtml:
    let label = &"Slide {blk.n}" & (if blk.title.len > 0: " · " & blk.title else: "")
    let at = &"#/{blk.h}/{blk.v}"
    let view =
      if blk.image.len > 0:
        &"""<img class="slide-view" src="{esc(blk.image)}" alt="{esc(label)}" loading="lazy">"""
      else:
        &"""<iframe class="slide-view" data-src="{esc(blk.deckUrl & frameQuery & at)}" title="{esc(label)}" loading="lazy" tabindex="-1"></iframe>"""
    &"""<section class="blog-slide" id="slide-{blk.h}-{blk.v}" data-where="{esc(label)}">""" & "\n" &
      &"""<figure>{view}<figcaption><a href="{esc(blk.deckUrl & at)}">{esc(label)}</a></figcaption></figure>""" & "\n" &
      nbContainerToHtml(blk, nb) & "\n</section>"

newNbBlock(NbBlogText):
  text: string
  source: string
  label: string
  toHtml:
    if blk.label.len > 0:
      &"""<aside class="blog-aside" data-origin="{esc(blk.source)}"><p class="blog-aside-label">{esc(blk.label)}</p>""" &
        "\n" & markdownToHtml(blk.text) & "\n</aside>"
    else:
      &"""<div class="blog-text" data-origin="{esc(blk.source)}">""" & "\n" & markdownToHtml(blk.text) & "\n</div>"

## Frames load when they come near the screen and unload when they are far from it, so a long
## deck does not run all its slides at once.
const frameScript = """<script>
(function () {
  var frames = document.querySelectorAll('iframe.slide-view[data-src]');
  if (!('IntersectionObserver' in window)) { frames.forEach(function (f) { f.src = f.dataset.src; }); return; }
  var near = new IntersectionObserver(function (entries) {
    entries.forEach(function (e) {
      var f = e.target, want = e.isIntersecting ? f.dataset.src : 'about:blank';
      if (f.getAttribute('src') !== want) f.setAttribute('src', want);
    });
  }, { rootMargin: '150% 0px' });
  frames.forEach(function (f) { near.observe(f); });
})();
</script>"""

newNbBlock(NbBlogFrames):
  toHtml:
    frameScript

proc addBlogSlides*(nb: var Nb, slides: seq[BlogSlide], deckUrl: string, slideImages = "") =
  ## the slides and their notes, as blocks of the page `nb`
  for s in slides:
    if s.between:
      for t in s.texts: nb.add newNbBlogText(text = t.text, source = t.source, label = t.label)
      continue
    var image = ""
    if slideImages.len > 0:
      for ext in ["webp", "jpg", "png"]:
        let candidate = slideImages & "/" & &"{s.h}-{s.v}.{ext}"
        if fileExists(nb.doc.homeDir.string / nb.doc.filename.parentDir / candidate):
          image = candidate
          break
    let blk = newNbBlogSlide(deckUrl = deckUrl, image = image, h = s.h, v = s.v, n = s.n, title = s.title)
    for t in s.texts: blk.blocks.add newNbBlogText(text = t.text, source = t.source, label = t.label)
    nb.add blk
  nb.add newNbBlogFrames()

template nbSaveAsBlogPost*(sourceFileRel, ttitle, tdeckUrl: string, slideImages = "", setup: untyped) =
  ## The deck of the current `nb` (built, best saved first) as a blog post: a nimib page of its
  ## own for the source file `sourceFileRel` (it names the page, docs/blog.html for blog.nim),
  ## with the title `ttitle`, then `setup` (run on the new page's `nb`: a theme, a style, an
  ## opening), then the slides, each with its notes. `tdeckUrl` is the deck's address from
  ## the page; `slideImages` a folder of screenshots (see the top of this module).
  block:
    let deckDoc = nb.doc
    nbInit(thisFileRel = sourceFileRel)
    let slides = blogSlides(deckDoc, nb.doc.srcDir.string)
    nb.doc.context["title"] = %ttitle
    setup
    nb.doc.context["stylesheet"] = %(nb.doc.context{"stylesheet"}.getStr & "\n<style>\n" & blogPostCss & "</style>")
    nb.addBlogSlides(slides, tdeckUrl, slideImages)
    nbSave
