## Builds the talk's pages into docs/ (needs `atlas install` first):
##
##   nim r build.nim                      everything, as the pages workflow does
##   nim r build.nim slides               the deck, the style test deck (my.html), the Thank You slide, the easter egg
##   nim r build.nim explainers           every slides/*_explainer.nim
##   nim r build.nim devlog               every talk log post, then the talk log index
##   nim r build.nim themes               the deck once per explored theme (docs/index_<theme>.html)
##   nim r build.nim check                only check that no built page loads anything from the network
##   nim r build.nim slides explainers    groups combine
##
## slides, explainers and devlog are built by one program (all.nim): one compile, however many
## pages. Each theme is a compile of its own (the theme is chosen at compile time). Every build
## ends with the check. Flags after `--` go to nim: `nim r build.nim explainers -- -d:release`.
import std / [os, osproc, strutils, re, sets, sequtils]

const
  pageGroups = ["slides", "explainers", "devlog"]
  themes = ["pirate", "book", "chart"]

proc run(cmd: string) =
  echo "== ", cmd
  if execCmd(cmd) != 0: quit "build: failed: " & cmd, 1

proc nimFlags(extra: seq[string]): string =
  (@["--hints:off"] & extra).mapIt(quoteShell(it)).join(" ")

proc check(): bool =
  ## true when no built page loads a script, a stylesheet, a font or an image from another site,
  ## directly or through a stylesheet it links (@import, url()): everything is in docs/assets/
  ## (scripts/vendor-assets.sh), so the pages work offline. Links to other sites are fine.
  let
    remote = r"(?:https?:)?//[^""' >)]+"
    tagRe = re("<(?:script|link|img|iframe|source|video|audio)[^>]*?(?:src|href)=[\"']?(" & remote & ")")
    cssRe = re("(?:url\\(|@import)[\"' ]*(" & remote & ")")
    linkRe = re("<link[^>]*href=[\"']([^\"']+\\.css)")
  var found: seq[string]
  var sheets: HashSet[string]
  for page in walkDirRec("docs"):
    if not page.endsWith(".html"): continue
    let html = readFile(page)
    for m in html.findAll(tagRe): found.add page & ": " & m
    for m in html.findAll(cssRe): found.add page & ": " & m
    var start = 0
    var caps: array[1, string]
    while (let at = html.find(linkRe, caps, start); at >= 0):
      start = at + 1
      if not caps[0].contains("//"): sheets.incl normalizedPath(page.parentDir / caps[0])
  for css in sheets:
    if fileExists(css):
      for m in readFile(css).findAll(cssRe): found.add css & ": " & m
  if found.len > 0:
    echo "== pages that load something from the network (vendor it in docs/assets/):"
    for f in found: echo f
    return false
  echo "== check: no page loads anything from the network"
  true

when isMainModule:
  setCurrentDir(currentSourcePath().parentDir)
  var groups, extra: seq[string]
  var afterDashes = false
  for a in commandLineParams():
    if afterDashes: extra.add a
    elif a == "--": afterDashes = true
    else: groups.add a
  if groups.len == 0 or "all" in groups:
    groups = @pageGroups & @["themes", "check"]
  for g in groups:
    if g notin pageGroups and g notin ["themes", "check"]:
      quit "build: unknown group " & g & " (slides, explainers, devlog, themes, check, all)", 2
  let pages = groups.filterIt(it in pageGroups)
  if pages.len > 0:
    run "nim r " & nimFlags(extra) & " -d:only=" & pages.join(",") & " all.nim"
  if "themes" in groups:
    for t in themes:
      run "nim r " & nimFlags(extra) & " -d:slideTheme=" & t & " all.nim"
  if not check(): quit 1
