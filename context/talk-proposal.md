# Talk proposal: Sailing the Seas of Scientific Nim

Copied verbatim from the Compute! Paris 2026 talk page (pasted by Pietro on
2026-10-04, since pretalx.com is not reachable from the cloud environment).

## At a glance

| Field | Value |
|---|---|
| Title | Sailing the Seas of Scientific Nim |
| Speaker | Pietro Peterlongo (@pietroppeter) |
| Conference | Compute! Paris 2026 (formerly PyData Paris), 25–26 Nov 2026, Centre International de Conférences de Sorbonne Université |
| Slot | **Thursday 26 Nov 2026, 14:40–15:10**, Room 108 |
| Session / track | A Babel of Compilers |
| Format | Talk, 30 minutes (CfP: 30 min including Q&A) |
| Status | Accepted |
| Audience | Scientific computing beginners and ecosystem builders; also PL enthusiasts and community builders |
| Slides tooling | nimib + nimiSlides |
| Talk page | https://pretalx.com/compute-paris-2026/talk/8EM8ZA/ (schedule view: https://compute.events/paris2026/schedule.html#session/8EM8ZA/) |

Other speakers in the "Babel of Compilers" session reportedly include Antonio
Cuni and Mamy André-Ratsimbazafy (from a search summary, not verified).

## Abstract

Programming languages used in Scientific Computing have evolved from Fortran to Python, but many languages are still actively used and are important in the ecosystem (C, C++, R). New languages made specifically for solving problems of the scientific ecosystem have been created (Julia). Is there space for one more? Why is Nim, a general purpose statically typed and compiled language, a good fit for Scientific Computing? We will make a quick travel around seven islands that represent important themes where Nim shows its powers. The talk will not hide where Nim falls short.

## Description

Talking about a niche programming language is a bit like traveling to an exotic land, where most people will feel like strangers. That is why, after a brief introduction motivating why there are so many programming languages in the scientific computing ecosystem, the talk will be structured around a quick hop through seven different "islands" that will showcase the unique capability of Nim programming language and its ecosystem.

The talk targets the scientific computing beginner and the ecosystem builder. For the beginner, we aim to have a first introduction to a language that is accessible, fun to play with, and possibly useful in the day to day work (at the very least as a learning tool). The builder should be able to evaluate the pros and cons of building scientific computing tools in Nim. Programming languages enthusiasts and community builders might also find the talk interesting.

The agenda of the talk:

- **Intro**: motivates why there are so many programming languages in scientific computing and that there is still space for more.
- **Accessible Performance without Ceiling** (first island): at a high level, Nim is as easy to write as Python and as fast as C.
- **Success stories** (second island): even with a niche language and in a tiny ecosystem, pioneers have been using Nim successfully in Scientific Computing. A couple of stories to inspire us.
- **Data Stack** (third island): a quick go through the basic building blocks of the ecosystem (tensor library, dataframe library, plotting library) explained with a Data Exploration of the classical penguins dataset.
- **An Expressive Language** (fourth island): two language features that make Nim good for scientific use. Defining custom operators (easy to use feature) and metaprogramming (advanced feature).
- **Interoperability** (fifth island): Nim is easy to interoperate with various languages. It is very easy to wrap existing libraries in C, C++ in case you need them. The ecosystem also provides two way bridges to Python, R, Julia (of varying degrees of maturity). What you build in Nim can be very easily used in Python (almost like Rust).
- **Interactivity** (sixth island): interactivity is very important for scientific computing, we will showcase one of Nim superpowers (compiling to Javascript) using a snappy port of a fun Shiny app. No, interactivity as in a Jupyter or Marimo notebook is not yet there.
- **Notebook** (seventh island): Jupyter showed how central the literate programming/computing paradigm is to scientific computing. An interesting option in Nim ecosystem goes in an unexpected direction.
- **Conclusion**: we touch back land. We give takeaways for beginner and builder and reflect why Nim is still a niche language. A brief and opinionated view about the language, the ecosystem, the community and the governance.

The talk will use examples from the ecosystem to showcase the power of Nim but it will NOT contain a tutorial of the language. This is possible because Nim reads like Python and the examples should be easy enough understand without knowing the language. Of course if you look up a tutorial of the language before the talk you might be in a better position to appreciate it, but it is not a requirement.

## Speaker bio

Data Scientist Delivery Lead at AgileLab (Consulting in Data for Enterprises), I am passionate about Open Source and Tech communities. Before AgileLab I worked for almost 9 years as a Data Scientist/Software Engineer in a product company for Supply Chain Planning and Optimization. Then I took a sabbatical where I went on a programming retreat (Recurse Center) and went all in on tech communities. I help organize the local Python Milan meetup and helped launch the PyData Milan meetup. I got the programming language bug thanks to an underdog programming language (Nim), this led me into Open Source (Nimib). I have a background as a mathematician and I did not complete a PhD in Math Applied to Climate Dynamics (that brought me to live two years in Paris).

## Notes for preparing the talk

- **Time budget**: 30 minutes including Q&A means roughly 25 minutes of content
  for an intro, seven islands and a conclusion, so about 2.5–3 minutes per island.
- **Commitments the proposal makes** (each needs a concrete demo or example):
  - Island 1: a Python-vs-C style performance comparison.
  - Island 2: a couple of scientific computing success stories in Nim.
  - Island 3: an exploration of the penguins dataset with the tensor, dataframe and plotting libraries.
  - Island 4: a custom operator example and a metaprogramming example.
  - Island 5: C/C++ wrapping, bridges to Python/R/Julia, and a Nim library used from Python.
  - Island 6: a Nim→JavaScript port of a fun Shiny app.
  - Island 7: nimib (the "unexpected direction" for notebooks).
  - Conclusion: takeaways for beginners and builders, plus an opinionated look at the language, ecosystem, community and governance.
- **No language tutorial**: examples must be readable by Python users without prior Nim knowledge.
- **Audience**: largely the Python/PyData scientific community. Keynotes include
  Fernando Pérez (Jupyter), Mackenzie Mathis, Inès Montani (spaCy) and Wolf Vollprecht (Pixi).
- **Related prior talk**: "Nimib-land: an extensible ecosystem for Literate
  Programming and Explorable Explanations" (FOSDEM 2024).
