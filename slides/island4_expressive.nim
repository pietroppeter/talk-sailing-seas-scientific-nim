import std / [math, strformat]
import nimib, nimiSlides
import nimib / highlight
import unchained
import ../my, island4_vectors
from island4_units import NauticalMile, nmi, Knot, knot
export math, unchained, island4_vectors
export NauticalMile, nmi, Knot, knot

# Section 5: Island 4: An Expressive Language (see the latest outline in openspec)
# Two language features that make Nim good for scientific use. Carries K2 (metaprogramming superpower).

proc sailingUnitsHtml: string =
  ## the declaration in island4_units.nim, between the markers, highlighted
  const source = staticRead("island4_units.nim")
  let code = source.split("# >>> sailing units\n")[1].split("# <<< sailing units")[0]
  &"""<pre style="width: 100%"><code class="nim hljs" data-noescape>{highlightNim(code.strip)}</code></pre>"""

template island4ExpressiveSection* =
  slide:
    mapSlide(4) # 5.1
    slide: # 5.2
      nbText "## Custom operators"
      nbTextSmall """
`Point + Point` is not a point:
let it be the line through them.
"""
      nbCode:
        type
          Line = object   # through p, along d
            p: Point
            d: Vec
          Plane = object  # through p, normal n
            p: Point
            n: Vec

        func `+`(a, b: Point): Line = Line(p: a, d: b - a)
        func `+`(l: Line, c: Point): Plane =
          Plane(p: l.p, n: l.d × (c - l.p))
        func `*`(l: Line, s: Plane): Point =
          l.p + ((s.p - l.p) ∙ s.n) / (l.d ∙ s.n) * l.d
      speakerNote """
Points, vectors, dot (∙) and cross (×) products
are a few lines in a helper module:
unicode operators are custom operators too.
`+` joins (two points make a line, a line and a point a plane),
`*` meets (a line hits a plane in a point).
"""
    slide: # 5.3
      nbText "## A shadow at sea"
      nbTextSmall """
Where does the shadow of the mast top fall?
"""
      nbCode:
        let
          sea = pt(0, 0, 0) + pt(1, 0, 0) + pt(0, 1, 0)
          sun = pt(-30, 0, 40)
          mastTop = pt(0, 0, 12)
          shadow = (sun + mastTop) * sea
        echo shadow
      speakerNote """
Three points make the plane of the sea,
the sun and the mast top make a line,
the line meets the sea in the shadow.
The formula reads like geometry, the types check it:
`sun + mastTop + shadow` is a plane, `sea * sun` does not compile.
"""
    slide: # 5.4
      nbText "## Units with a macro"
      nbTextSmall """
[unchained](https://github.com/SciNim/unchained) by Vindaar:
units checked at compile time, plain floats at run time.
Its `declareUnits` macro adds sailing units to SI:
"""
      nbRawHtml sailingUnitsHtml()
      nbTextSmall """
The macro writes the types, the aliases and the conversions;
`*`, `/` and `+` are macros that work out the unit of the result.
"""
      speakerNote """
A macro is Nim code that runs in the compiler and writes Nim code.
declareUnits reads this block and generates distinct float types
(NauticalMile, Knot) with their short names and conversions.
The arithmetic operators are macros too: at compile time they
compute the unit of the result (and define its type if needed).
Short name `knot`, not `kn`: Nim identifiers are case insensitive
after the first letter, so `kn` would clash with `kN` (kilonewton).
"""
    slide: # 5.5
      nbText "## Hull speed"
      nbTextSmall """
The speed of a wave as long as the boat,
a rule of thumb for how fast a hull can go.
"""
      nbCode:
        let
          g = 9.81.m•s⁻²
          waterline = 30.ft
          hullSpeed = sqrt(g * waterline / (2 * PI))
        echo hullSpeed, " = ", hullSpeed.to(knot)
        echo "30 nmi in ", (30.nmi / hullSpeed).to(h)
        echo compiles(waterline + g) # Length + Acceleration
      speakerNote """
Feet, SI and nautical units in one formula, converted for us.
sqrt only compiles for a unit that is a perfect square.
Adding a length to an acceleration is a compile time error.
"""
    placeholderSlide("5.6", "Rocks ahead", """with great power: macros can make code hard to read for newcomers; concepts (compile-time duck typing) were not robust until possibly recently.""")
