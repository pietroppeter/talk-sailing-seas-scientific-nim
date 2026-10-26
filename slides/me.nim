import nimib, nimiSlides
import ../my

# Opening, slide 0.2: about me (not part of the intro section, like the title slide)

template meSlide* =
  placeholderSlide("0.2", "About me", """mathematician, data scientist at AgileLab, nimib maintainer, Python Milan and PyData Milan organizer; the Paris climate-dynamics years as a personal hook [tbd: which details Pietro wants on stage].""")
