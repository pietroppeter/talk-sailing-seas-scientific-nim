## Builds the talk's pages into docs/ (needs `atlas install` first):
##
##   nim r build.nim                      everything, as the pages workflow does
##   nim r build.nim slides               the deck (slides.html), the style test deck (my.html), the Thank You slide, the easter egg
##   nim r build.nim deepdives            every deep dive (deepdive/*.nim), then the deep dives index
##   nim r build.nim devlog               every talk log post, then the talk log index
##   nim r build.nim themes               the deck once per explored theme (docs/slides_<theme>.html)
##   nim r build.nim looks                the deck and the style test deck in the earlier centered look (slides_centered.html, my_centered.html)
##   nim r build.nim check                only the checks: nothing loaded from the network, no broken link between pages,
##                                        no nbRawHtml, no `#>` note for Claude left (fails in CI, a warning locally)
##   nim r build.nim slides deepdives     groups combine
##   nim r build.nim island1              one part of the deck on its own (slides_island1.html), in the
##                                        deck's look: runs the `when isMainModule` of its module of slides/
##                                        (any of `deckParts`: intro, island1 to island7, conclusion, ...),
##                                        to review or publish one island
##
## Every build also exports the Shiny apps of shiny/ with shinylive into docs/shiny/
## (scripts/shinylive.sh), once: about 50 MB, not committed, and the first export needs
## the network. Offline and without them, a link to docs/shiny/ is only a warning outside CI.
##
## Any group also builds the site index (index.nim, docs/index.html), which lists everything.
##
## slides, deep dives and devlog are built by one program (all.nim): one compile, however many
## pages. Each theme is a compile of its own (the theme is chosen at compile time). Every build
## ends with the check. Flags after `--` go to nim: `nim r build.nim deepdives -- -d:release`.
import std / [os, osproc, strutils, re, sets, sequtils]

const
  pageGroups = ["slides", "deepdives", "devlog"]
  deckParts = {"title": "title", "about": "about", "intro": "intro",
               "island1": "island1_performance", "island2": "island2_stories",
               "island3": "island3_datastack", "island4": "island4_interop",
               "island5": "island5_expressive", "island6": "island6_interactivity",
               "island7": "island7_notebook", "conclusion": "conclusion",
               "thank_you": "thank_you"} # the modules of slides/ that deck.nim imports;
    # each one builds its part with `when isMainModule` (thank_you: docs/thank_you.html)
  themes = ["pirate", "book", "agile"] # the deck wears chart (themes.nim)

const partNames = deckParts.mapIt(it[0])

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

proc linksResolve(): bool =
  ## true when every link of a built page to another page or file of the site points to a file
  ## that exists (pages move: deepdive/, slides.html)
  let linkRe = re("<(?:a|link|script|img|iframe|source)[^>]*?(?:href|src)=\"([^\"#?]*)")
  var broken: seq[string]
  for page in walkDirRec("docs"):
    if not page.endsWith(".html"): continue
    var start = 0
    var caps: array[1, string]
    let html = readFile(page)
    while (let at = html.find(linkRe, caps, start); at >= 0):
      start = at + 1
      let url = caps[0]
      if url.len == 0 or url.contains(':') or url.startsWith("//"): continue
      if not fileExists(page.parentDir / url) and not dirExists(page.parentDir / url):
        if "shiny/" in url and not dirExists("docs/shiny") and getEnv("CI").len == 0:
          continue # exported by scripts/shinylive.sh, which needs the network once (see shinyApps)
        broken.add page & ": " & url
  if broken.len > 0:
    echo "== broken links between pages:"
    for b in broken: echo b
    return false
  echo "== check: every link between pages resolves"
  true

proc shinyApps() =
  ## the Shiny apps exported with shinylive (scripts/shinylive.sh), when they are missing
  if dirExists("docs/shiny/plant"): return
  echo "== bash scripts/shinylive.sh"
  if execCmd("bash scripts/shinylive.sh") != 0:
    if getEnv("CI").len > 0: quit "build: failed: scripts/shinylive.sh", 1
    echo "== warning: the Shiny apps could not be exported (offline?), links to docs/shiny/ are not checked"

proc noRawHtml(): bool =
  ## true when no page uses nbRawHtml: pages use the blocks of blocks.nim (see the nimib-blocks skill)
  var found: seq[string]
  for dir in [".", "slides", "deepdive", "devlog", "maps"]:
    for f in walkFiles(dir / "*.nim"):
      let lines = readFile(f).splitLines()
      for i, line in lines:
        if "nbRawHtml" in line and not line.strip.startsWith("#") and not line.strip.startsWith("##") and
            f.extractFilename != "build.nim":
          found.add f & ":" & $(i + 1) & ": " & line.strip
  if found.len > 0:
    echo "== nbRawHtml in a page (make a block in blocks.nim instead):"
    for f in found: echo f
    return false
  true

proc noAgentNotes(): bool =
  ## true when no tracked text file has a line starting with `#>`: a note for Claude from the
  ## local-changes branch (AGENTS.md, "Notes for Claude"), to be handled and removed before
  ## main. On main (CI sets CI=true) a note fails the build; locally it is only listed.
  let (output, code) = execCmdEx("git grep -nI -E \"^[[:space:]]*#>\" -- . \":!docs/assets\"")
  if code != 0 or output.strip.len == 0: return true
  let inCi = getEnv("CI").len > 0
  echo "== notes for Claude (#>) still in the sources", (if inCi: ":" else: " (a warning outside CI):")
  echo output.strip
  not inCi

when isMainModule:
  setCurrentDir(currentSourcePath().parentDir)
  var groups, extra: seq[string]
  var afterDashes = false
  for a in commandLineParams():
    if afterDashes: extra.add a
    elif a == "--": afterDashes = true
    else: groups.add a
  if groups.len == 0 or "all" in groups:
    groups = @pageGroups & @["themes", "looks", "check"]
  for g in groups:
    if g notin pageGroups and g notin ["themes", "looks", "check"] and g notin partNames:
      quit "build: unknown group " & g & " (slides, deepdives, devlog, themes, looks, check, all, " &
        "or a part of the deck: " & partNames.join(", ") & ")", 2
  let pages = groups.filterIt(it in pageGroups)
  if pages.len > 0:
    run "nim r " & nimFlags(extra) & " -d:only=" & pages.join(",") & " all.nim"
  if "themes" in groups:
    for t in themes:
      run "nim r " & nimFlags(extra) & " -d:slideTheme=" & t & " all.nim"
  for (name, module) in deckParts:
    if name in groups: run "nim r " & nimFlags(extra) & " slides/" & module & ".nim"
  if "looks" in groups:
    run "nim r " & nimFlags(extra) & " -d:deckLook=centered all.nim"
  shinyApps()
  let checks = [check(), linksResolve(), noRawHtml(), noAgentNotes()]
  if false in checks: quit 1
