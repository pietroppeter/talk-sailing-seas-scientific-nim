---
name: nimib-review
description: Use when a review export from a nimib page is pasted in the chat (Markdown with a YAML block or front matter holding `format: nimib-review/1` to `/6`), to apply each comment to the page's source and close the review round.
metadata:
  status: draft
---

# Apply a review export

The review mode of a nimib page (`review.nim`, ported from tabelline; every page that calls `nb.usePage` has it) lets a reader
open the review with a button, select text, comment on it, and export every comment as one text:
a title, a YAML block (a ```yaml fence since `nimib-review/2`; a front matter between `---` lines
in `nimib-review/1`), then one Markdown section per comment, in page order. This skill turns that
text into changes.

## 1. Read the export

- The YAML says which page (`page`, its URL), which notebook builds it (`source`, a path
  in the repository), which `version` was read, the `commit` it was built from (`/4`), and how
  many `comments` there are. The version is the number of commits that changed the source (`12+`:
  built from uncommitted changes; 7 hex characters: built outside git). Check that the
  count matches the `## n.` sections: a long paste can arrive cut short, and the count is how you
  notice. If it does not match, say so.
- Each section is `## n. Where` in `nimib-review/3` to `/6`: `In “Heading” (#id)`, `At the top`, or
  `On the whole page` (no quote: the note is about the page as a whole). Every comment is a note;
  a replacement is said in it, as `Replace with: ...`, or `Remove`. Do what the note asks.
- In `/1` and `/2` the section is `## n. Kind, where`:
  - `Comment`: do what the note asks.
  - `Replace`: replace the quoted text with the text in the `~~~text` fence; the note, if any,
    says why.
  - `Remove` (`Cut` in exports of version 3 and before): remove the quoted text and mend the
    sentence around it.
  A `/3` to `/5` export may still hold one of these, from a comment written on an older version.
- `Written in \`slides/intro.nim:42\`` under a heading (`/6`): the quoted text is not written in
  the page's `source` but there, at the call that starts it (a speaker note of a slide, in the
  blog post made from the deck: `blog.nim`, `blogpost.nim`). Change it there; the heading then
  names the slide (`In “Slide 12 · Ecosystem”`). A change to a speaker note changes the deck's
  notes too: that is the point.
- `From version 7 (commit a1b2c3d).` under a heading (`/5`): the comment was written on an older
  version than the export's, and kept in the browser (History's **Export** or **Export
  everything**). Check it before you apply it: see step 2.
- `> quote` is the exact text the reader selected, as the page shows it, whitespace collapsed.
  `Around it: “…before ⟦quote⟧ after…”` gives the words around it, to tell apart a quote found
  more than once. `(#id)` is the anchor of the heading the quote is under.
- `Screenshots: review-v2-3-1.jpg, ...` names images that go with the export: the reviewer
  pastes the text, then attaches each image (copied with *Copy image* in the export, or from
  the phone's photos), in the same message or the next ones. Look at them before changing
  anything: they often show what the words can't (a layout, a zoom, a colour). If they are
  named but missing, ask for them. An export of version 3 may end with `## Screenshots, small`
  (data-URL images): decode them to look, and don't keep that section in the saved round.
- The text may have been edited by hand before it was sent: trust what it says over the format.
- `(Not found on the page any more.)`: the text changed after the comment was written. Apply it
  where it still makes sense, or ask.

## 2. Find each quote in the source

When the export has a `commit`, first see what changed in the source since it was read:
`git log --oneline <commit>..HEAD -- <source>` and `git diff <commit> -- <source>`. A comment
on text that changed since may already be done, or need reading again.

A comment from an older version (`From version N`, or an export whose `version` is older than
the page's) needs checking before it is applied, because the page moved on since:

- Diff from the comment's own commit when it has one (`git diff <its commit> -- <source>`),
  else from the export's, else find the version's commit: the version is the number of commits
  that changed the source, so `git log --reverse --format=%h -- <source> | sed -n <N>p`.
- Still valid: the quote is still on the page and the note still asks for something not done.
  Apply it.
- Already done: the diff made the change it asks for. Say so, and change nothing.
- Moot: the text it is about is gone or rewritten (`(Not found on the page any more.)`, or the
  diff removed it). Say what became of that text, and ask only if the note still points to
  something worth doing.
- In the reply, list the older comments apart, each as valid (applied), already done or moot.

The quote is rendered text, not source. Search the notebook for it, and expect:

- Markdown marks gone: `**bold**`, `` `code` ``, `*em*` appear without their marks, a link shows
  only its text, a line break in the source is a space in the quote.
- Text made by code (a table, a generated list, an index, a block of `blocks.nim` or
  `review.nim`) is not in the notebook's text: find the code or the data file that makes it.
- Text in a shared header or footer, or in a list of pages, comes from `deepdive/deepdive.nim`
  (deep dives), `devlog/devlog.nim` (talk log) or `blocks.nim`, which change more than one page:
  say so before changing it.

## 3. Make the changes

Change the notebook named in `source`, or the file a comment says it is `Written in`. There are no versions to keep: git keeps them, and the
commit that holds the changes is the page's next version (its comments start empty).


## 4. Build, check, report

- Rebuild with `nim r build.nim` and the page's group (`deepdives`, `devlog`), look at the page at
  390px (Playwright), and make sure the build's checks pass.
- Reply by theme, not in the order of the comments: group the comments that ask for related
  changes, and for each theme say what was asked (with the comments' numbers) and what changed,
  or the question it raises. Comments that only say something works go in a section of their
  own at the end. Every comment is in the reply once; don't skip one silently, and don't change
  what no comment asked for.
