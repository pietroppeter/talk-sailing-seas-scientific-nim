import std / [strutils, json, math]
import nimib
import nimib / highlight

# A nimib document that explains, in plain words, the PhD
# thesis of Sebastian Schmidt (@Vindaar), the second success
# story of Island 2 (slides/island2_stories.nim):
#   nim r slides/island2_vindaar_explainer.nim
# writes docs/island2_vindaar_explainer.html.
# The toy code below runs when the page is built;
# the thesis snippet is quoted, not run.

# this path writes the page to docs/, not docs/slides/
nbInit(thisFileRel = "island2_vindaar_explainer.nim")
# but with it nimib cannot find this file,
# so give the "Show Source" button its source here
const ownSource = staticRead("island2_vindaar_explainer.nim")
nb.doc.source = ownSource
nb.doc.context["source"] = %nb.doc.source
nb.doc.context["source_highlighted"] = %highlightNim(nb.doc.source)
nbRawHtml("<style>\n" & """
pre { overflow-x: auto; }
table { font-size: 0.9em; }
""" & "</style>")

nbText """
# Vindaar's thesis in plain words

In the talk [Sailing Seas of Scientific
Nim](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/),
Island 2 tells two success stories in forty seconds each.
The second is Sebastian Schmidt (@Vindaar on GitHub),
who did a PhD in physics at the University of Bonn
and wrote the entire analysis code base in Nim.

The thesis is called "Search for solar axions using
a 7-GridPix IAXO prototype detector at CAST" (2024).
This page explains what that title means,
what he found, and where Nim comes in.
No physics background assumed.

## In one sentence

He looked for a hypothetical particle coming from the Sun,
using a giant magnet at CERN and a detector that can see
single electrons; he did not find it, and so he could say
more precisely how shy the particle must be.

## What is an axion?

The strong nuclear force, the one that holds atomic nuclei
together, could in principle treat matter and its mirror
image differently. Its equations have an angle in them
(called θ) that allows it. Measurements say that angle
is zero, or extremely close to it.

Physicists do not like coincidences of that kind.
In 1977 Peccei and Quinn proposed a mechanism that sets
the angle to zero by itself, and it comes with a new particle:
the axion. It would be very light and interact very weakly
with everything else. It is also a candidate for dark matter,
the invisible mass we see in galaxies.

No one has seen an axion yet. Experiments do not prove
a particle is absent; they rule out how strongly it could
interact with ordinary matter. Each new experiment pushes
that number lower. That number is called a coupling.

## Why look at the Sun?

If axions exist, the hot core of the Sun makes plenty
of them. One way (the Primakoff effect) is an X-ray that
turns into an axion near the electric field of a nucleus.
Other ways involve electrons. Axions fly straight out of
the Sun and through anything, the Earth included.

The flux of axions from the Sun peaks around a few keV,
the energy of soft X-rays. The thesis has a function for
the Primakoff part, with physical units checked by the
compiler (the excerpt on the slide):
"""

nbRawHtml("<pre><code class=\"nohighlight nim hljs\">" & highlightNim("""
proc axionFluxPrimakoff(E_a: keV,
                        g_aγ: GeV⁻¹): keV⁻¹•cm⁻²•s⁻¹ =
  let g₁₀ = g_aγ / 1e-10.GeV⁻¹
  result = g₁₀^2 * 3.821e10.cm⁻²•s⁻¹•keV⁻¹ *
    (E_a / 1.keV)^3 / (exp(E_a / (1.103.keV)) - 1)
""".strip) & "</code></pre>")

nbText """
That code is quoted, not run here: it needs
[Unchained](https://github.com/SciNim/Unchained),
the units library that makes `keV` and `GeV⁻¹` types.
Here is the same shape with plain floats,
to see where the flux peaks:
"""

nbCode:
  # energy in keV -> relative axion flux (shape only)
  proc flux(e: float): float = e^3 / (exp(e / 1.103) - 1)

  var peak = 0.1
  for i in 1 .. 100:
    let e = i.float / 10
    if flux(e) > flux(peak): peak = e
  echo "the flux peaks at about ", peak, " keV"
  for e in [1.0, 2.0, 3.0, 5.0, 8.0]:
    echo e, " keV: ", "#".repeat(int(flux(e) * 8))

