---
description: Create or refresh an Obsidian project note for a repository, following the vault's own conventions
---

Create or refresh the vault's project note for a repository using the
`vault-project-note` skill.

Arguments: $ARGUMENTS

If the arguments name a repo path, use it. Otherwise use the current repository.

If a note for this project already exists, treat this as a **refresh**: compare the
recorded last-commit against the repo, and if there are no new commits, change
nothing and say so.

The repository is read-only — read its git metadata and manifests, never write to it.
