import nimib, nimiSlides
import ../my

# Section 5: Island 4: An Expressive Language (draft outline, see openspec/changes/draft-outline/outline.md)
# Two language features that make Nim good for scientific use. Carries K2 (metaprogramming superpower).

template island4Section* =
  mapSlide(4) # 5.1
  placeholderSlide("5.2", "Custom operators", """defining an operator in one line and using it in a formula (the easy feature) [tbd: example].""")
  placeholderSlide("5.3", "Metaprogramming", """a macro or template that removes boilerplate in a scientific setting (the advanced feature) [tbd: example].""")
  placeholderSlide("5.4", "Rocks ahead", """with great power: macros can make code hard to read for newcomers; concepts (compile-time duck typing) were not robust until possibly recently.""")
