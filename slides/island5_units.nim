import unchained, unchained / ct_api

# Island 5 helper: astronomical masses declared on top of unchained's SI units,
# shown on slide 6.4 (read from this file at build time).
# The macro generates types, so it runs at the top level of its own module:
# it also generates again the compound SI types (e.g. `Meter•Second⁻¹`),
# so the island imports and exports only the new units, to avoid ambiguous types.

# >>> new units
declareUnits:
  Derived:
    SolarMass:
      short: Msun
      quantity: Mass
      conversion: 1.98847e30.kg
    EarthMass:
      short: Mearth
      quantity: Mass
      conversion: 5.9722e24.kg
# <<< new units
