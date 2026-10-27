# Proposal

## Why

Island 2 is still four placeholders. Pietro picked the two stories and the angle: two competent people did real science with Nim, one in bioinformatics and one in physics. That is the evidence for K3 (Nim is ready for more), told rather than demoed in about two minutes.

## What Changes

- Section 3 of the living outline: slides 3.2 and 3.3 get their story (Brent Pedersen, @brentp, bioinformatics; Vindaar, Sebastian Schmidt, physics), and 3.4 rocks ahead quotes Vindaar on the cost of a tiny ecosystem.
- `slides/island2_stories.nim`: the three placeholders become real slides with short text, one small code excerpt each, links to the papers and the thesis, and speaker notes.
- `slides/island2_brentp_explainer.nim` (new): a nimib explainer of Brent Pedersen's tools, with the genomics background needed to follow them (genome, sequencing, alignment, depth, variants, trios, file formats), toy versions of the mosdepth depth algorithm and of a slivar de novo rule that run at build time, and stars and citations; linked from slide 3.2, built by the pages workflow, listed in the README (following the code explainers principle).
- Decisions: the stories are about doing science with Nim, not about the libraries the two built for the data stack (that is island 3's ground); both are named by name and nick.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None: the abstract spec already asks for at least two concrete success stories (`skip_specs: true`).

## Impact

- `slides/island2_stories.nim`, `slides/island2_brentp_explainer.nim`, `.github/workflows/pages.yml`, `README.md`, `openspec/outline.md` (on archive).
- Timing unchanged: 2 minutes, 4 slides.
