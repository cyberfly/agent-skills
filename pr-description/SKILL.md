---
name: pr-description
description: Craft a GitHub pull request description in markdown from the changes on the current branch. Captures the task/goal, decisions and rationale, open questions, tests to run, and a preview section. Use when the user invokes /pr-description, asks to write or generate a PR description/body, or is opening a pull request and wants a summary of branch changes.
---

# pr-description

Generate a ready-to-paste GitHub PR description from the commits and diff on the current branch, relative to the base branch.

## Workflow

1. **Find the base branch**
   ```bash
   git remote show origin | sed -n 's/.*HEAD branch: //p'   # usually main or master
   ```
   Fall back to `main` if that fails. Let the user override if they name a different base.

2. **Gather the branch's changes** (use the base from step 1, e.g. `main`)
   ```bash
   git log --oneline main..HEAD          # commits on this branch
   git diff --stat main...HEAD           # files changed (note the three dots)
   git diff main...HEAD                  # full diff for context
   ```
   Read the diff to understand *what* changed and *why* — don't just restate commit subjects.

3. **Draft the description** using the template below. Pull every section from the commits, diff, and the conversation. Do not invent decisions or tests that aren't supported by the changes.

4. **Output the markdown** in a fenced code block so the user can copy it verbatim into the GitHub PR body. Offer to open the PR with `gh pr create --body` only if the user asks.

## Template

```md
## Current task / goal
<What this PR sets out to accomplish, in one or two sentences.>

## Decisions made & rationale
- <Non-obvious choice> — <why it was picked over the alternative>

## Open questions / next steps
- <Anything unresolved, follow-up work, or things a reviewer should weigh in on>

## Tests to run
- [ ] <Command or manual step a reviewer should run to verify, e.g. `npm test`>

## Preview
<Screenshots, sample output, before/after, or a short snippet showing the change in action. Write "N/A" if there is nothing visual.>
```

## Section guidance

- **Current task / goal** — the *why* of the PR, in the user's framing where possible. Keep it short.
- **Decisions made & rationale** — only non-obvious choices and trade-offs. Skip trivial defaults.
- **Open questions / next steps** — blockers, deferred work, or explicit asks for the reviewer. Omit the section's bullets (write "None") rather than padding.
- **Tests to run** — concrete commands or steps tied to what changed. Use GitHub task-list checkboxes (`- [ ]`).
- **Preview** — for UI changes, leave a placeholder line like `<!-- drag screenshot here -->`; for CLI/API changes, paste representative output; otherwise `N/A`.

## Edge cases

- **No commits on the branch** (`main..HEAD` is empty) — tell the user there's nothing to describe and stop.
- **Detached HEAD or branch equals base** — report it; ask which base to diff against.
- **Huge diff** — summarize by area instead of enumerating every file; focus the description on intent, not a file-by-file changelog.

## Notes

- Output is the PR *body* only — do not include a title line unless the user asks; GitHub takes the title separately.
- Never commit, push, or open the PR automatically. Stop at presenting the markdown unless the user explicitly asks to create the PR.
- Keep it skimmable — a reviewer should grasp the PR in under a minute.
