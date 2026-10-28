---
name: vault-open-questions
description: Use to work a standing open-questions / decision-log file where the user answers inline — "process my open questions", "I answered the questions", "check the decision log" — or when a task raises something you cannot determine and need to park for the user instead of guessing. Classifies each answer as fact, instruction, or non-answer, carries it into the affected notes, and removes only the entries it fully handled.
---

# Work an open-questions list

This skill is a protocol for **not guessing**. It has two halves: parking a question
so it's cheap for the user to answer, and processing the answer so the user never has
to see that question again.

It isn't Obsidian-specific. Any repo or vault with a standing questions file can use
it. Read `${CLAUDE_PLUGIN_ROOT}/references/safety.md` — this skill deletes things.

## Parking a question

When something can't be determined from the material at hand:

1. Note it in the affected note, in a question callout, linking to the central list.
2. Add it to the central list. **Both.** A question only in a project note is a
   question the user will never find.
3. **Number it once and never renumber.** Numbers get quoted in other notes, in
   daily entries, in chat. Renumbering silently breaks every one of those references.

Each entry needs four fields, and the fourth is what makes the system work:

| Field | Purpose |
| --- | --- |
| **Status** | Where the entry stands |
| **Background** | Enough that the user doesn't have to reconstruct the context |
| **Default if unanswered** | **What you will assume in the absence of an answer** |
| **Your answer** | Blank line for the user to type on |

State the default *concretely* — "I'll keep it marked done and note that this was
inferred", not "I'll proceed carefully". The user reads the default to decide whether
answering is worth a minute. A vague default makes every question feel obligatory,
and then none of them get answered.

Ask for the smallest thing that unblocks you. "Is this still in production?" gets
answered; "can you explain the architecture here?" does not.

## Processing answers

**Read the list before starting any other vault work.** Working from stale premises
means redoing it.

Take every entry whose answer line has content. **Entries with no answer are not
touched at all** — no status change, no renumbering, no inferring an answer from
silence.

### Classify the answer, then act

**Statement of fact** — "still running in production", "yes, superseded".

Carry it into the notes: fix the description, add the relation, update the
frontmatter, delete todos the fact invalidates, update the canvas. A fact that
changes a status changes the status.

Also look for what else the fact contradicts. One answer often invalidates a
suggestion or a gap recorded elsewhere; those need updating in the same pass, or the
vault now disagrees with itself.

**Instruction** — "change X to Y", "shut this one down", "open a requirement".

**Do it.** Don't restate the plan and wait.

If you genuinely can't — missing permission, needs an external system, too risky
without confirmation — then: keep the entry, set its status to answered-but-blocked,
and write **specifically what blocked you** in the day's note. "Couldn't do it" is
not a report; "writing to `<path>` was denied, so the plan stands and needs an
explicit grant" is. Being blocked by the user's own safety rule is a legitimate
outcome — surface it rather than routing around it.

**Vague, or venting** — "we'll see", "probably", "still no conclusion".

Don't mine it for a decision. Keep the entry, set its status to
answered-but-needs-confirmation, and add one line naming exactly what you still need.
Treating "probably" as "yes" is the failure mode this whole protocol exists to
prevent — and it's worse than not asking, because now there's a recorded decision
nobody made.

A "keep things as they are" answer *is* an answer: it accepts your stated default.
Apply the default, note that it was accepted rather than derived, and close the entry.

### Then delete the entry

Once handled, **remove the entry entirely.** Not to a resolved section, not struck
through, no stub. The list should only ever contain what still needs attention;
anything else and the user stops reading it.

The record goes in the day's note instead, one line each:

```
- Q<n> "<question, abridged>" → <answer, abridged> → <what you did>, changed: <notes>
```

That line is the audit trail — it's why deleting the entry is safe. Write it before
you delete, not after.

## What to keep out

Don't park a question you can answer by reading the code. Verifying takes a minute;
a question costs the user attention and sits in the list until answered. The list is
for things only the user knows: intent, status, priorities, what happened in a
meeting, whether something is still in use.
