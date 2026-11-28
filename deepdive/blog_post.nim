import std / strutils
import nimib
import nimiSlides except speakerNote # blogpost.nim has its own
import deepdive # useDeepDive, and the blocks of blocks.nim
import ../blogpost

# A deep dive on the talk as a blog post (blog.nim, docs/blog.html) and the module that
# makes it (blogpost.nim, meant for nimiSlides):
#   nim r deepdive/blog_post.nim
# The code shown is read from blogpost.nim when the page is built, so it never goes stale:
# an excerpt whose first line is not found anymore stops the build.

nbInit(thisFileRel = "deepdive/blog_post.nim")
const ownSource = staticRead("blog_post.nim")
nb.useDeepDive("blog_post", ownSource)

const moduleSource = staticRead("../blogpost.nim")

proc excerpt(first: string, until = ""): string =
  ## the lines of blogpost.nim from the one starting with `first` to the first blank line
  ## (or, with `until`, to the line before the one starting with it)
  let lines = moduleSource.splitLines
  var a = -1
  for i, line in lines:
    if line.startsWith(first):
      a = i
      break
  doAssert a >= 0, "deep dive: not found in blogpost.nim: " & first
  var b = a
  while b + 1 < lines.len:
    let next = lines[b + 1]
    if until.len > 0:
      if next.startsWith(until): break
    elif next.strip.len == 0: break
    inc b
  while b > a and lines[b].strip.len == 0: dec b
  lines[a .. b].join("\n")

nbText """
After the talk I wanted it as something to read,
not only as slides: the [blog post](../blog.html)
shows every slide, then what I say over it.
What I say is already written down, in the speaker notes,
so the blog post is built from the deck itself,
with the deck, by the same program.
And since a blog post gets read, it has a review mode:
a comment on a sentence goes back to the speaker note
in the slide's source, so reviewing the blog post
is how the notes get fixed.

This page is about how it works.
The code lives in `blogpost.nim`, which needs only nimib
and nimiSlides: the idea is to move it into nimiSlides.

## Writing it: notes, blog notes, after the talk

In a slide nothing changes: `speakerNote` writes the notes
that reveal.js shows in its speaker view (press `s`),
and they also become the text of the slide in the blog post.
Two things are new.
A note can stay out of the blog post, with `blog = false`
(for "no time here, skip"), and `blogNote` writes text
that only the blog post has, inside a slide or between two.
With a label, it is set apart: this talk uses it for
*After the talk* boxes (`afterTheTalk` in `my.nim`).
"""

nbShowCode """
slide:
  nbText "## Why still niche?"
  speakerNote \"\"\"
My opinionated view...
\"\"\"
  speakerNote("(30 seconds left: skip this one.)", blog = false)
  afterTheTalk \"\"\"
Mamy called me out on compile times during the talk...
\"\"\"
"""

nbText """
Then, after the deck is saved, one call builds the page:
a title, a setup for the page (its theme, an opening),
and the deck's address, for the links and the frames.
This is the whole of `blog.nim`, minus the text:
"""

nbShowCode """
nbSaveAsBlogPost("blog.nim", "Sailing Seas of Scientific Nim", "slides.html",
                 slideImages = "images/blog"):
  nb.usePage(ownSource)
  nbText "# Sailing Seas of Scientific Nim"
  nbLede "The talk, slide by slide, with what I say over each slide."
"""

nbText """
## Notes that remember where they were written

nimiSlides' `speakerNote` writes the notes as raw HTML:
once the deck is built they are just a string in a block,
and nobody knows anymore which file they came from.
The new `speakerNote` is a block of its own that keeps
its markdown, and the file and line of the call,
from `instantiationInfo`. In the deck it writes exactly
the same HTML as before, so the deck does not change.
"""

nbShowCode excerpt("newNbBlock(NbSpeakerNote)", "newNbBlock(NbBlogNote)")

nbText """
`instantiationInfo(-1)` gives the place of the call to the
template, and a Nim node keeps the line where it was written
even when the call is inside another template
(every slide of this deck is one, expanded in `deck.nim`):
so the line is the line in `slides/`, where the note is.

The price, until this is in nimiSlides: two templates named
`speakerNote` with the same arguments are an ambiguous call.
So the modules that use it import
`nimiSlides except speakerNote`; the slide templates are
expanded in `deck.nim` and `all.nim`, which do the same.

## From blocks to a blog post

A built deck is a tree of nimib blocks.
At the top, one `NbSlide` per column of reveal.js;
a slide that holds slides is a vertical stack.
`blogSlides` walks it and, for every slide, keeps its
place in the deck (`#/h/v`, the address reveal.js uses),
its first heading, and its notes for the blog, in order.
Here it is on a small deck made by hand:
"""

