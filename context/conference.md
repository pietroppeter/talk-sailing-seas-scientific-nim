# Compute! Paris 2026: conference context

Context for the talk **"Sailing the Seas of Scientific Nim"** (Pietro Peterlongo).
Gathered 2026-10-04 from web search results. The official sites
(compute.events, pretalx.com) were not directly reachable from the research
environment, so items marked _(unverified)_ should be checked on the site.

## At a glance

| | |
|---|---|
| Name | **Compute! Paris 2026** (first edition of the Compute! series) |
| Dates | **Wednesday 25 – Thursday 26 November 2026** (two days) |
| Venue | Centre International de Conférences de Sorbonne Université (CICSU), 4 place Jussieu, Patio 44-55, 75005 Paris (Jussieu campus, Latin Quarter) |
| Getting there | Metro Jussieu (lines 7 and 10); buses 63, 67, 86, 87, 89 |
| Organizer | QuantStack (lead: Sylvain Corlay, CEO), same team that ran PyData Paris |
| Our slot | **Thursday 26 November 2026, 14:40–15:10, Room 108**, session "A Babel of Compilers" (talk, 30 min incl. Q&A) |
| Website | https://compute.events/paris2026/ |
| CfP / schedule (pretalx) | https://pretalx.com/compute-paris-2026/ |
| Meetup group | https://www.meetup.com/compute-paris/ |

## What the conference is

- Compute! is a new conference series "dedicated to open-source software for
  machine learning, AI, data, and scientific computing". Paris is the first
  edition.
- It is the successor of **PyData Paris**: same organizing team, renamed to
  cover data science, AI/ML and open source **across all languages**, not just
  Python. The CfP explicitly encouraged submissions from ecosystems other than
  the Python scientific stack (the Julia community was invited on Julia
  Discourse). This is the hook for a Nim talk: the audience will be mostly
  Python-centric, but the conference is actively looking for "other language"
  content.
- Target audience: maintainers, researchers, engineers and practitioners who
  build, use and depend on open tools, from both academia and industry.
- The organizing team has contributed to Jupyter, scikit-learn, Apache Arrow,
  Mamba and other core tools, so expect a strong Jupyter / packaging /
  scientific-Python crowd.

## Topics (from the CfP)

Data analysis & visualization · Scientific computing · Machine learning & AI ·
Data engineering · High-performance computing · Reproducible research ·
Open source tools & ecosystems · Education & outreach · Ethics & responsible
AI · Community building · Domain applications · Package management &
distribution.

Our talk sits mainly in *Scientific computing* and *Open source tools &
ecosystems*, touching *Education & outreach* (Nim as a learning tool) and
*Reproducible research* (nimib, literate programming).

## Format

- Two days of live talks, keynotes and community events.
- Talks are **30-minute slots including Q&A** (so plan roughly 22–25 minutes of
  content). Confirmed for our talk: 14:40–15:10.
- Proposals were reviewed double-blind (reviewers saw title, description,
  outline, brief summary and prior knowledge expected, not the speaker).
- The **brief summary** is printed in the conference programme; summary and
  description are both visible to attendees online. Attendees choose our talk
  from these, so the talk should deliver what they promise.
- The site nav lists a **Sprints** page, so there is a sprints programme
  around the conference (details not read yet).
- Each accepted talk includes **one free speaker ticket** for the full event.
- Travel support, recording policy and number of parallel tracks were not
  found. PyData Paris 2025 ran 3 parallel tracks with ~45 talks, and its talks
  were recorded; expect something similar _(unverified)_.

## Timeline

- CfP: opened 15 April 2026, deadline extended from 24 May to **7 June 2026**
  (now closed). Acceptance notifications were "TBC" on the CfP page.
- Conference: 25–26 November 2026.
- Schedule publication date, slide/recording deadlines: not found; check
  pretalx and speaker emails.

## Our session: "A Babel of Compilers"

Thursday 26 November, Room 108. Confirmed by Pietro (2026-10-04):

- **Antonio Cuni** (with a co-speaker): SPy.
- **Mamy André-Ratsimbazafy**: high-performance computing for AI in Nim.
- **Pietro Peterlongo**: Sailing the Seas of Scientific Nim (14:40–15:10).

Implications: the session audience comes for languages and compilers, so less
"why another language" justification is needed. Mamy's talk is also about Nim
and covers HPC/AI, so the "Accessible Performance" island and any
Arraymancer/HPC material can stay brief and point to his talk rather than
duplicate it. Coordinate with Mamy on overlap (order of talks unknown). SPy
(a statically compiled Python variant) is a natural comparison point when
explaining Nim's "reads like Python, compiles like C" pitch.

## CfP guidance, read as guidelines for the talk

Source: the CfP page text, pasted by Pietro on 2026-10-04 (verbatim copy of
compute.events/paris2026/cfp.html). The organizers wrote it for proposals, but
it is equally a checklist for the talk itself.

**What a good talk/proposal discloses**

