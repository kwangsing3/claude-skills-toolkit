---
name: commit-push-sync
description: Use when committing AND pushing changes to a git repository. Writes changelog-ready commits in Conventional Commits style (type(scope): subject, breaking-change markers, semver-aware) so history alone can drive a changelog later. Before committing, review and (with confirmation) update local docs (CLAUDE.md + README) so they stay in sync with the change. Tagging is optional and opt-in: only when the user explicitly asks to tag this push, propose a `v<version>` tag (the LLM computes the version from what changed — feature removed = major, existing feature breaks = minor, pure fix = patch, otherwise ordinary semver), confirm it, then create and push the tag with the commit. After the push, only if the repo is on GitHub and the `gh` CLI is available and authenticated, also review and (with confirmation) update the GitHub repo's description and topics — and, when the push carried a tag, create a matching GitHub Release. For non-GitHub repos, skip the GitHub steps entirely with no action.
---

# Commit, push, and sync project docs + GitHub repo metadata

Run when the user asks to **commit and push** (not for commit-only requests). The goal is to do the normal git work — writing each commit in changelog-ready Conventional Commits style — keep the project's docs (CLAUDE.md + README) in sync with what you just changed, optionally attach a **tag** when (and only when) the user asks for one, and — only when the repo lives on GitHub — keep its public metadata (description + topics) in sync too, plus cut a **GitHub Release** when the push carried a tag.

## 1. Sync local docs before committing

Local docs live in the repo and have nothing to do with GitHub, so this step always applies — including for repos hosted on GitLab, Bitbucket, a private server, or no remote at all.

Look at the changes being committed and check whether they make the project's docs stale:

- **`README.md`** — does the change add/rename a feature, command, or setup step that the README should mention? Update only what is genuinely out of date.
- **`CLAUDE.md`** (and `AGENTS.md` if present) — do the changes affect guidance an AI assistant relies on (structure, conventions, workflows)? Keep it accurate.

If a doc edit is warranted, make it and **stage it alongside the code** so it lands in the same commit. If the docs are already accurate, change nothing. Don't invent docs that don't already exist — only update files the repo already has.

## 2. Commit and push — write changelog-ready commits

Borrowed from `changelogen`'s philosophy: **the commit history is the source of truth**, so every everyday commit should be written well enough that a changelog or release could later be generated from git history alone, with zero manual curation. You are not generating a changelog here — you are just making sure the commit *messages* are clean enough that any tool could.

Stage the intended changes (plus any doc updates from step 1) and write the message in **Conventional Commits** form:

