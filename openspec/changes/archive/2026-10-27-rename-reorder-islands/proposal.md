# Proposal

## Why

Pietro (2026-10-27) wants a shorter name for the first island and the interoperability island before the expressive-language one: "without Ceiling" makes the title long on the map, and the order brings interop (calling C, C++ and Python, and Nim from Python) right after the data stack, before the metaprogramming of Island 5.

## What Changes

- Island 1 is renamed from "Accessible Performance without Ceiling" to **Accessible Performance** (timing table, section heading, map); its slides are unchanged, slide 2.4 still says what "no ceiling" means.
- Island 4 is now **Interoperability** (section 5, slides 5.1-5.5, 3 min) and Island 5 is **An Expressive Language** (section 6, slides 6.1-6.6, 2.5 min); slide content is unchanged, only IDs and numbers move. The timing table is reordered (ends at 13:00 and 15:30), the total is unchanged.
- Files follow the island number: `slides/island4_interop.nim` (`island4InteropSection`), `slides/island5_expressive.nim` (`island5ExpressiveSection`) with its helpers `island5_vectors.nim` and `island5_units.nim`, and the explainers `island5_operators_explainer` and `island5_units_explainer` (their deployed URLs change accordingly).
- The README keeps the abstract and agenda verbatim as submitted and gets a section "Changes from the submitted abstract" (no "the" in the title slide, the shorter Island 1, the swapped islands).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `abstract`: the island order and the names of Island 1, 4 and 5.

## Impact

- `my.nim` (island names on the map), `index.nim`, `slides/island1_performance.nim`, renamed island 4/5 files and explainers, `slides/island2_brentp_explainer.nim` (wrapping C is now Island 4), `.github/workflows/pages.yml`, `README.md` (file list), `openspec/specs/abstract/spec.md` and `openspec/outline.md` (on archive).
