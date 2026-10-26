import nimib, nimiSlides
import ../my

# Section 4: Island 3: Data Stack (draft outline, see openspec/changes/draft-outline/outline.md)
# The basic building blocks of the data ecosystem, through an exploration of the penguins dataset. Carries K2 and K3.

template island3Section* =
  mapSlide(3) # 4.1
  placeholderSlide("4.2", "Meet the penguins", """the palmerpenguins dataset in one slide, a familiar sight for the Python and R crowd.""")
  placeholderSlide("4.3", "Dataframe", """load and summarise the penguins in a dataframe [example] [tbd: library].""")
  placeholderSlide("4.4", "Plot", """a scatter plot of the penguins [example] [tbd: library].""")
  placeholderSlide("4.5", "Tensor", """the tensor library underneath, one small computation [example] [tbd: library].""")
  placeholderSlide("4.6", "Rocks ahead", """one honest limitation of the data stack [tbd].""")
