---
name: commit-push-sync
description: Use when the user asks to commit AND push to a git repository (not for commit-only requests). Writes changelog-ready Conventional Commits, syncs local docs and any linked Obsidian vault notes into the same commit, optionally tags the push when explicitly asked, and on GitHub repos syncs repo metadata and cuts a Release for that tag.
---

# Commit, push, and sync docs, notes, and repo metadata

Run when the user asks to **commit and push**. The flow is: refresh what the change
made stale (local docs, then linked Obsidian notes), do the git work with a clean
Conventional Commit, optionally tag, then — GitHub only — sync public metadata and
cut a Release.

Keep it lightweight. This is a push, not a repo audit.

## 1. Sync local docs before committing

Local docs live in the repo, so this applies to every remote (GitHub, GitLab, a
private server, or no remote at all).

- **`README.md`** — does the change add/rename a feature, command, or setup step?
- **`CLAUDE.md`** / **`AGENTS.md`** — do the changes affect guidance an AI relies on
  (structure, conventions, workflows)?

Update only what is genuinely out of date, and **stage it alongside the code** so it
lands in the same commit. Don't create docs the repo doesn't already have.

## 2. Sync an Obsidian vault (only if the user has one)

Some projects keep their real documentation in an Obsidian vault rather than in the
repo. Two separate questions, in order: **is Obsidian in play at all**, and **can you
reach the notes**.

### 2a. Is Obsidian in play?

Any one of these is enough — check cheaply, and only once:

- an **Obsidian skill is available** to you (e.g. `obsidian-cli`, `obsidian-markdown`
  from `kepano/obsidian-skills`) — its presence means the user works with a vault,
  even if the CLI itself is not installed;
- the **`obsidian` CLI** is on `PATH` (`command -v obsidian`);
- an **Obsidian MCP server** is connected;
- a **vault on disk** — a `.obsidian/` directory inside or beside the repo, or a vault
  path configured in `CLAUDE.md` / `.env` / project config.

**If none of these hold, do nothing and move on.** This is the common case and is not
a failure. Never install the CLI, start Obsidian, or create a vault.

### 2b. Reach the notes with whatever access you have

Do **not** gate on the CLI. Take the highest rung of this ladder that works:

1. **`obsidian` CLI** — preferred; it talks to the running app and respects its index.
   ```bash
   obsidian search query="<repo name>" limit=10   # which notes cover this project
   obsidian read file="<Note>"                    # read before editing
   obsidian backlinks file="<Note>"               # how it fits the vault's structure
   ```
2. **An Obsidian MCP server**, if one is connected — use its read/search tools.
3. **The filesystem** — a vault is just a folder of markdown, so when you know the
   vault path but the CLI is unavailable (Obsidian not installed, or not running),
   read and write the `.md` files directly with your normal file tools. Grep for the
   repo name to find the relevant notes. Obsidian picks up external edits on its own.

If an Obsidian skill is available, **follow it** for syntax — wikilinks, embeds,
callouts, properties. It is the authority on Obsidian Flavored Markdown; don't
improvise a format this skill doesn't specify.

If you can detect a vault but genuinely cannot reach it by any rung (no CLI, no MCP,
no known path), say so in one line and continue with the push. Don't guess at paths.

### 2c. Nothing tracks this project yet

Ask — once, in passing — whether the user wants to start tracking this project in
their vault. Keep it to one line alongside your other output; it is an offer, not a
blocker.

- If they say yes, ask where it belongs (which vault, which folder) and create a
  single note following the conventions of its neighbours, then continue.
- If they say no, or don't answer, **carry on with the commit and push regardless** —
  never hold up the git work waiting on this, and don't ask again in the same session.

### 2d. Update what went stale

Judge whether the change you are committing makes the notes stale — a renamed command,
a new feature, a changed setup step, a decision that supersedes what the note records.
Follow the vault's existing conventions (folder placement, properties, wikilinks,
tags); mirror what neighbouring notes do rather than inventing a format.

Notes are the user's own knowledge base, so **propose the edit and get confirmation
before writing**. Then apply it — via the CLI when you have it:

```bash
obsidian append file="<Note>" content="..." silent
obsidian property:set name="updated" value="<YYYY-MM-DD>" file="<Note>"
```

— or by editing the note file directly when you don't.

Prefer appending to or editing an existing note over creating a new one, and only
create one when the user asks. Vault edits are **not** part of the commit — mention
them separately when you report. If both a repo doc and a vault note cover the same
thing, update the repo doc and leave the note pointing at it rather than duplicating.

