---
description: Run the Obsidian vault daily review — ingest drops, process answered questions, scan repos, sync the forge, write the day's note
---

Run the vault daily review using the `vault-daily-review` skill.

Follow that skill's steps in order, finishing each before starting the next. Read the
plugin's `references/safety.md` first — this flow deletes open-question entries and
moves files.

Arguments: $ARGUMENTS

If the arguments name a single step (for example "just the drops" or "only the repo
scan"), run that step alone and say which steps you skipped.

**Never close an issue on the forge**, regardless of what the evidence suggests —
that needs the user's explicit confirmation in conversation.
