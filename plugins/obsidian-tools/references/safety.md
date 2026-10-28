# Safety rules for vault operations

**Every skill in `obsidian-tools` reads this file before doing anything that writes,
moves, or deletes.** These are not footnotes — they are the preconditions.

The rules exist because these skills are the destructive ones in this marketplace.
`vault-daily-review` deletes entries from a questions list and moves files between
folders unattended; `vault-drop-ingest` moves the user's original emails and
attachments. Getting one of those wrong loses data the user cannot get back.

## Never delete or overwrite an existing note

To remove something from active use, **move it to the archive folder** (this vault's
convention is `40-archive/`; read the vault's own `CLAUDE.md` to confirm the name).
Moving, not deleting, keeps existing wikilinks resolvable.

The one sanctioned deletion is an **answered entry in the open-questions list** —
and only after its answer has been carried into the affected notes, and only with a
record written into that day's daily note. See `vault-open-questions`.

## Never batch-delete with a wildcard

No `rm -r`, no globbed deletes, no "clean up the folder". Name every path you remove.
A wildcard in a vault means "I do not know what I am deleting".

## Source code is read-only

Repos the vault documents are **read-only**. Read `git log`, manifests, and source to
fill in note metadata; never write into them. If a task seems to require writing to a
repo, stop and ask — the user's authorization has to be explicit and scoped.

## Do not overwrite a file the user is editing

Obsidian vaults are usually on a sync service (OneDrive, iCloud, Obsidian Sync).
Writing to a note that is open in Obsidian produces a conflict copy. Before a large
rewrite, prefer targeted edits over full-file writes, and say which files you touched
so the user can check for conflicts.

## Do not invent facts to fill a template

A section with no information gets an explicit placeholder callout, not a plausible
guess. When a note's structure asks for something you cannot determine from the
repo or the source material, that is an **open question** (see
`vault-open-questions`), not a blank to fill in.

This applies to statuses especially. "This project is probably still running" is not
a status. Leave it as it was and ask.

## No output is a valid outcome

If nothing changed, say nothing changed. `vault-daily-review` writes one line — "no
changes" — rather than manufacturing edits to look productive. Never touch a note's
frontmatter just to have touched something.
