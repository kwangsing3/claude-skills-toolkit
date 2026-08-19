---
description: Bump the version and generate CHANGELOG.md from Conventional Commits since the last tag
---

Cut a release using the `changelog-release` skill.

Follow that skill end to end: read the commits since the last tag, compute the semver
bump from the plugin's versioning reference, propose the next version for confirmation,
update the version manifest, and write `CHANGELOG.md`.

Arguments: $ARGUMENTS

If the arguments name an explicit version or a pre-release (e.g. `1.6.0`, `--rc`),
use it instead of the computed bump — but still confirm before committing or tagging.
Do not push unless asked.
