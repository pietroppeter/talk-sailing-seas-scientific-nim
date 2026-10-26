import nimib, nimiSlides
import ../my

# Section 2: Island 1: Accessible Performance without Ceiling (see the latest outline in openspec)
# Nim is as easy to write as Python and as fast as C, passed through quickly: performance is not the focus here and Mamy's talk in the same session goes deeper. Carries K2.

template island1PerformanceSection* =
  slide:
    mapSlide(1) # 2.1
    placeholderSlide("2.2", "Reads like Python", """the same small function in Python and in Nim side by side.""")
    placeholderSlide("2.3", "Runs like C", """timing of that function in Python and Nim [example] [tbd: which benchmark].""")
    placeholderSlide("2.4", "No ceiling", """one line on what "no ceiling" means (compiled, static types, control over memory when you need it), then a pointer to Mamy's HPC/AI talk in the same session for the deep dive.""")
