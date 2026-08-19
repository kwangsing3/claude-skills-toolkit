# Versioning rules (single source of truth)

Both `commit-push-sync` (opt-in tagging) and `changelog-release` (version bump)
resolve the next version **here**. Do not restate these rules in a SKILL.md —
the two skills must never disagree about what version a given range implies.

## Tag format

Always `v<version>` — a leading `v` followed by the version number, no exceptions.
Examples: `v1.4.0`, `v2.0.0`, `v0.5.0-rc.1`.

## Current version

Read the current version from, in order of preference:

1. The project's version manifest (`package.json` `version`, `pyproject.toml`,
   `Cargo.toml`, or the language-appropriate file).
2. If there is no manifest, the latest tag: `git describe --tags --abbrev=0`.

> For **this** repository the version manifest is
> `plugins/git-tools/.claude-plugin/plugin.json`. The repo carries one tag for
> the whole marketplace; when a second plugin is added, each plugin keeps its own
> `version` field and the repo tag tracks the marketplace as a whole.

## Bump table

Derive the bump from the **highest-impact** Conventional Commit in range
(`git log <lastTag>..HEAD`).

| In range | Bump (>= 1.0.0) | Bump on `0.y.z` |
|----------|-----------------|-----------------|
| any `BREAKING CHANGE:` / `type!:` — breaking change or removed feature | **major** | **minor** |
| any `feat:` (no breaking change) | **minor** | **patch** |
| only `fix:` / `perf:` / others | **patch** | **patch** |

**The `0.x` rule is mandatory, not optional** (it matches `changelogen`): while the
current version is `0.y.z`, every bump drops exactly one level. `0.3.4` + a breaking
change is `0.4.0`, not `1.0.0`. Above `1.0.0` the left column applies as-is.

Pre-releases (`-rc.1`, `-beta.2`) are fine when the user asks for one.

## Always confirm

A version is outward-facing and hard to undo. Compute the next version, **propose
it to the user, and let them confirm or override** before creating any tag, commit,
or release. Never bump silently.
