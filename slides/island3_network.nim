import std / [sequtils, strutils]
import nimib
import nimiSlides except speakerNote # blogpost.nim has its own (my.nim exports it)
import arraymancer / [tensor, nn, autograd]
import nanuq
import ../my

# Island 3, slide 4.5: a small neural network, written with Arraymancer's `network` macro,
# learns the species of a penguin from its four measurements when the deck is built.
# A template of its own module (not dirty): `nn` and nanuq stay out of the deck's scope.
# `network` runs at the top level of this module: inside a template its layers do not parse,
# so the slide shows its source (read between the markers) and runs the training.
# Paths are relative to docs/ (nimib's homeDir), as in island3_datastack.nim.

const
  measures = ["bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g"]
  speciesNames = ["Adelie", "Chinstrap", "Gentoo"]

proc penguinTensors*(): tuple[xTrain, xTest: Tensor[float32], yTrain, yTest: Tensor[int]] =
  ## the measured penguins as tensors: four standardized measurements and the species
  ## (0, 1, 2); even rows to train, odd rows to test
  let df = readCsv("data/penguins.csv").dropNulls(measures)
  var x = newTensor[float32](df.height, measures.len)
  for j, name in measures:
    for i, v in df.cast({name: Float64}).toList(name, float):
      x[i, int(j)] = v.float32
  x = (x -. x.mean(axis = 0)) /. x.std(axis = 0)
  let y = df.toList("species", string).mapIt(speciesNames.find(it)).toTensor
  let (even, odd) = (toSeq(countup(0, df.height - 1, 2)), toSeq(countup(1, df.height - 1, 2)))
  (x.index_select(0, even), x.index_select(0, odd), y.index_select(0, even), y.index_select(0, odd))

# >>> network
network PenguinNet: # a macro: layers and forward pass
  layers:
    hidden: Linear(4, 16) # bill length and depth, flipper, mass
    output: Linear(16, 3) # Adelie, Chinstrap, Gentoo
  forward x:
    x.hidden.relu.output
# <<< network

proc networkCode*: string =
  ## the declaration above, as shown on the slide
  const source = staticRead("island3_network.nim")
  source.split("# >>> network\n")[1].split("# <<< network")[0].strip

proc bestOf*(scores: Tensor[float32]): Tensor[int] =
  ## the column of the highest score in each row: the network's guess
  ## (as argmax(axis = 1), whose generated C code does not compile with Nim 2.2.12)
  result = newTensor[int](scores.shape[0])
  for i in 0 ..< scores.shape[0]:
    for j in 1 ..< scores.shape[1]:
      if scores[i, j] > scores[i, result[i]]: result[i] = j

proc accuracy*(predicted, actual: Tensor[int]): string =
  ## the share of right answers, as a percentage
  $int(100 * (predicted ==. actual).astype(float).mean) & "%"

template networkSlide* =
  slide: # 4.5
    nbText "## Deep learning: Arraymancer"
    let ctx = newContext Tensor[float32]
    let (train, test, yTrain, yTest) = penguinTensors()
    let (xTrain, xTest) = (ctx.variable train, ctx.variable test)
    nbShowCode networkCode()
    nbCode:
      let model = ctx.init(PenguinNet)
      var optim = model.optimizer(SGD, learning_rate = 0.1'f32)
      for epoch in 1 .. 300:
        model.forward(xTrain).sparse_softmax_cross_entropy(yTrain).backprop()
        optim.update()
      let guess = model.forward(xTest).value.bestOf # the top score
      echo "right on unseen penguins: ", accuracy(guess, yTest)
    nbTextSmall """
Autograd, layers, optimizers;
since October 2026 also GPT-2-like transformers
([by lucidrains](https://github.com/mratsim/Arraymancer/pull/695)).
Step by step in 🐋 [the deep dive](deepdive/penguins_data_stack.html).
"""
    speakerNote """
On top of the tensors, a compact deep learning framework, as in PyTorch.
`network` is a macro: you list the layers and write the forward pass.
Half the penguins train it, the other half check it,
when the deck is built.
In October 2026 lucidrains (Phil Wang, known for his many
transformer implementations in PyTorch) added transformers
and a GPT-2-like example,
a promise he made in an issue in 2023.
The API is marked unstable, and classic machine learning
is a handful of algorithms: more in the deep dive.
"""

when isMainModule: # this part of the deck on its own: docs/slides_island3_network.html
  buildDeckPart("island3_network", "slides/island3_network.nim"):
    networkSlide
