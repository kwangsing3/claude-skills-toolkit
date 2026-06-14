---
name: commit-push-sync
description: Use when committing AND pushing changes to a git repository. After the push, if the `gh` CLI is available and authenticated, also review and (with confirmation) update the GitHub repo's description and topics so they stay in sync with the project.
---

# Commit, push, and sync GitHub repo metadata

Run when the user asks to **commit and push** (not for commit-only requests). The goal is to do the normal git work and then keep the repository's public metadata (description + topics) in sync — but only when `gh` is available.

## 1. Commit and push as usual

- Stage the intended changes, write a clear commit message, and push.
- End commit messages with the standard co-author trailer if your environment requires one.
- Respect the user's branching norms (e.g. branch first if on the default branch and that is the convention).

## 2. Check whether `gh` is usable

After the push succeeds, probe for the GitHub CLI before doing anything metadata-related:

```bash
gh --version            # is gh installed?
gh auth status          # is it authenticated?
```

If either fails, **stop here** — just report the push result. Do not attempt to install or authenticate `gh` yourself; at most mention that metadata sync was skipped because `gh` is unavailable.

Also confirm the repo actually has a GitHub remote (`git remote -v`). Skip metadata sync for non-GitHub remotes.

## 3. Review description and topics

If `gh` works, fetch the current metadata:

```bash
gh repo view --json name,description,repositoryTopics,homepageUrl
```

Compare it against what the project now actually is (use the README, package manifest, and the changes you just pushed):

- **Description** — is it accurate, free of obvious typos, and does it reflect new major features? Propose an improved one only if it is genuinely stale or wrong.
- **Topics** — are key technologies / domains represented? Suggest additive topics; avoid churn by removing existing ones unless they are clearly wrong.

If everything is already accurate, say so and change nothing.

## 4. Apply changes (with confirmation)

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

- This skill is about keeping metadata fresh *opportunistically* during a push — it is not a reason to push. Never push solely to trigger a metadata update.
- Keep it lightweight: a couple of `gh` calls, a short proposal, and an edit. Don't turn it into a full repo audit.