nbText """
## CAST: a telescope made of a magnet

A strong magnetic field can turn an axion back into
an X-ray. CAST, the CERN Axion Solar Telescope, used
a 9.26 m long prototype magnet of the Large Hadron
Collider, with a field of 8.8 tesla, mounted on a
platform that follows the Sun for about 90 minutes
at sunrise and 90 at sunset. Since axions cross the
Earth, tracking starts before sunrise.
CAST ran from 2003; Vindaar's detector took data
there in 2017 and 2018.

At the end of the magnet sits a detector looking for
the few X-rays that axions would make.

## The detector: seven chips that see single electrons

When an X-ray hits the gas inside the detector, it frees
electrons. A GridPix chip (a Timepix pixel chip with
a fine grid on top) records each of those electrons,
so an X-ray looks like a small round blob.

The hard part is everything else that looks like an X-ray:
mostly cosmic muons, particles from space that hit the
Earth all the time. The "Septemboard" puts seven chips
side by side: the one in the middle looks for X-rays,
and the six around it catch the tracks that pass through.
If something lights up the outer chips at the same time,
it was not an axion. Together with other vetoes,
this cuts the background by about ten times over the
whole central chip.

## The analysis

In numbers: about 3150 hours of background data
(magnet not pointing at the Sun) and 160 hours of
data while tracking the Sun. The question is whether
the Sun data has more X-ray-like events than the
background predicts.

Getting there took, among other things:
a classifier that tells X-rays from the rest, including
a small neural network trained only on simulated X-rays,
a raytracing simulation of the telescope to know where
on the chip an axion image would land,
and a Bayesian statistical method that takes the
uncertainties into account by sampling (Markov Chain
Monte Carlo).

## The result

No sign of axions. That gives limits, at 95% confidence:

| coupling | this thesis | previous best |
|---|---|---|
| axion-electron × axion-photon (GeV⁻¹) | 7.35e-23 | 8.1e-23 (CAST 2013) |
| axion-photon (GeV⁻¹) | 9.0e-11 | 6.6e-11 (CAST 2017) |
| chameleon-photon | 3.1e10 | 5.74e10 |

Smaller is better. The first line improves on the
previous CAST result; on axion-photon alone the
detector was not expected to beat the best limit,
and it did not; for chameleons (another hypothetical
particle, a candidate for dark energy) it sets
a new best bound.

## Where Nim comes in

All of the analysis is
[TimepixAnalysis](https://github.com/Vindaar/TimepixAnalysis),
written in Nim, from reading the raw detector data
to the limits. He chose Nim for, in his words,
"concise and clean syntax, high-level features for
productivity, high performance due to native code
generation, easy interfacing with existing C and C++
code bases and its strong metaprogramming features".

There was no data stack in Nim to lean on, so he built
much of it: [ggplotnim](https://github.com/Vindaar/ggplotnim)
for plots (every plot in the thesis is made with it),
[Datamancer](https://github.com/SciNim/Datamancer) for
data frames, [nimhdf5](https://github.com/Vindaar/nimhdf5)
for data files, [Unchained](https://github.com/SciNim/Unchained)
for units, [Measuremancer](https://github.com/SciNim/Measuremancer)
for uncertainties. The neural network uses
[Flambeau](https://github.com/SciNim/flambeau),
a Nim wrapper of the C++ library under PyTorch.

The thesis itself is a single Org file of more than
50k lines with the Nim code next to the text,
and code, thesis and data are all public.
In his words, Nim provides "the perfect base for
the single developer to be productive and build fast,
safe software. In other words: the language gets out
of my way".

The price is in the appendix too:
"by choosing Nim as the target language
I underestimated the amount of code I would / had
to write", and "while it certainly delayed the end
of my thesis by a significant time, I learned way more
than I would have otherwise."

## Sources

[The thesis](https://doi.org/10.48565/bonndoc-303)
(University of Bonn, 2024),
[its source](https://github.com/Vindaar/phd),
[the code](https://github.com/Vindaar/TimepixAnalysis),
[the data](https://zenodo.org/uploads/10521887).
The numbers on this page are from its summary chapter.
"""

nbSave