## 3. Commit and push — write changelog-ready commits

Borrowed from `changelogen`'s philosophy: **the commit history is the source of
truth**. Every everyday commit should be written well enough that a changelog could
later be generated from git history alone. You are not generating a changelog here —
just making the messages clean enough that any tool could.

Stage the intended changes (plus doc updates from step 1) and write the message in
**Conventional Commits** form:

- Header: `type(scope): subject`
  - **type** (required): `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `build`,
    `ci`, `chore`, `style`.
  - **scope** (optional): a short lowercase area — `feat(auth): …`.
  - **subject**: imperative mood, concise, no trailing period.
- **Breaking changes**: mark with `!` after the type/scope (`feat!:`) and/or add a
  `BREAKING CHANGE:` footer explaining the break.
- If the staged changes cover **multiple unrelated concerns**, split them into
  separate well-typed commits — mixed commits are what make changelogs messy later.
- End with the co-author trailer if your environment requires one, and respect the
  user's branching norms (branch first if on the default branch and that's the norm).

**Stay release-aware (informational only — do NOT act):** note in one line the semver
impact the commit implies, per `${CLAUDE_PLUGIN_ROOT}/references/versioning.md`, so
the user knows where history is heading. Do **not** bump the version or write a
`CHANGELOG.md` — those belong to `changelog-release`.

Then push.

## 4. Optional: attach a tag (opt-in only)

Tagging is **off by default** — a routine commit+push never creates a tag. Only
attach one when the user **explicitly asks** ("tag this push", "commit and push with
a tag").

Read `${CLAUDE_PLUGIN_ROOT}/references/versioning.md` and compute the next version
from it — that file is the single source of truth for the tag format, the bump table,
and the mandatory `0.x` rule. Propose the version, get confirmation, then create an
**annotated** tag on the commit you just made and push it with the branch:

```bash
git tag -a v1.5.0 -m "v1.5.0"
git push --follow-tags        # pushes the branch and any annotated tags it reaches
```

Remember that a tag was pushed — it is the trigger for the Release step below.

This skill creates only the git tag (and the GitHub Release). It does not touch
`package.json` or `CHANGELOG.md`; route the user to `changelog-release` for that.

## 5. Is this a GitHub repo with a usable `gh`?

Everything below is **GitHub-only**. Many projects are not on GitHub — then there is
simply nothing to do: report the push (and the tag, if any) and stop. That is the
normal outcome, not a failure; the tag still reached the remote either way.

```bash
git remote -v           # is there a GitHub remote at all?
gh --version            # is gh installed?
gh auth status          # is it authenticated?
```

If the remote isn't GitHub, or `gh` is missing/unauthenticated, stop here. Do not
install or authenticate `gh` yourself.

## 6. Create a GitHub Release (only if this push carried a tag)

Only when **both** are true: the push attached a tag, and this is GitHub with a
usable `gh`. A push without a tag never creates a release — skip to step 7.

A Release is outward-facing, so confirm the tag name, title, and prerelease status
first. Check `gh release view <tag>` — if a release already exists, report it rather
than duplicating.

```bash
gh release create v1.5.0 --title "v1.5.0" --generate-notes
# or supply notes distilled from the Conventional Commits in range:
#   --notes "..."
# add --prerelease for -rc/-beta tags, or --draft to stage without publishing
```

Report the release URL (`gh release view v1.5.0 --json url`).

## 7. Review description and topics

```bash
gh repo view --json name,description,repositoryTopics,homepageUrl
```

Compare against what the project now actually is (README, manifest, what you just
pushed):

- **Description** — accurate, typo-free, reflects new major features? Propose a
  replacement only if it is genuinely stale or wrong.
- **Topics** — are key technologies/domains represented? Suggest additions; avoid
  churn by removing existing ones.

If everything is accurate, say so and change nothing.

## 8. Apply metadata changes (with confirmation)

Description and topics are outward-facing. Confirm wording first (offer concrete
options rather than picking silently). Topic *additions* are low-risk — you may apply
and report — but never remove a topic without asking.

```bash
gh repo edit <owner>/<repo> --description "..." --add-topic <topic>
# --remove-topic <topic>   # only when clearly justified and confirmed
```

Verify and report the final description + topic list.

## Notes

- This skill keeps docs, notes, and metadata fresh *opportunistically* during a push.
  It is never a reason to push — don't push solely to trigger a sync.
- Every version decision routes through `references/versioning.md`. If you find
  yourself reciting a bump table from memory, read the file instead.
