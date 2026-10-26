import nimib, nimiSlides
import ../my
import thank_you

# Section 9: Conclusion: back on land (see the latest outline in openspec)
# Takeaways and an opinionated reflection on why Nim is still niche. Carries K1, K3 and K4.

template conclusionSection* =
  slide:
    mapSlide(8) # 9.1
    placeholderSlide("9.2", "For the beginner", """an accessible, fun language to try, at least as a learning tool that shows you your own language's tradeoffs, and where to start.""")
    placeholderSlide("9.3", "For the builder", """the pros and cons of building scientific tools in Nim.""")
    placeholderSlide("9.4", "Your language, seen from Nim", """not "switch to Nim": the tradeoffs of your own language that this voyage made visible, and why diversity of languages is good for scientific computing.""")
    placeholderSlide("9.5", "Why still niche?", """stable for a while and ready for more, yet niche: an opinionated view of the language, the ecosystem and the community, with governance as the main shortcoming, and dev tooling not yet at Rust's level, with Nimony and NIF as the way to catch up [tbd: Pietro's views].""")
    thankYouSlide # 9.6
