# The talk

Status: accepted · Updated 2026-11-24

## Context

"Sailing the Seas of Scientific Nim", by Pietro Peterlongo (@pietroppeter), was accepted at Compute! Paris 2026 (successor of PyData Paris, organized by QuantStack): Thursday 26 November 2026, 14:40-15:10, Room 108, Centre International de Conférences de Sorbonne Université (CICSU), session "A Babel of Compilers". Talk page: https://pretalx.com/compute-paris-2026/talk/8EM8ZA/

The abstract and description, verbatim as submitted, are in the [README](../README.md#abstract), their single source. The CfP's guidelines on talk quality are in [notes/conference.md](../notes/conference.md).

Speaker bio as submitted: Data Scientist Delivery Lead at AgileLab (Consulting in Data for Enterprises), I am passionate about Open Source and Tech communities. Before AgileLab I worked for almost 9 years as a Data Scientist/Software Engineer in a product company for Supply Chain Planning and Optimization. Then I took a sabbatical where I went on a programming retreat (Recurse Center) and went all in on tech communities. I help organize the local Python Milan meetup and helped launch the PyData Milan meetup. I got the programming language bug thanks to an underdog programming language (Nim), this led me into Open Source (Nimib). I have a background as a mathematician and I did not complete a PhD in Math Applied to Climate Dynamics (that brought me to live two years in Paris).

## Decision

- **Title.** "Sailing the Seas of Scientific Nim" in the programme; the title slide uses the short form "Sailing Seas of Scientific Nim", so it fits one line. The talk answers the abstract's question: why Nim, a general purpose statically typed and compiled language, is a good fit for scientific computing.
- **Promise kept.** The talk delivers what the title, summary and description promise: every agenda item of the description has a section in the deck. Deviations from the submitted agenda are listed in the README, "Changes from the submitted abstract" (Pietro, 2026-10-27).
- **Time.** 30 minutes including Q&A: content takes at most 25 minutes, aiming at 22-25. The outline gives minutes per section, as the CfP asks; today 23.5 minutes ([outline.md](../outline.md)).
- **Audience.** Two primary audiences: the scientific computing beginner, who leaves with a first introduction to a language that is accessible, fun and possibly useful (at least as a learning tool), and the ecosystem builder, who can weigh the pros and cons of building scientific tools in Nim. Language enthusiasts and community builders are a secondary audience.
- **Background of the room.** Mostly Python and Jupyter people, so Python-like examples and comparisons are the bridge to Nim; but examples must also make sense to R, C++ and HPC people. No prior Nim knowledge is needed: a Python user can tell what a code example does from the code and the explanation.
- **Roles.** Both library authors (who judge Nim as a language to build in) and library users (who judge it as a daily tool); each island speaks mainly to one or both.
- **The session.** Mamy André-Ratsimbazafy talks about high-performance computing for AI in Nim, Antonio Cuni about SPy: HPC and AI stay brief here and point to Mamy's talk.
- **Format.** An example-driven tour with a light travel narrative, not a tutorial: no slides that teach syntax for its own sake. New material, not a reused deck. Every example built into the deck well before the day.

## Options considered

- The full title on the title slide: two lines, set aside.

## Consequences

- Nine sections in about 23 minutes leave about 2.5 minutes per island: one core slide per island carries the message, everything else can be cut, and the timing is checked in rehearsal.

## History

- 2026-10-26: requirements from the abstract, audience and format (PR #7, #8, OpenSpec specs).
- 2026-10-27: island names and order changed from the submitted agenda (PR #23).
- 2026-10-28: 23.5 minutes with the QEX story (PR #25).
- 2026-11-24: moved from OpenSpec specs (abstract, audience, format) to this record.
