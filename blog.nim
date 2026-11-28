## The talk as a blog post (docs/blog.html): every slide of the deck, then what is said over
## it, from its speaker notes (blogpost.nim). Built with the deck, from the same slides:
## `buildDeck` (deck.nim) calls `buildBlogPost` once the deck is saved.
##
## In the slides, `speakerNote("...", blog = false)` keeps a note out of the blog post, and
## `blogNote "..."` adds text the blog post has and the deck does not.
import nimib
import page, blogpost

const ownSource = staticRead("blog.nim")

template buildBlogPost*() =
  ## the blog post of the deck in `nb`, after the deck is saved
  nbSaveAsBlogPost("blog.nim", "Sailing Seas of Scientific Nim", "slides.html",
                   slideImages = "images/blog"):
    nb.usePage(ownSource)
    nb.title = "Sailing Seas of Scientific Nim · the talk as a blog post"
    nbEyebrow "Compute Paris · 26 November 2026 · [the slides](slides.html)"
    nbText "# Sailing Seas of Scientific Nim"
    nbLede """
The talk, slide by slide, with what I say over each slide.
"""
    nbText """
I gave this talk at
[Compute Paris 2026](https://pretalx.com/compute-paris-2026/talk/8EM8ZA/),
in the session *A Babel of Compilers*.
The text under each slide comes from the speaker notes
of the deck, so it reads like someone talking.
The slides are live: tap the caption under one
to open the deck at that slide.
"""
