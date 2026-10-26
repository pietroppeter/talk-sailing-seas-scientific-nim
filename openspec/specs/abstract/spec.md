# abstract Specification

## Purpose

Turns the talk as submitted and accepted (title, abstract and description in the README) into requirements: the structure of intro, seven islands and conclusion.

## Submitted text

Title: **Sailing the Seas of Scientific Nim**, by Pietro Peterlongo (@pietroppeter). Talk page: https://pretalx.com/compute-paris-2026/talk/8EM8ZA/

The abstract and description, verbatim as submitted, are in the [README](../../../README.md#abstract), which is their single source of truth. The speaker bio as submitted is below.

### Speaker bio

Data Scientist Delivery Lead at AgileLab (Consulting in Data for Enterprises), I am passionate about Open Source and Tech communities. Before AgileLab I worked for almost 9 years as a Data Scientist/Software Engineer in a product company for Supply Chain Planning and Optimization. Then I took a sabbatical where I went on a programming retreat (Recurse Center) and went all in on tech communities. I help organize the local Python Milan meetup and helped launch the PyData Milan meetup. I got the programming language bug thanks to an underdog programming language (Nim), this led me into Open Source (Nimib). I have a background as a mathematician and I did not complete a PhD in Math Applied to Climate Dynamics (that brought me to live two years in Paris).

## Requirements

### Requirement: Talk keeps its title
The talk SHALL be titled "Sailing the Seas of Scientific Nim" in the conference programme, and the title slide SHALL use the short form "Sailing Seas of Scientific Nim" so the title fits on one line. The talk SHALL answer the abstract's question: why Nim, a general purpose statically typed and compiled language, is a good fit for scientific computing.

#### Scenario: Title slide
- **WHEN** the deck opens
- **THEN** the title slide reads "Sailing Seas of Scientific Nim" with the speaker's name

### Requirement: Intro, seven islands, conclusion
The talk SHALL consist of an intro, seven islands and a conclusion, in this order: Intro; Accessible Performance without Ceiling; Success Stories; Data Stack; An Expressive Language; Interoperability; Interactivity; Notebook; Conclusion.

#### Scenario: Section order
- **WHEN** the deck is paged through
- **THEN** the sections appear in the order above, each island clearly announced as the next stop of the journey

### Requirement: Intro motivates many languages
The intro SHALL motivate why there are so many programming languages in scientific computing (from Fortran to Python, with C, C++, R and Julia still important) and that there is still space for more.

#### Scenario: Intro hand-over
- **WHEN** the intro ends
- **THEN** the audience has seen why one more language is worth a look and the journey to the first island starts

### Requirement: Island 1, Accessible Performance without Ceiling
The first island SHALL show, at a high level, that Nim is as easy to write as Python and as fast as C.

#### Scenario: Performance claim
- **WHEN** the first island ends
- **THEN** the audience has seen evidence for both the ease (Python-like code) and the speed (C-like performance)

### Requirement: Island 2, Success Stories
The second island SHALL tell a couple of stories of pioneers who used Nim successfully in scientific computing, despite the niche language and tiny ecosystem.

#### Scenario: Stories told
- **WHEN** the second island ends
- **THEN** at least two concrete success stories have been presented

### Requirement: Island 3, Data Stack
The third island SHALL go through the basic building blocks of the data ecosystem (tensor library, dataframe library, plotting library) through a data exploration of the classical penguins dataset.

#### Scenario: Building blocks covered
- **WHEN** the third island ends
- **THEN** a tensor, a dataframe and a plot library have each appeared in the penguins exploration

### Requirement: Island 4, An Expressive Language
The fourth island SHALL show two language features that make Nim good for scientific use: defining custom operators (an easy feature) and metaprogramming (an advanced feature).

#### Scenario: Two features shown
- **WHEN** the fourth island ends
- **THEN** one custom operator example and one metaprogramming example have been shown

### Requirement: Island 5, Interoperability
The fifth island SHALL show that Nim interoperates easily: wrapping existing C and C++ libraries, two-way bridges to Python, R and Julia (of varying maturity), and Nim code used from Python almost as easily as Rust.

#### Scenario: Interop directions
- **WHEN** the fifth island ends
- **THEN** both directions have been shown: calling C/C++ or Python from Nim, and using Nim from Python

### Requirement: Island 6, Interactivity
The sixth island SHALL showcase compiling Nim to JavaScript with a snappy port of a fun Shiny app, and SHALL say openly that interactivity as in a Jupyter or Marimo notebook is not there yet.

#### Scenario: Interactive demo
- **WHEN** the sixth island is presented
- **THEN** the audience sees the Nim-to-JavaScript port running in the browser and hears the limitation about notebook-style interactivity

### Requirement: Island 7, Notebook
The seventh island SHALL connect to the literate programming/computing paradigm that Jupyter made central, and present the Nim option that goes in an unexpected direction (nimib).

#### Scenario: Notebook island
- **WHEN** the seventh island ends
- **THEN** the audience knows what nimib is and how it differs from a Jupyter notebook

### Requirement: Conclusion touches back land
The conclusion SHALL give takeaways for the beginner and the builder, reflect on why Nim is still a niche language, and give a brief, opinionated view of the language, the ecosystem, the community and the governance.

#### Scenario: Closing
- **WHEN** the conclusion ends
- **THEN** the language, ecosystem, community and governance have each been addressed

### Requirement: Shortcomings are not hidden
The talk SHALL say where Nim falls short, not only where it shines.

#### Scenario: Honest tour
- **WHEN** the talk is over
- **THEN** the audience has heard concrete weaknesses of Nim or its ecosystem
