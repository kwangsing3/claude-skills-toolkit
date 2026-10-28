# Reading a vault's conventions

**The vault's own `CLAUDE.md` is the source of truth. This file tells you how to read
it — it does not replace it.**

Every skill in `obsidian-tools` starts here. Folder names, filename formats,
frontmatter fields, and note structure are all **per-vault conventions**, not
properties of Obsidian. Hardcoding one vault's layout into a skill means the skill
creates wrong folders in the next vault it runs in.

## 1. Locate and read the vault's `CLAUDE.md`

Look in the vault root. If there isn't one, the vault has no documented conventions —
**ask the user** rather than imposing the defaults below. Offer to write a `CLAUDE.md`
first; that is a better outcome than guessing on every note.

## 2. Extract these six things, in this order

| What | Why you need it |
| --- | --- |
| **Folder map** | Where projects, dailies, meetings, maps, attachments, templates, archive live |
| **Filename format** | Emoji prefixes, kebab-case, separators — path safety usually drives these |
| **Language rules** | Which parts are prose language vs. which must stay ASCII (field names, tags, filenames) |
| **Required frontmatter** | Per note type. Never invent a field that isn't listed |
| **Note structure** | Section order for each note type — usually fixed, and usually load-bearing |
| **Data model for tasks** | See §4. This is the one people get wrong |

Quote the vault's own table back when you apply it, so the user can see you followed
their rules rather than a remembered version of them.

## 3. Titles vs. filenames

A common pattern: **filenames are ASCII for path safety, titles are in the user's
language.** When both exist, a note needs *both* — a `title:` field, an `aliases:`
list, and a heading — because the filename alone is unreadable.

The corollary matters for graph and canvas work: **display the human title, never the
slug.** A mind-map node showing `gss-log-doorman` has failed at being a mind map.

Wikilinks are the opposite case: link to the **bare slug**, never the decorated
filename. Decoration (emoji, prefixes) changes; the slug shouldn't. If a vault puts
emoji in filenames, its `aliases:` list should carry the bare slug so links stay
stable when the emoji changes.

## 4. Checkboxes are not a task system

**The single most important convention to get right.** A markdown checkbox is inert
text — it cannot be queried, filtered, grouped, or rolled up across projects. A vault
that tracks work will have a **note-per-item** model instead:

- one note per requirement / task, in a known subfolder
- a `type:` that marks it as such
- a **link-type property** pointing at its parent project — *that property is the
  edge*, and it is what makes cross-project queries possible
- a `source:` property recording where the item came from
- a status field with a known vocabulary

So when a source document yields action items, **open notes**, don't append
checkboxes. Reserve checkboxes for trivia not worth a note, and for acceptance
criteria *inside* a requirement note.

If the vault has query/table views (Obsidian Bases, Dataview), the project note
should **embed the query** rather than restate the list by hand. A hand-written list
goes stale the moment a requirement changes status.

## 5. Mind maps / canvases

If the vault standardizes on canvases, expect a fixed set per project with fixed
roles (typical split: structure / requirements / relationships). Rules that recur:

- **Centre node as a text node, not a file node.** A file node renders the whole
  note body when zoomed out, hiding the very title you needed.
- **Every node gets a text heading.** Give leaf nodes enough width that titles in
  non-Latin scripts don't get clipped — CJK titles need noticeably more room than
  their character count suggests.
- **Placeholder over empty branch.** A branch with nothing in it gets an explicit
  "not yet linked" callout node.
- Colour has meaning; read the vault's mapping instead of picking colours.

## 6. Open questions, not assumptions

When the vault's conventions or the source material leave something undecidable,
that's an open question. Route it through `vault-open-questions` — do not resolve it
by picking the likelier option and writing it down as fact.

## Boundary: what this plugin does not do

**`obsidian-tools` never syncs notes as a side effect of a git operation.** That is
`git-tools`' `commit-push-sync`, and it already does it. These skills are for
*directly operating on the vault* — the user asks for a note, an ingest, a review.

Two entry points for one job is how the two drift apart. If you're here because a
commit needs its notes updated, you're in the wrong plugin.
