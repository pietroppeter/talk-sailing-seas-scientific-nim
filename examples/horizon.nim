import nimib, std/math
nbInit

nbText "### From the deck of a boat"
nbCode:
  let earth = 6371e3 # m, radius
  let eyes = 2.0     # m above the sea
  let horizon = sqrt(2 * earth * eyes)
  echo horizon.round, " m"
nbText "Horizon: **" &
  $round(horizon / 1000, 1) & " km**"

nbSave
