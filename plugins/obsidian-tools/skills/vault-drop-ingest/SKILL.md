---
name: vault-drop-ingest
description: Use when the user drops source material into their vault and wants it turned into notes — emails (.eml/.msg), Office files (.docx/.xlsx/.pptx), HTML reports, PDFs — or says "process my inbox", "turn this email into a meeting note", "what's in this report". Explores the file's real structure first, extracts the data, then produces an index note plus separate requirement notes for the action items.
---

# Ingest dropped source material into notes

Two failure modes to avoid, and they pull in opposite directions:

1. **Reading the whole file into context.** An 8 MB email or a 283 KB embedded JSON
   blob will fill the window and leave nothing for the actual work.
2. **Trusting the surface.** The visible text is often not where the content is.

So: explore, extract with a script, then write. Never open the raw file blind.

Read `${CLAUDE_PLUGIN_ROOT}/references/safety.md` before moving any original file,
and `${CLAUDE_PLUGIN_ROOT}/references/vault-conventions.md` for where notes go.

## 1. Find the drop zone

The vault's `CLAUDE.md` defines it — commonly the vault root plus an inbox folder.
Anything there that isn't a note is a candidate.

## 2. Explore before extracting

Check size and format first. Then, per type:

| Type | Where the content actually is |
| --- | --- |
| `.eml` | Python stdlib `email` handles it. **Walk the attachments** — the thread body is often the least valuable part |
| `.msg` | Outlook's own format; needs `extract-msg`. Not a renamed `.eml` |
| `.docx` `.xlsx` `.pptx` | Zip archives of XML. Unzip and parse; don't try to read them as text |
| `.html` | **Check for `<script>` blocks before trusting the visible text.** Dashboards and exported reports routinely ship a few dozen lines of markup wrapping a large JSON payload — that payload is the content |
| `.pdf`, images | Don't script these. Open them with the Read tool, which handles them natively |

The HTML case is worth stating as a rule, because the failure is silent: a file whose
visible text is 32 lines can carry 283 KB of JSON and 161 records. If you summarise
the visible text you will confidently report almost nothing, and it will read as a
complete summary. **Grep for `<script` and check payload sizes first.**

## 3. Extract with a script, not by reading

Write (or reuse) a small extraction script that emits structured text to a scratch
file, then read *that*. This keeps the raw file out of context and makes the
extraction reproducible.

If the vault already has an extraction tool, use it — it encodes decisions about
which formats are in scope. Note that its dependencies (`extract-msg` and friends)
live in a specific virtualenv; call that interpreter explicitly.

## 4. Produce two kinds of note — this is the core of the skill

**Index note** — "what does this material say". Goes in the relevant project's
folder. Carries provenance frontmatter (source filename, type, version, ingest date),
a summary, distribution tables if the data is tabular, and the full detail table.

**Requirement notes** — "so what do I have to do". Every action item, gap, and
feature request in the material becomes its **own note** per the vault's task data
model (`vault-conventions.md` §4), with `source:` pointing back at the index note.

The split is what makes the ingest worth doing. An index note alone is an archive;
the requirement notes are what surface later in a todo query. **Do not compress the
action items into a checkbox list at the bottom of the index note** — that is the
mistake this skill exists to prevent.

For a discussion thread, the note is a **meeting note**, not a transcript: extract
conclusions, decisions, action items *with owners*, and hard numbers. Nobody rereads
a pasted email chain.

## 5. Route it to a project

Decide which project the material belongs to. If none fits, create the project note
first (`vault-project-note`) — an index note with no parent project is unreachable.

Then update the project's requirements canvas: add the material under its
sources branch, and any newly-found gaps under the gaps branch.

## 6. Where originals go

Originals that came from outside any repo move to the vault's attachments folder
(emails often have their own subfolder). **Move, don't delete** — notes reference
them. Clear the drop zone so the next run starts clean, and delete the scratch
extraction files.

Two exceptions:

- **Material already inside a repo** (e.g. under the repo's `docs/`) — reference it
  by path. Don't copy it into the vault; you'd be forking a file that has an owner.
- **Anything that failed to extract, or that you don't understand** — leave it
  exactly where it is and record why in that day's note. A file moved into
  attachments looks processed. Moving something you failed to read makes it
  invisible.

## 7. Report numbers

Close with counts: records extracted, requirement notes opened, originals moved,
files skipped. Then the part with actual value — **what was in there that the user
didn't know about**. That's the return on the ingest.
