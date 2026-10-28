---
name: vault-project-note
description: Use when the user wants an Obsidian note created or refreshed for a code repository — "add this repo to my vault", "make a project note for X", "my project notes are out of date". Reads the repo's git metadata and manifests, then writes a project note that follows the vault's own conventions, plus its standard mind-map canvases. Also use to refresh an existing note's git frontmatter after new commits.
---

# Turn a repo into a standard project note

The point of a project note is that **it is findable again**. Months later the user
remembers a customer name, not a folder name — so the note has to carry enough
metadata to lead back to the source code, and enough plain-language context to be
readable when they're not already thinking about the code.

Read `${CLAUDE_PLUGIN_ROOT}/references/vault-conventions.md` first, then
`${CLAUDE_PLUGIN_ROOT}/references/safety.md`. The vault's `CLAUDE.md` overrides
anything below.

## 1. Read the repo before writing anything

Collect the git facts by running these in the repo — all read-only:

```bash
git -C <repo> remote get-url origin        # full URL; may be GitHub *or* GitLab
git -C <repo> rev-parse --abbrev-ref HEAD  # NOT necessarily main
git -C <repo> log -1 --format=%ad --date=short          # last commit
git -C <repo> log --reverse -1 --format=%ad --date=short # first commit
```

Use `git -C <repo>`, not `cd <repo> && git …` — changing directory first can execute
hooks from the target repo.

Then derive:

- **host** from the remote URL, and **namespace** (the owner/group path). Namespaces
  are how the user's projects group into families — record the full path, not just
  the last segment.
- **stack** from actual manifests (`package.json`, `requirements.txt`, `*.csproj`,
  `go.mod`, `composer.json`) and from the source layout. Read them; don't infer a
  stack from the repo name.
- **domain / category** per the vault's own classification table.

Three traps, all of which produce a wrong note that looks right:

- **The default branch is often not `main`.** Record what `HEAD` actually points at.
- **Not every documented project has a remote.** If there's no git at all, say so
  explicitly in the note and mark the remote field accordingly, rather than leaving
  a field that implies one exists.
- **The remote can outlive the local clone**, and vice versa. These are two separate
  facts; a missing local folder does not mean the project is gone.

## 2. Read enough to write the purpose section

The metadata is mechanical. The plain-language "why does this exist" section is not,
and it's the half the user reads when they're away from work.

Sources, in order of value: the README, then the actual entry point, then commit
subjects (they narrate the project's arc better than any doc), then issue titles.

If the README is still the forge's default template, **say that in the note** — it's
a real finding about the project, and it belongs in the todo list rather than being
quietly worked around.

## 3. Write the note

Follow the vault's required frontmatter and its fixed section order exactly. Don't
reorder sections to suit the content, and don't drop a section because you have
nothing for it — use a placeholder callout (see `safety.md`).

Two things to get right:

- **Requirements section**: if the vault has a note-per-requirement model, embed its
  query view rather than writing a checkbox list. See `vault-conventions.md` §4.
- **Related section**: lead with the clickable remote URL, then the local path. That
  ordering is deliberate — the remote is the durable one.

## 4. Create the mind maps

Generate the vault's standard canvas set for the project (see
`vault-conventions.md` §5), and embed them from the note in the vault's stated
order.

Populate them from what you actually found. An architecture canvas built from the
real module layout is worth having; one built from generic boxes labelled
"Frontend / Backend / Database" is worse than none, because it looks like
information.

## 5. Proposing improvements

If the vault's note structure includes an AI-suggestions section, every suggestion
must **cite a specific fact from this repo** — a file path, a count, a line that
will throw, a credential you found committed. "Consider improving performance" is
banned; it carries no information and it costs the user attention to read.

Mark the section clearly as unreviewed, and keep it visually distinct from real
requirements. A suggestion only becomes a requirement note after the user adopts it.

## 6. Refreshing an existing note

When the note already exists, this is a **diff**, not a rewrite:

1. Compare the note's recorded last-commit against the repo's actual last commit.
2. No new commits → **change nothing at all.** Not the frontmatter, not a timestamp.
   Say it's current and stop.
3. New commits → update the git frontmatter, add **one summarising line** to the work
   log (what that batch of commits accomplished — not a transcription of each commit
   subject), and update the structure section only if the architecture genuinely
   moved.
4. If commits closed something the requirements track, update those requirement notes
   and the requirements canvas too — but verify against the source code first. A
   commit message claiming a feature is not the feature existing.