nbCode:
  let deck = NbDoc(kind: "NbDoc")
  let title = newNbSlide(slideNumber = 1, options = slideOptions())
  title.blocks.add newNbText(text = "# A tiny talk")
  title.blocks.add newNbSpeakerNote(text = "Hello!", file = "slides/tiny.nim",
                                    line = 3, inBlog = true)
  deck.blocks.add title
  let stack = newNbSlide(slideNumber = 2, options = slideOptions())
  for i, (heading, note) in [("## First", "One thing."), ("## Second", "Another.")]:
    let s = newNbSlide(slideNumber = 3 + i, options = slideOptions())
    s.blocks.add newNbText(text = heading)
    s.blocks.add newNbSpeakerNote(text = note, file = "slides/tiny.nim",
                                  line = 10 + 5 * i, inBlog = true)
    stack.blocks.add s
  deck.blocks.add stack
  for s in blogSlides(deck):
    echo s.n, " #/", s.h, "/", s.v, " ", s.title, ": ",
      s.texts[0].text, " (", s.texts[0].source, ")"

nbText """
Then each slide becomes a block of the page,
with its notes as blocks inside it.
`nbSaveAsBlogPost` starts a second nimib document
(a second `nbInit`, in a block of its own, so it
does not clash with the deck's `nb`), runs the setup,
adds the slides and saves.

## Showing a slide: a screenshot, or the deck itself

A slide is not easy to show outside reveal.js: it needs
the deck's style, its scripts, its fonts and its scale.
So the blog post does not try. It shows either a screenshot,
or the deck itself, in a frame, at that slide.

The frame works with no extra step: reveal.js reads
its settings from the address too, after its own,
so the deck is the same file with no controls,
no keys taken from the page and every fragment shown.
(One setting I tried, `embedded=true`, leaves the slide blank.)
"""

nbShowCode excerpt("const frameQuery")

nbText """
A deck with fifty slides is fifty frames, each running
the whole deck, so frames load only when they come near
the screen and unload when they leave it.

Screenshots are lighter and better for a blog post,
but someone has to take them: `scripts/blog-shots.sh`
opens every slide in headless Chromium at the deck's size
(1050 by 700 pixels, Quarto's proportions), with the same
settings in the address, and writes `<h>-<v>.webp`
(about 5 MB for this talk; png is four times as much).
The blog post uses a screenshot where there is one,
and a frame where there is none:
"""

nbShowCode excerpt("    if slideImages.len > 0:")

nbText """
## Review mode, back to the slides

Every page of this site has a review mode
([how it works](../devlog/index.html)): select words,
comment, export the comments as one text for a coding
agent, which applies them with a skill.
On the blog post the words are speaker notes, written
in `slides/`, not in `blog.nim`. So every note on the page
says where it was written, in an attribute,
and every slide says which slide it is:
"""

nbShowCode("""
<section class="blog-slide" data-where="Slide 11 · Reads like Python, runs like C">
  <figure>...</figure>
  <div class="blog-text" data-origin="slides/island1_performance.nim:73">
    <p>(Very little time here.) The main value proposition...</p>
  </div>
</section>
""", lang = "html")

nbText """
The review script (`docs/assets/review.js`) knows nothing
about slides: it only looks for the nearest element
with `data-origin` or `data-where` around the words a
comment is on. Then the export says where to edit
(`nimib-review/6`):
"""

nbShowCode("""
## 8. In “Slide 11 · Reads like Python, runs like C”

Written in `slides/island1_performance.nim:73` (edit it there, not in the page's source).

> before

Around it: “… of people like Mamy, who talks ⟦before⟧ me, Nim is one of the languages…”

After
""", lang = "markdown")

nbText """
That is a real comment, from the first review of the
blog post: Mamy talked after me, not before.
The `nimib-review` skill opens the file at that line,
finds the words and fixes the note; the deck's speaker
view and the blog post change together.

## What is left for nimiSlides

To go upstream, `speakerNote` would become this block in
nimiSlides (no more `except`), and `blogNote`,
`nbSaveAsBlogPost` and the frame settings would come with it.
The style of the page and the review mode stay with
whoever uses it: here, `usePage` in the setup.
Screenshots need a browser, so they stay a script,
and a deck without them still gets a blog post.
"""

nbSave