- Header: `type(scope): subject`
  - **type** (required): `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `build`, `ci`, `chore` (and `style`).
  - **scope** (optional): a short lowercase area, e.g. `feat(auth): …`.
  - **subject**: imperative mood, concise, no trailing period.
- **Breaking changes**: mark with `!` after the type/scope (`feat!:`) and/or add a `BREAKING CHANGE:` footer explaining the break.
- If the staged changes cover **multiple unrelated concerns**, prefer splitting them into separate, well-typed commits rather than one mixed commit — mixed commits are what make changelogs messy later.
- End with the standard co-author trailer if your environment requires one, and respect the user's branching norms (e.g. branch first if on the default branch and that is the convention).

**Stay release-aware (informational only — do NOT act):** after composing the message, note in one line the semver impact the type implies, so the user knows where the history is heading. Do **not** bump the version, write a `CHANGELOG.md`, or create a tag — those stay out of the everyday flow.

| Commit | Implied bump | On `0.x` (drops a level) |
|--------|--------------|--------------------------|
| `BREAKING CHANGE` / `type!:` | major | minor |
| `feat:` | minor | patch |
| `fix:` and others | patch | patch |

Then push.

### Optional: attach a tag (opt-in only)

Tagging is **off by default** — a routine commit+push never creates a tag. Only attach one when the user **explicitly asks** for it (e.g. "commit and push with a tag", "tag this push").

**Tag format is always `v<version>`** (e.g. `v1.4.0`) — a leading `v` followed by the version number, no exceptions.

**Figuring out the version is the LLM's call.** Look at what changed since the last tag (`git describe --tags --abbrev=0` for the current version, then the commits/diff in range) and propose the next version yourself, applying this project's bump rules:

| Change since last tag | Bump |
|-----------------------|------|
| A feature / capability was **removed** | **major** |
| An existing feature **breaks** (behavior changes, nothing removed) | **minor** |
| **Pure fixes**, no functional change | **patch** |
| Anything these rules don't cover (e.g. a **purely additive** new feature) | fall back to ordinary **semver** judgment |

Note these rules are *non-standard* (removal outranks a break here), so reason from the actual change rather than the Conventional Commit type alone. Use your judgment for mixed or ambiguous cases, and pre-releases (`-rc.1`, `-beta`) are fine when the user wants one.

Because a tag (and the Release below) is outward-facing, **propose the computed `v<version>` and confirm it with the user** before creating anything — let them override. Then create an **annotated** tag on the commit you just made and push it with the branch:

```bash
git tag -a v1.4.0 -m "v1.4.0"
git push --follow-tags        # pushes the branch and any annotated tags it reaches
```

Remember that a tag was pushed in this run — it's the trigger for the GitHub Release step below.

## 3. Is this a GitHub repo with a usable `gh`?

Everything below — both the **Release** (when this push carried a tag) and the **metadata sync** — is **GitHub-only**. Many projects are not on GitHub — in that case there is simply **nothing to do here**: report the push result (and the tag, if you pushed one) and stop. This is the normal, expected outcome, not a failure. The tag still lives on the remote either way; only the GitHub Release is skipped.

After the push succeeds, check all of:

```bash
git remote -v           # is there a GitHub remote at all?
gh --version            # is gh installed?
gh auth status          # is it authenticated?
```

If the remote is not GitHub, or `gh` is missing/unauthenticated, **stop here** and just report the push (and any doc updates, and any tag you pushed). Do not install or authenticate `gh` yourself, and don't treat the absence of GitHub as something to apologize for or work around.

## 4. Create a GitHub Release (only if this push carried a tag)

Run this step **only when** both are true: the push attached a tag (from the opt-in step above) **and** the repo is GitHub with a usable `gh`. A push *without* a tag never creates a release — skip straight to step 5.

A Release is **outward-facing**, so confirm before publishing. Draft notes from the commits this tag introduces, then create the release on the existing tag:

```bash
# Default: let GitHub auto-generate notes from the commits/PRs since the previous tag
gh release create v1.4.0 --title "v1.4.0" --generate-notes

# Or supply your own notes (e.g. distilled from the Conventional Commits in range):
# gh release create v1.4.0 --title "v1.4.0" --notes "..."

# Add --prerelease for -rc/-beta tags, or --draft to stage without publishing.
```

Confirm the tag name, title, and whether it's a prerelease with the user first, then create it and report the release URL (`gh release view v1.4.0 --json url`). Don't create a release for a tag that already has one — check with `gh release view <tag>` and report it instead of duplicating.

## 5. Review description and topics

If the repo is on GitHub and `gh` works, fetch the current metadata:

```bash
gh repo view --json name,description,repositoryTopics,homepageUrl
```

Compare it against what the project now actually is (use the README, package manifest, and the changes you just pushed):

- **Description** — is it accurate, free of obvious typos, and does it reflect new major features? Propose an improved one only if it is genuinely stale or wrong.
- **Topics** — are key technologies / domains represented? Suggest additive topics; avoid churn by removing existing ones unless they are clearly wrong.

If everything is already accurate, say so and change nothing.

## 6. Apply changes (with confirmation)

Description and topics are **outward-facing**. When a change is warranted:

- Confirm the wording with the user first (offer concrete options for the description rather than picking silently).
- Topic *additions* are low-risk; you may apply them and report, but still avoid removing topics without asking.

Apply with:

```bash
gh repo edit <owner>/<repo> \
  --description "..." \
  --add-topic <topic>
# remove only when clearly justified and confirmed:
# --remove-topic <topic>
```

Then verify and report the final description + topic list.

## Notes

- This skill is about keeping docs and metadata fresh *opportunistically* during a push — it is not a reason to push. Never push solely to trigger a doc or metadata update.
- Keep it lightweight: a clean Conventional Commit message, a quick doc check, a couple of `gh` calls (only if on GitHub), a short proposal, and an edit. Don't turn it into a full repo audit.
- Tagging here is an opt-in convenience: when asked, the LLM proposes the `v<version>` (per the project bump rules above), confirms it, tags, and — on GitHub — releases. Writing `CHANGELOG.md` and bumping the version *manifest* remain `changelog-release`'s job; this skill just creates the git tag + GitHub Release, it does not touch `package.json`/`CHANGELOG.md`. Route the user there when they want a full changelog/manifest release rather than just a tag.
- The Conventional Commits styling is the main slice of changelog tooling adopted here — it keeps everyday history clean enough that a dedicated tool (e.g. `changelogen`) could later generate a changelog from git history alone.
