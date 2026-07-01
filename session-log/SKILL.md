---
name: session-log
description: Records the decisions, tradeoffs, and rationale from the current session into a per-branch markdown log under docs/. Derives the filename from the git branch (slashes become hyphens) so one branch maps to one file, and appends a new timestamped section on every run — multiple sessions on the same branch accumulate in the same file. Use when the user invokes /session-log, or asks to document, log, or record the decisions, tradeoffs, or rationale made during a session.
---

# session-log

Capture the meaningful decisions from the current session into `docs/<branch>.md`, where slashes
in the branch name become hyphens (`feat/staticbase-skill` → `docs/feat-staticbase-skill.md`).
Each run appends a timestamped `## Session` block, so several sessions on one branch build up a
single running log.

## Workflow

1. **Review the session** — scan the conversation for genuine decisions, tradeoffs, and their
   rationale: choices where an alternative existed, non-obvious approaches, or things that would
   confuse a future reader if left unexplained. Skip routine edits and mechanical steps.

2. **Draft the entries** — write one block per decision using the [Entry format](#entry-format)
   below. Base every block on what actually happened in the session; never invent decisions or
   alternatives that weren't really considered.

3. **Append** — write the drafted markdown to a temp file, then run the helper (it resolves the
   branch, derives the path, creates the file with an H1 title if missing, and appends under a
   timestamped heading):
   ```bash
   bash <skill-dir>/scripts/append-session.sh /path/to/draft.md
   ```
   Use the session scratchpad directory for the temp file. The script prints the final path.

4. **Confirm** — tell the user the file path the script reported and give a one-line summary of
   what was logged.

## Entry format

One block per decision:

```md
### Decision: <short title>
- **Chose:** <what was decided>
- **Alternatives:** <options considered, or "none" if it was the only viable path>
- **Tradeoff:** <what this costs / what is given up>
- **Why:** <the reasoning that settled it>
```

## Notes

- **One file per branch** — the filename is derived from the current branch every run; the user
  does not name it. Different branches get different files.
- **Append, never overwrite** — the script only ever adds a new section; prior sessions stay
  intact. Do not edit or rewrite earlier session blocks unless the user asks.
- **Nothing worth logging?** If the session made no real decisions, say so and don't append an
  empty entry.
- **Not on a branch / not a git repo** — the script exits with an error for detached HEAD or a
  non-git directory; relay that to the user instead of forcing a file.
