import std / [json]
import nimib
import nimib / highlight

# A nimib document with Nim success stories outside
# scientific computing, for the curious, linked from
# the Success Stories intro (slides/island2_stories.nim):
#   nim r slides/island2_beyond_explainer.nim
# writes docs/island2_beyond_explainer.html.

# this path writes the page to docs/, not docs/slides/
nbInit(thisFileRel = "island2_beyond_explainer.nim")
# but with it nimib cannot find this file,
# so give the "Show Source" button its source here
const ownSource = staticRead("island2_beyond_explainer.nim")
nb.doc.source = ownSource
nb.doc.context["source"] = %nb.doc.source
nb.doc.context["source_highlighted"] = %highlightNim(nb.doc.source)

nbText """
# Nim success stories beyond science

In the talk [Sailing Seas of Scientific
Nim](https://pietroppeter.github.io/talk-sailing-seas-scientific-nim/),
Island 2 tells two success stories of people who used
Nim to advance science: Brent Pedersen in bioinformatics
and Vindaar in physics.

Nim is a general purpose language, and most of the
people who use it are not scientists. This page lists
some of the things they built, to show the breadth:
a web front-end, an Ethereum client, a supply-chain
security tool, games, chip SDKs, business software.
It is a sample, not a complete list.

## On the web

**[Nitter](https://github.com/zedeus/nitter)**,
by zedeus, is a free and open source front-end for
Twitter (now X), focused on privacy and performance:
no JavaScript, no ads, no tracking, and much lighter
pages (60KB against 784KB for the same profile,
according to its README). It was used by many public
instances. In August 2026 X Corp. sent cease and desist
letters asking to take the instances and the
repository down; its author is seeking legal help.

## Blockchain and cryptography

**[Nimbus](https://github.com/status-im/nimbus-eth2)**
is one of the clients of the Ethereum network, the
software that keeps the chain in consensus. It is
written in Nim and built to be light enough for
embedded devices such as a Raspberry Pi. It is made by
Status, part of the [Institute of Free
Technology](https://free.technology/), which also makes
the [Status app](https://github.com/status-im/status-desktop),
a private messenger built with Nim and Qt.
Many core Nim libraries come from this team.

**[Constantine](https://github.com/mratsim/constantine)**,
by Mamy Ratsimbazafy (@mratsim, who speaks right after
this talk), is a library of high performance,
constant-time cryptography for blockchains and
zero-knowledge proofs.

## Security and developer tools

**[Chalk](https://github.com/crashappsec/chalk)**,
by Crash Override (written by John Viega), marks every
software artifact (containers, executables, scripts)
with an identifier at build time and collects where
it came from, so a company can tell which code is
running in production. Supply-chain security, in Nim.

**[CodeTracer](https://github.com/metacraft-labs/codetracer)**,
by Metacraft Labs, is a time-traveling debugger:
it records a program run in a trace file, and lets
you step backwards as well as forwards.
It is written in Nim and Rust.

**[Vim³](https://github.com/oakes/vim_cubed)**,
by Zach Oakes, is Vim on the faces of a spinning cube.
Its README opens with "Most people use vim in two
stupid dimensions. But not me. I use it in three".
It is written in Nim, on top of his
[paravim](https://github.com/paranim/paravim),
Vim embedded in an OpenGL game engine.

## Education

[Exercism](https://exercism.org) is a free, non-profit
platform to learn programming languages by solving
exercises, with mentors who review your solutions.
It has dozens of language tracks (Nim among them),
each a GitHub repository of exercises and tests,
maintained by volunteers.

Keeping all those tracks consistent is the job of
**[configlet](https://github.com/exercism/configlet)**,
the official tool for managing track repositories.
Every track downloads it, and runs it in its CI:
it lints the track configuration, syncs exercise
descriptions and tests from the shared problem
specifications, formats the files, and creates new
exercises. A single binary, written in Nim.

## Industry and AI research

**Reddit**: Andre von Houck (@treeform) used Nim at
Reddit for internal analytics and data tools.
Along the way he wrote some of the most used Nim
libraries, such as [pixie](https://github.com/treeform/pixie)
for 2D graphics and [jsony](https://github.com/treeform/jsony)
for JSON.

**[Softmax](https://github.com/Metta-AI)**, a company
researching cooperation and alignment between AI agents,
is where Andre works now. Nim is the main language
of its GitHub organization, with game engines and
environments for AI research such as polyworld
and bitworld.

**Avju Solutions**, a Norwegian company, has Peter
Munch-Ellingsen (@PMunch), a long time Nim contributor
and author of many Nim packages, as its CTO,
and builds its software in Nim.

**[CxPlanner](https://cxplanner.com/)**, a Danish
company making software to plan and commission
construction projects, has its backend, builder and
microservices written in Nim, according to its
founder Thomas T. Jarløv.

## Games

**[Turing Complete](https://store.steampowered.com/app/1444480/Turing_Complete/)**
is a game on Steam where you build a computer from
logic gates up and then program it. LevelHead made
it with the Godot engine and Nim, through godot-nim.

**[NimForUE](https://github.com/jmgomez/NimForUE)**
brings Nim to Unreal Engine 5, with hot reloading
while the editor is open.

**[Beamdog](https://www.beamdog.com/)** used Nim for
the multiplayer services of Neverwinter Nights:
Enhanced Edition, and for tools and prototypes.

## Embedded

**[INGCHIPS](https://www.ingchips.com/)** makes Bluetooth
Low Energy chips, and its official SDK for them has
Nim among the languages for writing applications,
with a "Hello, Nim" chapter in the user guide.

## More

The Nim wiki keeps a list of [organizations using
Nim](https://github.com/nim-lang/Nim/wiki/Organizations-using-Nim),
and the forum has a thread on [companies using Nim
in production](https://forum.nim-lang.org/t/13387).
"""

nbSave
