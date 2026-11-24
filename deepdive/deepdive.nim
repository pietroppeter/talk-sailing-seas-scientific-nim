## The deep dives: nimib pages that go deeper into what the slides only sketch.
## Each slide that sketches a topic links its deep dive; `deepdive/index.nim`
## (docs/deepdive/index.html) and the site index (index.nim) list them all.
##
## Adding a deep dive: append an entry here, start the page with
##   nbInit(thisFileRel = "deepdive/my_topic.nim")
##   const ownSource = staticRead("my_topic.nim")
##   nb.useDeepDive("my_topic", ownSource)
## and link it from its slide as `deepdive/my_topic.html`
## (`nim r build.nim deepdives` finds and builds it).
import nimib
import ../page # usePage, and the blocks of blocks.nim
export page

type
  DeepDive* = object
    slug*: string    ## the file name: deepdive/<slug>.nim, docs/deepdive/<slug>.html
    title*: string
    section*: string ## where the talk sketches it
    summary*: string ## one line, for the lists

const deepDives* = @[
  DeepDive(slug: "beyond_science", section: "Island 2 · Success Stories",
    title: "Nim success stories beyond science",
    summary: "What people who are not scientists built with Nim: a web front-end, an Ethereum client, games, chip SDKs, business software."),
  DeepDive(slug: "brentp", section: "Island 2 · Success Stories",
    title: "Brent Pedersen: genomics tools in Nim",
    summary: "The genomics tools of Brent Pedersen, with the bioinformatics behind them and toy code that runs."),
  DeepDive(slug: "vindaar", section: "Island 2 · Success Stories",
    title: "Vindaar's thesis in plain words",
    summary: "A physics PhD whose whole analysis is written in Nim: solar axions, the detector, and the code."),
  DeepDive(slug: "qex", section: "Island 2 · Success Stories",
    title: "Lattice QCD and QEX in plain words",
    summary: "What lattice QCD is, what QEX does and where Nim comes in, with a toy lattice that runs when the page is built."),
  DeepDive(slug: "penguins_data_stack", section: "Island 3 · Data Stack",
    title: "Penguins with the Nim data stack",
    summary: "The penguins dataset explored with Arraymancer, Datamancer, ggplotnim and plotly, further than the slides go."),
  DeepDive(slug: "operators", section: "Island 5 · An Expressive Language",
    title: "Custom operators: points, lines and planes",
    summary: "How operators work in Nim, the geometry behind the example, where it breaks, and one more operator to try."),
  DeepDive(slug: "units_macros", section: "Island 5 · An Expressive Language",
    title: "Units with unchained",
    summary: "How unchained checks units at compile time, how declareUnits adds new ones, and Kepler's third law."),
  DeepDive(slug: "plant_app", section: "Island 6 · Interactivity",
    title: "A plant in the browser",
    summary: "A Shiny for Python app ported to Nim and compiled to JavaScript, what the JavaScript backend can do, and why Nim has no REPL yet."),
  DeepDive(slug: "thank_you_sketch", section: "Thank you",
    title: "How the Thank You slide works",
    summary: "Creative coding with p5nim: the animation of the last slide, explained one step at a time."),
]

func fileName*(d: DeepDive): string = d.slug & ".html"

func findDeepDive*(slug: string): int =
  for i, d in deepDives:
    if d.slug == slug: return i
  -1

proc useDeepDive*(nb: var Nb, slug: string, ownSource: string) =
  ## the style of every page, and a header that says where the talk sketches this topic
  let i = findDeepDive(slug)
  doAssert i >= 0, "deepdive: add " & slug & " to deepdive/deepdive.nim"
  let d = deepDives[i]
  nb.usePage(ownSource)
  nb.title = d.title & " · deep dive"
  nbEyebrow "[Deep dives](index.html) · " & d.section & " · [the slides](../slides.html)"
