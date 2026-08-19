---
name: changelog-release
description: Use when the user explicitly asks to cut a release, bump the version, or (re)generate CHANGELOG.md from git history. Computes the semver bump from Conventional Commits since the last tag, updates the version manifest, writes CHANGELOG.md, and creates the release commit + tag only with confirmation. Deliberate and opt-in — never run it as part of a routine commit+push.
---

# Cut a version + generate CHANGELOG.md

This is the **release** counterpart to `commit-push-sync`. Where that skill keeps
everyday commit *messages* clean, this skill is the explicit moment you turn that
clean history into a **version bump** and a **CHANGELOG.md** entry.

Only run it when the user clearly asks to release / bump / update the changelog.
Never trigger it from a routine commit or push.

## 1. Establish the range and read the history

- Last release tag: `git describe --tags --abbrev=0` (no tag → the full history).
- Commits since then: `git log <lastTag>..HEAD --oneline`.
- Parse them as Conventional Commits (`type(scope): subject`, `type!:`,
  `BREAKING CHANGE:` footers). Commits that don't follow the convention won't
  produce clean entries — surface them to the user rather than silently dropping
  anything significant.

If there are no releasable commits since the last tag, say so and stop — don't cut
an empty release.

## 2. Determine the version bump

Read `${CLAUDE_PLUGIN_ROOT}/references/versioning.md` and apply it. That file is the
single source of truth for the tag format, the bump table, the mandatory `0.x`
drop-a-level rule, and where to read the current version from. Do not restate or
re-derive those rules here — `commit-push-sync` reads the same file, and the two must
never disagree about what version a given range implies.

Propose the computed next version and let the user confirm or override (they may want
to force a major, or a pre-release like `-rc.1`).

## 3. Prefer `changelogen`, fall back to manual

Check once whether the tool is available:

```bash
npx changelogen --version   # or: changelogen --version
```

**If available**, drive it instead of reimplementing the logic:

- Changelog only: `npx changelogen`
- Bump version + write changelog: `npx changelogen --bump`
- Full release (bump + commit + tag): `npx changelogen --release` (add `--push` only
  if the user asks)

Map the user's confirmed intent to the right flag, show what it will do, and run the
least-destructive flag that satisfies the request.

**If not available**, do it by hand:

- Update the version field in the manifest.
- Prepend a new section to `CHANGELOG.md` (create it if missing), Keep a Changelog
  style:

  ```markdown
  ## v<next> (<YYYY-MM-DD>)

  ### 🚀 Features
  - <subject> (<short-sha>)

  ### 🐞 Fixes
  - <subject> (<short-sha>)

  ### ⚠️ Breaking Changes
  - <subject> — <BREAKING CHANGE description>
  ```

  Group by type, keep the newest version on top, and link/annotate commit shas if the
  existing file already does.

## 4. Commit and tag — only with confirmation

Version bumps and tags are outward-facing and hard to undo. Before the destructive
part, show the diff (manifest + CHANGELOG.md) and the exact tag name, then get
explicit confirmation.

```bash
git add <manifest> CHANGELOG.md
git commit -m "chore(release): v<next>"
git tag v<next>
```

Push the commit and tag **only if the user asks** (`git push --follow-tags`). Do not
publish to a registry or create a GitHub Release unless explicitly requested.

## Notes

- This skill consumes the clean history that `commit-push-sync` produces — the two
  compose but stay separate. Keep version/changelog work *out* of the everyday flow.
- Be tool-agnostic: defer to `changelogen` when it exists; hand-roll only when absent.
- Never bump or tag silently. The version number and changelog are things humans review.
