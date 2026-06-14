# claude-skills-toolkit

A personal [Claude Code](https://code.claude.com) plugin marketplace — a portable way to reuse my skills across machines and Claude surfaces.

## Install

On any machine with Claude Code:

```
/plugin marketplace add kwangsing3/claude-skills-toolkit
/plugin install git-tools@claude-skills-toolkit
```

Update later with `/plugin marketplace update claude-skills-toolkit`.

## Plugins

### `git-tools`

| Skill | What it does |
|-------|--------------|
| `commit-push-sync` | When committing **and** pushing, performs the git work, then — if the `gh` CLI is available and authenticated — reviews the GitHub repo's description and topics and updates them (with confirmation) so metadata stays in sync. |

## Structure

```
.claude-plugin/marketplace.json     # marketplace catalog
plugins/
  git-tools/
    .claude-plugin/plugin.json      # plugin manifest
    skills/
      commit-push-sync/SKILL.md     # the skill
```

To add more skills, drop another `skills/<name>/SKILL.md` into a plugin (or add a new plugin entry to `marketplace.json`) and bump the plugin `version`.

## License

MIT
