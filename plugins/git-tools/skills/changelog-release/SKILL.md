---
name: changelog-release
description: Use when the user explicitly wants to cut a release, bump the version, or (re)generate CHANGELOG.md from git history — phrases like "release", "bump version", "update changelog", "cut a new version". Determines the semver bump from Conventional Commits since the last tag, updates the version manifest, writes CHANGELOG.md, and (only with confirmation) creates the release commit + tag. Prefers the `changelogen` CLI when available, otherwise does it by hand. This is a deliberate, opt-in release action — never run it as part of a routine commit+push.
---

# Cut a version + generate CHANGELOG.md

This is the **release** counterpart to `commit-push-sync`. Where that skill keeps everyday commit *messages* clean (Conventional Commits, no version/changelog/tag), this skill is the explicit moment you turn that clean history into a **version bump** and a **CHANGELOG.md** entry.

Only run it when the user clearly asks to release / bump / update the changelog. Never trigger it automatically from a routine commit or push — bumping a version and writing a changelog are deliberate, outward-facing acts.

## 1. Establish the range and read the history

- Find the last release tag: `git describe --tags --abbrev=0` (if there is none, the range is the full history / project start).
- List the commits since then: `git log <lastTag>..HEAD --oneline`.
- Parse them as Conventional Commits (`type(scope): subject`, `type!:`, `BREAKING CHANGE:` footers). Commits that don't follow the convention are noted but won't produce clean changelog entries — surface them to the user rather than silently dropping anything significant.

If there are no releasable commits since the last tag, say so and stop — don't cut an empty release.

## 2. Determine the version bump

Derive the bump from the highest-impact commit in range:

| In range | Bump |
|----------|------|
| any `BREAKING CHANGE` / `type!:` | **major** |
| any `feat:` (no breaking) | **minor** |
| only `fix:` / others | **patch** |

**0.x rule (match changelogen):** while the current version is `0.y.z`, drop one level — a breaking change bumps **minor** (`0.3.x` → `0.4.0`), a `feat` bumps **patch**. Above `1.0.0`, use the table as-is.

Read the current version from the project's manifest (`package.json` `version`, or the language-appropriate file). **Propose the computed next version to the user and let them confirm or override** (they may want to force a major, or a pre-release like `-rc.1`).

## 3. Prefer `changelogen`, fall back to manual

Check once whether the tool is available:

```bash
npx changelogen --version   # or: changelogen --version
```

**If available**, drive it instead of reimplementing the logic:
- Changelog only: `npx changelogen`
- Bump version + write changelog: `npx changelogen --bump`
- Full release (bump + commit + tag): `npx changelogen --release` (add `--push` only if the user asks)

Map the user's confirmed intent to the right flag, show what it will do, and run the least-destructive flag that satisfies the request.

**If not available**, do it by hand:
- Update the version field in the manifest.
- Prepend a new section to `CHANGELOG.md` (create it if missing), following Keep a Changelog style:

  ```markdown
  ## v<next> (<YYYY-MM-DD>)

  ### 🚀 Features
  - <subject> (<short-sha>)

  ### 🐞 Fixes
  - <subject> (<short-sha>)

  ### ⚠️ Breaking Changes
  - <subject> — <BREAKING CHANGE description>
  ```

  Group by type, keep the newest version on top, and link/annotate commit shas if the existing file already does.

## 4. Commit and tag — only with confirmation

Version bumps and tags are **outward-facing and hard to undo**. Before doing the destructive part:

- Show the diff (manifest + CHANGELOG.md) and the exact tag name (`v<next>`).
- Get explicit confirmation.

Then:

```bash
git add <manifest> CHANGELOG.md
git commit -m "chore(release): v<next>"
git tag v<next>
```

Push the commit and tag **only if the user asks** (`git push --follow-tags`). Do not publish to a registry or create a GitHub Release unless explicitly requested.

## Notes

- This skill consumes the clean history that `commit-push-sync` produces — the two compose, but stay separate. Keep version/changelog/tag work *out* of the everyday commit flow.
- Be tool-agnostic: if `changelogen` exists, defer to it rather than hand-rolling; only fall back to manual generation when it's absent.
- Never bump or tag silently. The version number and changelog are things humans review.
