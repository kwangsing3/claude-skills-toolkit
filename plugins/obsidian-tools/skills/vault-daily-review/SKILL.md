---
name: vault-daily-review
description: Use when the user asks for their daily or periodic vault review — "run the daily review", "catch up my vault", "sync my notes with my repos" — or when a scheduled job invokes the review. Orchestrates the other obsidian-tools skills in order (ingest drops, process answered questions, scan repos for new commits, sync the forge, verify issue completion, then write the day's note) and stops without inventing changes when nothing moved.
---

# Run the vault daily review

An orchestration, not a new capability: it sequences the other three skills and adds
repo scanning. The value is in the **order** and in the discipline of writing nothing
when nothing happened.

**Read `${CLAUDE_PLUGIN_ROOT}/references/safety.md` before starting.** This skill
deletes list entries and moves files unattended. Then
`${CLAUDE_PLUGIN_ROOT}/references/vault-conventions.md`, then the vault's `CLAUDE.md`.

Do the steps in order and finish each one before starting the next. Later steps
depend on earlier ones: an answered question can change which projects matter, and an
ingested document can create the requirement a commit then closes.

## 1. Ingest the drop zone

Per `vault-drop-ingest`. Nothing there → move on immediately.

## 2. Process answered open questions

Per `vault-open-questions`. **Before the repo scan**, so you're not writing notes
from premises the user has already corrected.

## 3. Scan the documented repos for new commits

For each project note with a local repo path:

```bash
git -C <repo> log --since="<note's recorded last-commit>" --format="%ad %s" --date=short
git -C <repo> rev-parse --abbrev-ref HEAD
```

Use `git -C`, never `cd <repo> && git …`.

Practical notes from running this at scale:

- **Decode git output as UTF-8 explicitly.** On a Windows console the default
  codepage will raise on non-ASCII commit messages and lose the whole repo's log.
- **A recorded path that no longer exists is a finding, not an error.** Report it;
  don't archive the project on your own initiative. The clone may be gone while the
  remote is fine.
- Projects with no new commits: **skip entirely.** Don't touch the frontmatter.

For projects that *did* move: update the git frontmatter, add one summarising line to
the work log, and update the requirements and architecture sections plus their
canvases **only if they genuinely changed**. Delegate the note mechanics to
`vault-project-note` §6.

## 4. Sync the forge (GitLab / GitHub)

The local clones are not the whole picture — the remote is routinely months ahead,
and issues and wikis have no local copy at all.

- **Projects on the forge but not in the vault** → create notes
  (`vault-project-note`). Projects in the vault but deleted from the forge → archive
  them and say why.
- **Open issues** → requirement notes, `source:` set to the issue URL. Closed issues
  → mark the matching requirement done.
- **Merge requests** → summarise into the work log; unmerged ones are todos.
- **Wiki pages** → fold into the structure section, prioritising projects with no
  README.
- **Beware "last activity"**: on GitLab that timestamp moves when an *issue* is
  updated, not only on push. Don't report it as new commits — check the commit list.
  A comment you posted yesterday will make every project you touched look active.
- If the token lacks a scope, record which one **once**. Don't re-ask daily.

## 5. Verify issue completion against the source code

Gather candidate commits per issue (branch names and messages referencing the issue
number, then keyword matches). Then:

**Evidence is not a conclusion.** Two distinct traps:

- A **direct reference** (`#12` in a branch name or commit subject) is strong — except
  in a fork of an upstream project, where the upstream's own PR numbers collide with
  your issue numbers. In a repo with tens of thousands of inherited commits, most
  `#N` matches are somebody else's.
- A **keyword match** is nearly worthless alone. "cve" appearing in a commit does not
  close a CVE issue.

**Before judging any issue complete, open the source and confirm the behaviour
exists.** This step catches the case that matters: an issue whose commits, branch
name, and messages all say "done" while the actual feature — the auto-detection, the
real recipient list, the fallback path — was never written. That case is common
enough to be the default assumption, not the exception.

Then: set the requirement's status, stamp a verified date, and add a verification
section citing commit hash, date, and **code location**. For anything incomplete,
write the **remaining scope** explicitly — that's the part that gets acted on.

Comment the finding back on the issue if the forge integration allows it. Include the
commit hash, the date, the code location, and a note that it was generated
automatically.

> **Never close an issue.** Closing notifies colleagues, and the judgement came from
> reading commits and code — it can be wrong. Closing requires the user's explicit
> in-conversation confirmation, every time. A scheduled run must never be able to do
> it; if the tooling has a close flag, a scheduled run must not pass it.

## 6. Write the day's note

Cover: which questions were processed, which projects moved and what the change was,
requirements opened and closed, and any new question needing the user's input (added
to the questions list in the same pass — a question mentioned only in a daily note is
lost).

**If nothing changed, write one line saying so.** Don't pad it. An unattended job
that produces edits every day to justify itself is worse than one that reports
nothing — the user loses the ability to tell a real change from noise.

Say plainly what you checked and found unchanged. "27 repos scanned, none with new
commits, no frontmatter touched" is a useful report; silence about it is not.
