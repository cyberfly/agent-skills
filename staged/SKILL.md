---
name: staged
description: Stage only the files the agent modified in this session, then suggest a commit message (without committing). Use when the user invokes /staged or wants to git add only the agent's recent changes while leaving any manual edits unstaged.
model: haiku
---

# staged

Stage only the files you (the agent) modified this session — not everything in the working tree.

## Workflow

1. **Identify files touched this session**
   Look back through your tool call history for all `Edit`, `Write`, and `NotebookEdit` calls. Collect the unique set of file paths you actually modified or created.

2. **Cross-check against git status**
   ```bash
   git status --short
   ```
   Only stage paths that appear in both your session history and the git working tree diff. Skip files you touched that are already clean (e.g. reverted).

3. **Stage only those files**
   ```bash
   git add <file1> <file2> ...
   ```

4. **Confirm what is now staged**
   ```bash
   git diff --cached --stat
   ```

5. **Generate a commit message**
   Inspect the staged diff and write a Conventional Commits message directly — do **not** invoke the `commit-message` skill (saves tokens).
   ```bash
   git diff --cached          # full diff for context
   ```
   Format: `<type>(<scope>): <subject>` with an optional body after a blank line.
   - **type**: `feat` (new capability), `fix` (bug), `chore` (deps/config/tooling), `docs`, `refactor` (no behavior change), `test`, `style` (formatting), `perf`, `build`, `ci`, `revert`.
   - **scope** (optional): short noun for the area changed (`auth`, `api`, `ui`, `db`). Omit when changes span many areas.
   - **subject**: imperative mood ("add" not "added"), lowercase first letter, no trailing period, first line ≤ 72 chars.
   - **body** (optional): add only when the *why* isn't obvious from the subject.

   Present the message to the user — do not commit automatically unless they ask.

Report the list of staged files alongside the suggested commit message.

## Edge cases

- **You modified nothing this session** — report that and stop.
- **A file you edited has no diff** (change was reverted) — skip it.
- **User says "not all of them"** — list your session files and ask which ones to include before staging.
- **Untracked files you created** — include them; call them out so the user can `.gitignore` any that are sensitive.

## Notes

- Never commit — this skill stops at staging.
- Never use `git add -A` or `git add .` — that would include manual user changes outside this session.
