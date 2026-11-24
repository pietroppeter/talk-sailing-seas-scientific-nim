## What every nimib page (deep dives, talk log) starts with, after nbInit:
##
##   const ownSource = staticRead("my_page.nim")
##   nb.usePage(ownSource)
##
## assets from docs/assets (offline.nim), the style (talkstyle.nim), and the source for "Show Source"
## (nimib cannot find it when thisFileRel puts the page in docs/ and not docs/slides/).
## Exports the blocks of blocks.nim.
import std / json
import nimib
import offline, talkstyle, blocks
export offline, talkstyle, blocks

proc usePage*(nb: var Nb, ownSource = "") =
  nb.useOfflineAssets
  nb.useTalkStyle
  if ownSource.len > 0:
    nb.doc.source = ownSource
    nb.doc.context["source"] = %ownSource
    nb.doc.context["source_highlighted"] = %highlightNim(ownSource)
