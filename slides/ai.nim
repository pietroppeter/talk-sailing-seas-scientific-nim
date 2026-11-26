import nimib, nimiSlides
import ../my

# Opening, slide 0.3: AI, right after about me, in the context of this talk
# (content dictated by Pietro in the first dry run, 2026-11-26)

template aiSlide* =
  slide:
    nbText """
## 🤖 the AI slide (Nov 2026)

A lot is changing. For the context of this talk:

- Programming languages matter less
- 👀 **AI writes excellent Nim** (compiler, static types, low cognitive load)
- A small ecosystem hurts less: binding/porting is easy

What does not change (becomes more important):

- *Judgment*: what you point your agent at, when to stop
- *Ownership*: you own everything you put out
- *Trust*: the trust you build with your community of users
"""
    reference "(me: went heavy on AI only in last two months)"
    speakerNote """
It is November 2026, so I need an AI slide. Let me keep
it to the context of this talk. Three things.

One: AI makes the choice of programming language less
important, and in a way that is liberating.

Two: a small language is not a problem for AI. AI writes
excellent Nim code: it is compiled and statically typed,
so the compiler checks what the agent writes. In my
experience it often writes better Nim than Python.

Three: some issues of a small language, like a small
ecosystem, matter much less with AI: porting a library
is very, very easy.

My experience is limited: I spent the last year learning
to be a manager, and only in the last couple of months
I really went deep into AI. Take it with a grain of salt.

What does not change, and becomes more important, are
three things. Judgment: picking what to point your agent
at, and when to tell it to stop, matters more than ever.
Ownership: you own everything you put out. Trust: the
trust you build with your community of users is worth
more than ever, and an irresponsible use of AI, one
that shows poor judgment, erodes it much more easily.
"""

when isMainModule: # this part of the deck on its own: docs/slides_ai.html
  buildDeckPart("ai", "slides/ai.nim"):
    aiSlide
