import nimib
import devlog

nbInit(thisFileRel = "devlog/setting_sail.nim")
const ownSource = staticRead("setting_sail.nim")
nb.useDevlogPost("setting-sail", ownSource)

nbText """
This is the first post of the talk log,
a log of how the talk
[Sailing Seas of Scientific Nim](../index.html)
is made, for Compute Paris on 26 November 2026.
It starts late, a month into the work,
so this first post looks back at how we got here.

## The idea

The talk is a sea voyage.
We leave the mainland of scientific computing
(Fortran, C, C++, R, Python, Julia),
and hop across seven islands,
each one a strength of Nim,
with an honest "rocks ahead" where Nim falls short.
From a boat you only get a limited view of the land:
the talk gives the feeling of each island,
not a tour of it.
The [abstract](https://github.com/pietroppeter/talk-sailing-seas-scientific-nim#abstract)
is in the README, as it was submitted.

## Slides as code (4 October)

The slides are Nim code:
[nimib](https://github.com/pietroppeter/nimib) 0.4.1
with [nimiSlides](https://github.com/HugoGranstrom/nimiSlides) 0.4.0 (reveal.js),
and dependencies managed with atlas.
The first scaffold ported `my.nim`, the helpers of an earlier talk,
to nimib 0.4: the AgileLab theme and logo,
a soft white background, images with a width,
and a workaround for LaTeX in nimiSlides 0.4.

## Specs, an outline and a public deck (26 October)

The talk is prepared with [OpenSpec](https://github.com/Fission-AI/OpenSpec)
and a custom schema for talks:
specs say what the talk must be
(the abstract, the audience, the format, four key messages, the tooling),
a living outline says what is in it,
and every change to the talk is a proposal with its own outline delta.
The four key messages are
Nim's tradeoffs and its untapped potential,
its strengths (easy like Python, fast as C, with superpowers),
that it is pragmatic and ready for more,
and an appreciation of the diversity of languages.

The deck went public on GitHub Pages,
with reveal.js, KaTeX and p5.js vendored in the repository
so the slides work without a network at the venue.
Draft slides show only a title and a draft marker,
their notes stay in the speaker notes.
Each section became a vertical stack:
left and right move between islands, down goes through one.
The first layout (an image on the left) and the
animated Thank You slide (a p5nim sketch) came the same day.

## Explainers and the first islands (27 October)

Slides have little room for code,
so code-heavy slides get an explainer:
a nimib page, built with the deck,
that goes deeper for whoever wants to explore.
The first one explains the Thank You animation.

Then the islands started to fill:
the success stories of Brent Pedersen (genomics)
and Sebastian Schmidt, Vindaar (physics), each with an explainer;
the data stack, Datamancer, ggplotnim and Arraymancer,
told with the penguins dataset;
custom operators and a units macro with unchained.
The code moved to a light theme,
and the islands were renamed and reordered
(Island 1 became "Accessible Performance",
Interoperability now comes before An Expressive Language).
The README keeps a list of the changes from the submitted abstract.

## What's next

The content is getting there, the look is still corporate.
The next two posts explore how the slides could tell the voyage too:
[three themes](2026-11-07-dressing-the-voyage.html)
and [a map drawn by code](2026-11-07-drawing-the-map.html).
"""

nb.devlogFooter("setting-sail")
nbSave
