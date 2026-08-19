---
description: Commit and push with a Conventional Commit, syncing docs, Obsidian notes, and repo metadata
---

Commit and push the current changes using the `commit-push-sync` skill.

Follow that skill end to end: sync local docs, check for a linked Obsidian vault,
write a changelog-ready Conventional Commit, and push.

Arguments: $ARGUMENTS

If the arguments mention tagging (e.g. "tag", "with a tag", or an explicit version),
treat that as the explicit opt-in for the tagging step and propose a `v<version>` per
the plugin's versioning reference. Otherwise **do not tag** — a routine commit+push
never creates a tag.
