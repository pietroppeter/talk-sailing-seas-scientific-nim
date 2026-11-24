## What every nimib page (deep dives, talk log) starts with, after nbInit:
##
##   const ownSource = staticRead("my_page.nim")
##   nb.usePage(ownSource)
##
## assets from docs/assets (offline.nim), the style (talkstyle.nim), the review mode (review.nim)
## and the source for "Show Source"
## (nimib cannot find it when thisFileRel puts the page in docs/ and not docs/slides/).
## Exports the blocks of blocks.nim.
import std / json
import nimib
import offline, talkstyle, blocks, review
export offline, talkstyle, blocks, review

proc usePage*(nb: var Nb, ownSource = "", withReview = true) =
  ## `withReview = false` leaves out the review mode (review.nim): a version line and **✎ Review**
  ## under the lede or the title, to comment on the page and export the comments
  nb.useOfflineAssets
  nb.useTalkStyle
  if withReview:
    nb.review(script = nb.doc.relToRoot("assets/review.js"))
  if ownSource.len > 0:
    nb.doc.source = ownSource
    nb.doc.context["source"] = %ownSource
    nb.doc.context["source_highlighted"] = %highlightNim(ownSource)
