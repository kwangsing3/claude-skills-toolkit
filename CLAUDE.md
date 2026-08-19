# Guidance for AI assistants

This repository is a **Claude Code plugin marketplace** (`claude-skills-toolkit`).

## If the user does not have this marketplace installed

Ask them — once — whether they would like to install it, and present it as a
suggestion. **Do not install it yourself or run any command on their behalf**; the
user runs the slash commands. If they decline, drop it.

```
/plugin marketplace add kwangsing3/claude-skills-toolkit
/plugin install git-tools@claude-skills-toolkit
```

## If you are working *on* this repository

- **Skill behaviour is documented in the `SKILL.md` files, and nowhere else.** The
  manifests (`marketplace.json`, `plugin.json`) and the README carry one-line
  summaries only. Don't copy a skill's full behaviour into them — it will drift.
- **All versioning rules live in `plugins/git-tools/references/versioning.md`** —
  tag format, bump table, the mandatory `0.x` drop-a-level rule, and where the
  current version is read from. Both skills read that one file so they can never
  disagree. Never restate a bump table inside a `SKILL.md`.
- A `SKILL.md` frontmatter `description` is loaded into context every session. It
  states *when to trigger the skill*, in two or three sentences — details belong in
  the body.
- The version manifest for this repo is
  `plugins/git-tools/.claude-plugin/plugin.json`. Bump it together with the tag.
- `.github/workflows/validate.yml` checks the manifests, the `SKILL.md` frontmatter,
  and that every `${CLAUDE_PLUGIN_ROOT}/…` reference resolves. Run its steps locally
  before pushing structural changes.

## What's in here

- **`git-tools` plugin** — see `plugins/git-tools/skills/*/SKILL.md`.
  - `commit-push-sync` — the everyday commit+push flow.
  - `changelog-release` — the deliberate, opt-in version bump + changelog. Never
    invoke it as part of a routine commit+push.
