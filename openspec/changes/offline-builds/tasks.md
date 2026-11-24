# Tasks

## Layouts

- [x] L.1 Vendor water.css, nimib's assets and plotly.js into `docs/assets/` with `scripts/vendor-assets.sh`; verify the other vendored assets are unchanged after rerunning it
- [x] L.2 `offline.nim` with `nb.useOfflineAssets`, used by every explainer and the talk log; `slides/nbplotly.nim` loads the vendored plotly.js
- [x] L.3 `nim r build.nim` with groups and the offline check; the pages workflow runs it; README documents it

## Whole talk

- [x] W.1 `nim r build.nim` builds every page and the check passes; every page opened in Chromium with the network off makes no network request and logs no error; screenshots of an explainer with math, the penguins plot and a talk log post

## Workflow follow-up

- [ ] Archive the change after Pietro's review.
