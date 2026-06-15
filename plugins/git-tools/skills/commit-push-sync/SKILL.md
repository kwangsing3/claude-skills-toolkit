---
name: commit-push-sync
description: Use when committing AND pushing changes to a git repository. Before committing, review and (with confirmation) update local docs (CLAUDE.md + README) so they stay in sync with the change. After the push, only if the repo is on GitHub and the `gh` CLI is available and authenticated, also review and (with confirmation) update the GitHub repo's description and topics. For non-GitHub repos, skip the GitHub step entirely with no action.
---

# Commit, push, and sync project docs + GitHub repo metadata

Run when the user asks to **commit and push** (not for commit-only requests). The goal is to do the normal git work, keep the project's docs (CLAUDE.md + README) in sync with what you just changed, and — only when the repo lives on GitHub — keep its public metadata (description + topics) in sync too.

## 1. Sync local docs before committing

Local docs live in the repo and have nothing to do with GitHub, so this step always applies — including for repos hosted on GitLab, Bitbucket, a private server, or no remote at all.

Look at the changes being committed and check whether they make the project's docs stale:

- **`README.md`** — does the change add/rename a feature, command, or setup step that the README should mention? Update only what is genuinely out of date.
- **`CLAUDE.md`** (and `AGENTS.md` if present) — do the changes affect guidance an AI assistant relies on (structure, conventions, workflows)? Keep it accurate.

If a doc edit is warranted, make it and **stage it alongside the code** so it lands in the same commit. If the docs are already accurate, change nothing. Don't invent docs that don't already exist — only update files the repo already has.

## 2. Commit and push as usual

- Stage the intended changes (plus any doc updates from step 1), write a clear commit message, and push.
- End commit messages with the standard co-author trailer if your environment requires one.
- Respect the user's branching norms (e.g. branch first if on the default branch and that is the convention).

## 3. Is this a GitHub repo with a usable `gh`?

The metadata sync below is **GitHub-only**. Many projects are not on GitHub — in that case there is simply **nothing to do here**: report the push result and stop. This is the normal, expected outcome, not a failure.

After the push succeeds, check all of:

```bash
git remote -v           # is there a GitHub remote at all?
gh --version            # is gh installed?
gh auth status          # is it authenticated?
```

If the remote is not GitHub, or `gh` is missing/unauthenticated, **stop here** and just report the push (and any doc updates). Do not install or authenticate `gh` yourself, and don't treat the absence of GitHub as something to apologize for or work around.

## 4. Review description and topics

If the repo is on GitHub and `gh` works, fetch the current metadata:

```bash
gh repo view --json name,description,repositoryTopics,homepageUrl
```

Compare it against what the project now actually is (use the README, package manifest, and the changes you just pushed):

- **Description** — is it accurate, free of obvious typos, and does it reflect new major features? Propose an improved one only if it is genuinely stale or wrong.
- **Topics** — are key technologies / domains represented? Suggest additive topics; avoid churn by removing existing ones unless they are clearly wrong.

If everything is already accurate, say so and change nothing.

## 5. Apply changes (with confirmation)

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
- Keep it lightweight: a quick doc check, a couple of `gh` calls (only if on GitHub), a short proposal, and an edit. Don't turn it into a full repo audit.
