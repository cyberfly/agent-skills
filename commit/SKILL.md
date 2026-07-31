---
name: commit
description: Stage only the files the agent modified in this session and commit them immediately with a generated Conventional Commits message. Use when the user invokes /commit or wants the agent's recent changes committed in one shot, without sweeping in manual or unrelated edits. This is the commit-and-be-done counterpart to /staged (which stops at staging).
model: haiku
---

# commit

Stage the files **you (the agent) modified this session** and commit them right away with a Conventional Commits message. This is `/staged` plus the commit step: same careful, session-scoped staging, but it finishes the job instead of stopping at a suggestion.

The reason for the session-scoped staging is trust. The user may have their own edits in the working tree that they don't want folded into your commit. By committing only what you changed, the user can invoke this freely without auditing the whole index first.

## Workflow

1. **Identify files touched this session**
   Look back through your tool call history for every `Edit`, `Write`, and `NotebookEdit` call. Collect the unique set of file paths you actually modified or created.

2. **Cross-check against git status**
   ```bash
   git status --short
   ```
   Only stage paths that appear in **both** your session history and the working-tree diff. A file you touched but that shows clean was reverted — skip it.

3. **Stage only those files**
   ```bash
   git add <file1> <file2> ...
   ```
   Never `git add -A` or `git add .` — that would pull in the user's manual changes.

4. **Write the commit message from the staged diff**
   ```bash
   git diff --cached          # full diff for context
   ```
   Write the message inline — do **not** invoke the `commit-message` skill (saves tokens). Format:
   ```
   <type>(<scope>): <subject>

   [optional body]
   ```
   - **type**: `feat` (new capability), `fix` (bug), `chore` (deps/config/tooling), `docs`, `refactor` (no behavior change), `test`, `style` (formatting), `perf`, `build`, `ci`, `revert`.
   - **scope** (optional): short noun for the area changed (`auth`, `api`, `ui`, `db`). Omit when the changes span many areas.
   - **subject**: imperative mood ("add" not "added"), lowercase first letter, no trailing period, first line ≤ 72 chars.
   - **body** (optional): add only when the *why* isn't obvious from the subject.

5. **Commit immediately**
   ```bash
   git commit -m "<subject>" [-m "<body>"]
   ```
   The user invoked this skill to commit, so don't pause for confirmation — commit is local and reversible (`git reset --soft HEAD~1` undoes it). Afterward, report the commit hash, the staged file list, and the message you used.

## Edge cases

- **You modified nothing this session** — report that and stop. Don't commit an empty or unrelated change.
- **A file you edited has no diff** (change was reverted) — skip it silently.
- **Untracked files you created** — include them, but call them out in your report so the user can spot anything that shouldn't be tracked (secrets, build artifacts).
- **On the default branch (`main`/`master`)** — commit as asked, but mention it in your report so the user isn't surprised they've committed straight to main.
- **A pre-commit hook rejects the commit** — report the hook output verbatim and stop; don't retry with `--no-verify` unless the user asks.
- **User says "not all of them" / "just X"** — list your session files and commit only the subset they name.

## Notes

- This skill both stages **and** commits. If you only want to stage and stop, use `/staged` instead.
- Only ever stages files you changed this session — the user's parallel edits stay untouched in the working tree.
- Never push. Committing is where this skill ends.
