import unchained, unchained / ct_api

# Island 4 helper: sailing units declared on top of unchained's SI units,
# shown on slide 5.3 (read from this file at build time).
# The macro generates types, so it runs at the top level of its own module:
# it also generates again the compound SI types (e.g. `Meter•Second⁻¹`),
# so the island exports only the new units, to avoid ambiguous types.

# >>> sailing units
declareUnits:
  Derived:
    NauticalMile:
      short: nmi
      quantity: Length
      conversion: 1852.0.m
    Knot:
      short: knot
      quantity: Velocity
      conversion: 0.514444.m•s⁻¹ # 1 nmi/h
# <<< sailing units
