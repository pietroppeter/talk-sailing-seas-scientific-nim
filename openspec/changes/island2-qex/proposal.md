# Proposal

## Why

Pietro wants QEX among the success stories. QEX (Quantum EXpressions) is a lattice QCD framework written in Nim by James Osborn and Xiao-Yong Jin at Argonne National Laboratory: started in 2016, presented in two proceedings (ICHEP 2016, Lattice 2016), still very active (298 commits in 2026), and the code behind other groups' physics papers. It is strong evidence for K3 (Nim is ready for more) from a field where performance is everything.

## What Changes

- Timing: Island 2 goes from 2 to 2.5 minutes, the total from 23 to 23.5 minutes (within the 25 of the format spec).
- Section 3: the intro slide 3.2 announces three stories (🧬 Bioinformatics, ☀️ Physics, ⚛️ Lattice QCD), a new slide 3.5 tells QEX, and rocks ahead becomes 3.6.
- `slides/island2_stories.nim`: the QEX slide with the plaquette loop from QEX's examples, links to the framework paper, the code, a physics paper that uses it and the explainer, and speaker notes.
- `slides/island2_qex_explainer.nim` (new): lattice QCD and QEX in plain words, the QEX plaquette code explained, a toy 2D U(1) lattice with Metropolis that runs at build time and matches the exact answer, who builds QEX (commit counts), the papers, and the neural network field transformations added to QEX in 2026; linked from slide 3.5, built by the pages workflow, listed in the README.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None: the abstract spec already asks for at least two concrete success stories (`skip_specs: true`).

## Impact

- `slides/island2_stories.nim`, `slides/island2_qex_explainer.nim`, `.github/workflows/pages.yml`, `README.md`, `openspec/outline.md` (on archive).
