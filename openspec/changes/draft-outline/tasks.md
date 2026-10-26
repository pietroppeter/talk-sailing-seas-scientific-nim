# Tasks

Every slide task below means: a slide with the outline's title as heading, the outline's one-line description as speaker note, and `[tbd]` shown on the slide where the outline marks it. "Verify in the screenshots" means `nim r index.nim` succeeds and the slide appears in `scripts/screenshot.sh docs/index.html <outdir>`.

## 1. Intro: leaving the mainland

- [ ] 1.1 Slide "Sailing the Seas of Scientific Nim": fix the title in slides/title.nim to the accepted title (with "the"); verify in the screenshots
- [ ] 1.2 Slides 1.2-1.6 in slides/intro.nim as template `introSection`, wired into index.nim after `titleSlide`; verify in the screenshots
- [ ] 1.3 Map slide helper `mapSlide(n)` in my.nim, a text-only placeholder listing the seven islands with island n highlighted (used by 1.6 and each island title); verify the highlighted island differs per section in the screenshots

## 2. Island 1: Accessible Performance without Ceiling

- [ ] 2.1 Slides 2.1-2.5 in slides/island1-performance.nim as template `island1Section`, wired into index.nim; verify in the screenshots

## 3. Island 2: Success Stories

- [ ] 3.1 Slides 3.1-3.4 in slides/island2-stories.nim as template `island2Section`, wired into index.nim; verify in the screenshots

## 4. Island 3: Data Stack

- [ ] 4.1 Slides 4.1-4.6 in slides/island3-datastack.nim as template `island3Section`, wired into index.nim; verify in the screenshots

## 5. Island 4: An Expressive Language

- [ ] 5.1 Slides 5.1-5.4 in slides/island4-expressive.nim as template `island4Section`, wired into index.nim; verify in the screenshots

## 6. Island 5: Interoperability

- [ ] 6.1 Slides 6.1-6.5 in slides/island5-interop.nim as template `island5Section`, wired into index.nim; verify in the screenshots

## 7. Island 6: Interactivity

- [ ] 7.1 Slides 7.1-7.4 in slides/island6-interactivity.nim as template `island6Section`, wired into index.nim; verify in the screenshots

## 8. Island 7: Notebook

- [ ] 8.1 Slides 8.1-8.4 in slides/island7-notebook.nim as template `island7Section`, wired into index.nim; verify in the screenshots

## 9. Conclusion: back on land

- [ ] 9.1 Slides 9.1-9.5 in slides/conclusion.nim as template `conclusionSection`, wired into index.nim; verify in the screenshots

## Whole talk

- [ ] W.1 Build the full deck and screenshot every slide; verify the deck has the nine sections in outline order and the slide count matches the outline (43 slides)
- [ ] W.2 Read-through of the speaker notes against the timing table; verify each section's notes fit its minutes

## Workflow follow-up

- Share the screenshots with Pietro in the project thread.
- Archive the change after Pietro's review, so `key-messages` becomes a main spec.