- The topic (the **WHAT**) and **WHY** it is interesting.
- The audience to **WHOM** it is addressed (job role and experience level).
- The **TYPE** of talk (lots of maths, hands-on, etc.) and the tone.
- The **TAKEAWAY**: what attendees will learn or be able to do.
- Background knowledge required.
- Approximate time breakdown (e.g. minutes 0–10: X, 10–15: Y).

**Other advice from the CfP**

- *Clear title*: people should get a rough idea of the talk from the title, and
  the presentation should be consistent with title and proposal.
- *Get feedback*: have friends or colleagues (ideally the target audience)
  review it.
- *Pitfalls*: overly long (aim for the key info in ~200 words); relying on
  future work (core content should already be shaped); sales pitches (the
  audience prefers techniques they can try with open-source tools); repeated
  talks (strong preference for new talks and new speakers; a talk already
  online is unlikely to be accepted).

**How this applies to "Sailing the Seas of Scientific Nim"**

- WHAT/WHY: why Nim is a good fit for scientific computing, as a tour of seven
  "islands", without hiding where Nim falls short.
- WHOM: the scientific-computing beginner and the ecosystem builder (plus
  language enthusiasts and community builders). The room is mostly
  Python/Jupyter people, so Python-like examples are the right bridge.
- TYPE/tone: an example-driven tour, explicitly *not* a language tutorial;
  light, travel-themed narrative.
- TAKEAWAY: separate takeaways for the beginner (an accessible, fun language
  to try) and the builder (pros and cons of building tools in Nim).
- Time budget: ~25 minutes of content in a 30-minute slot. With intro,
  conclusion and seven islands, that's about 2.5–3 minutes per island. Write
  the per-section time breakdown into the slide outline, as the CfP suggests.
- "Core content already shaped": every demo the proposal promises (penguins
  data exploration, the Shiny app port, Python interop and so on) should work
  well before the day.
- "Repeated talks": the CfP strongly prefers new material, so the talk should
  not reuse a deck that is already online.
- "No sales pitch": nimib is Pietro's own project; present the seventh island
  as an open-source option with honest trade-offs, not a pitch.

## Keynotes

- **Fernando Pérez**: founder of Project Jupyter, UC Berkeley.
- **Mackenzie Weygandt Mathis**: EPFL professor, creator of DeepLabCut
  (neuroscience + AI).
- **Ines Montani**: co-founder and CEO of Explosion, creator of spaCy.
- **Wolf Vollprecht**: creator of Mamba and Pixi, CEO of prefix.dev.

Talk-relevant note: Fernando Pérez (Jupyter / literate computing) is a natural
reference point for nimib, which is a notebook-like literate programming tool
for Nim. Wolf Vollprecht (Pixi, conda-forge packaging) is relevant if the talk
touches on installing Nim or Nim tools through conda/pixi.

## Supporters

QuantStack, CODRA, Inria, Probabl, Stat4decision, SCAI, PyLadies Paris,
R-Ladies Paris, Systematic Paris-Region.

## Precedent: PyData Paris

- PyData Paris 2025: 30 Sept – 1 Oct 2025 at the Cité des Sciences, 3 keynotes
  (Alenka Frim / Apache Arrow, Ralf Gommers / SciPy, Anita Graser / QGIS) and
  45 talks in 3 parallel tracks covering ML, data infrastructure,
  visualization and open-source practice.
- The 2025 schedule (https://pretalx.com/pydata-paris-2025/schedule/) is a good
  proxy for the tone and technical level to expect.

## Open questions to check

- [x] Day, time and room of our talk: Thu 26 Nov, 14:40–15:10, Room 108,
      session "A Babel of Compilers" (confirmed by Pietro from the website).
- [x] Other talks in the "A Babel of Compilers" session (confirmed by Pietro):
      Antonio Cuni and a co-speaker on SPy, and Mamy André-Ratsimbazafy on
      high-performance computing for AI in Nim.
- [ ] Other non-Python language talks (Julia, R, Rust) elsewhere in the
      programme to cross-reference.
- [ ] Recording and streaming policy; slide upload deadline.
- [ ] Projector / screen setup (aspect ratio, HDMI/USB-C) for nimiSlides.
- [ ] Social events and the sprints programme (Sprints page on the site).
- [ ] Travel or accommodation support for speakers (likely none beyond the ticket).

## Sources

- https://compute.events/paris2026/ and https://compute.events/paris2026/cfp.html
  (CfP text pasted by Pietro in the project thread)
- https://pretalx.com/compute-paris-2026/ (CfP page; proposals now closed)
- https://discourse.julialang.org/t/compute-paris-ex-pydata-paris-25-26-november-2026/138889
- https://discourse.julialang.org/t/new-conference-for-open-source-computation-and-data/137283
- https://linuxfr.org/news/compute-paris-2026
- https://www.sorbonne-universite.fr/en/university/rental-conference-facilities/international-conference-centre
- https://parisjetaime.com/eng/convention/pro/centre-international-de-conferences-sorbonne-universite-cicsu-pc4228
- https://pydata.org/paris2025/about
