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
import ../islandnames # islandLabel
export page

type
  DeepDive* = object
    slug*: string    ## the file name: deepdive/<slug>.nim, docs/deepdive/<slug>.html
    title*: string
    section*: string ## where the talk sketches it
    summary*: string ## one line, for the lists

const deepDives* = @[
  DeepDive(slug: "vandermonde", section: islandLabel(1),
    title: "The Vandermonde matrix, with for loops",
    summary: "The benchmark of the performance slide: the same loops in Python and Nim, NumPy, Bezanson's case study, the caveats, and how far down Nim goes."),
  DeepDive(slug: "beyond_science", section: islandLabel(2),
    title: "Nim success stories beyond science",
    summary: "What people who are not scientists built with Nim: a web front-end, an Ethereum client, games, chip SDKs, business software."),
  DeepDive(slug: "bioinformatics", section: islandLabel(2),
    title: "Nim in bioinformatics",
    summary: "The genomics tools of Brent Pedersen, who started it, the people who followed, and the bioinformatics behind them, with toy code that runs."),
  DeepDive(slug: "vindaar", section: islandLabel(2),
    title: "Vindaar's thesis in plain words",
    summary: "A physics PhD whose whole analysis is written in Nim: solar axions, the detector, and the code."),
  DeepDive(slug: "qex", section: islandLabel(2),
    title: "Lattice QCD and QEX in plain words",
    summary: "What lattice QCD is, what QEX does and where Nim comes in, with a toy lattice that runs when the page is built."),
  DeepDive(slug: "penguins_data_stack", section: islandLabel(3),
    title: "Penguins with the Nim data stack",
    summary: "The penguins dataset explored with Arraymancer, Datamancer, ggplotnim and plotly, further than the slides go, with a small neural network."),
  DeepDive(slug: "penguins_polars", section: islandLabel(3),
    title: "Penguins with nanuq and tabelline",
    summary: "Polars from Nim with nanuq, display tables with tabelline: how they work, the penguins again, and how they compare with Datamancer."),
  DeepDive(slug: "interoperability", section: islandLabel(4),
    title: "Interoperability: Nim with other languages",
    summary: "Calling C, C++ and JavaScript natively, bridges to Python, R and Julia, and Nim inside Python with nimlang-pypi and naffprop."),
  DeepDive(slug: "operators", section: islandLabel(5),
    title: "Custom operators: points, lines and planes",
    summary: "How operators work in Nim, the geometry behind the example, where it breaks, and one more operator to try."),
  DeepDive(slug: "units_macros", section: islandLabel(5),
    title: "Units with unchained",
    summary: "How unchained checks units at compile time, how declareUnits adds new ones, and Kepler's third law."),
  DeepDive(slug: "plant_app", section: islandLabel(6),
    title: "A plant in the browser",
    summary: "A Shiny for Python app ported to Nim and compiled to JavaScript, what the JavaScript backend can do, and why Nim has no REPL yet."),
  DeepDive(slug: "notebook", section: islandLabel(7),
    title: "nimib: a notebook that is a Nim program",
    summary: "From literate programming to Jupyter, the blocks of nimib, what people make with it, how it compares with other notebooks, and its limits."),
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
