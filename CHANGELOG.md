# Changelog

All notable changes to this project are documented here. Generated from
[Conventional Commits](https://www.conventionalcommits.org/) — see
[`references/versioning.md`](plugins/git-tools/references/versioning.md) for the
bump rules.

## v1.5.1 (2026-08-19)

### 🐞 Fixes

- **commit-push-sync:** the Obsidian step gated on `command -v obsidian`, so it stayed
  dormant for anyone who has a vault but no CLI on `PATH` — the CLI ships with the
  Obsidian desktop app, not with the Obsidian skills. Detection now triggers on any
  sign of a vault (an Obsidian skill being available, the CLI, an MCP server, or a
  `.obsidian/` directory), and access degrades through a ladder: CLI → MCP → reading
  the vault's markdown files directly.

## v1.5.0 (2026-08-19)

### 🚀 Features

- **commit-push-sync:** sync a linked Obsidian vault — detect the `obsidian` CLI and
  any note tying back to the project, inspect the note structure, and update stale
  notes with confirmation. Self-disabling when the CLI is absent; when the CLI is
  present but the project is untracked, it offers once to start tracking it and
  pushes either way.
- **git-tools:** add `/commit-push` and `/release` slash commands as explicit entry
  points for the two skills.
- **ci:** validate JSON manifests, `SKILL.md` frontmatter, semver versions, and
  `${CLAUDE_PLUGIN_ROOT}` references on every push and PR.

### 🐞 Fixes

- **versioning:** the `0.x` drop-a-level rule was *optional* in `commit-push-sync` but
  *mandatory* in `changelog-release`, so the same commit range could yield two
  different versions depending on which skill ran. Both now resolve versions through a
  single `references/versioning.md`.

### 📖 Documentation

- Collapse the skill descriptions that were duplicated verbatim across
  `marketplace.json`, `plugin.json`, `CLAUDE.md`, the README, and the skill
  frontmatter down to one-line summaries pointing at the `SKILL.md` files.
- Trim the always-in-context `SKILL.md` frontmatter descriptions and the `CLAUDE.md`
  AI-guidance block.
- Add the `LICENSE` file the README already claimed, plus `license`, `homepage`,
  `repository`, and `keywords` in the plugin manifest.
- Document that this repo's version manifest is
  `plugins/git-tools/.claude-plugin/plugin.json`.

## v1.4.1 (2026-06-17)

### 🐞 Fixes

- **git-tools:** use standard semver for the opt-in tag version (bdfa15a)

## v1.4.0 (2026-06-17)

### 🚀 Features

- **git-tools:** add opt-in tag + GitHub Release to `commit-push-sync` (298ec34)

## v1.3.0 (2026-06-15)

### 🚀 Features

- **git-tools:** adopt the changelogen workflow — Conventional Commits + opt-in
  release skill (c8b2744)
- sync local docs on commit+push; make the GitHub metadata step GitHub-only (9084b7b)

### 📖 Documentation

- state that the repo is intentionally designed to guide AI to ask (7ad00e1)
- add the AI-assistant guidance prompt (ask, never auto-install) (4aa13db)

### 🏡 Chore

- drop the repo-level SessionStart hook in favor of a global one (dfbf7e9)

## Earlier

- feat: SessionStart hook suggests installing the plugin to the author (10e51ce)
- feat: initial marketplace with `git-tools/commit-push-sync` skill (33681aa)
