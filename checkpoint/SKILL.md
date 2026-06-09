---
name: checkpoint
description: Save important conversation context to a timestamped handoff file in .claude/checkpoints/ so it can be loaded into a new session before context runs out. Captures current task, decisions and rationale, work completed, and open questions. Copies the full handoff to the clipboard via pbcopy. Use when the user invokes /checkpoint, says context is getting full, wants to hand off to a new session, or asks to save/snapshot session state for later.
---

# checkpoint

Snapshot the important state of the current conversation into a timestamped handoff file the user can resurrect in a fresh session.

## Workflow

1. **Create the checkpoints directory** (if missing)
   ```bash
   mkdir -p .claude/checkpoints
   ```

2. **Build the handoff content** with these four sections — pull from the conversation, do not invent:

   - **Current task / goal** — what the user is trying to accomplish, in their words where possible.
   - **Decisions made & rationale** — non-obvious choices and *why* they were picked. Skip trivial defaults.
   - **Work completed so far** — files created/edited (with paths), commands run, state achieved. Concrete, not vague.
   - **Open questions / next steps** — what is pending, blockers, what the next session should pick up first.

3. **Write to a timestamped file**
   Filename format: `.claude/checkpoints/YYYY-MM-DD-HHMM.md` using the current local time. Use the `Write` tool. See [TEMPLATE.md](TEMPLATE.md) for the exact structure.

4. **Copy full content to clipboard**
   ```bash
   pbcopy < .claude/checkpoints/YYYY-MM-DD-HHMM.md
   ```

5. **Report to the user** — the file path, and confirm the content is on the clipboard so they can paste it into a new session if they prefer that over `/load-checkpoint`.

## Notes

- Write for a future agent with **zero context** — include file paths, branch names, command output snippets, not vague references like "the bug we discussed."
- Do not dump the entire conversation. Curate aggressively. A good checkpoint is dense and skimmable.
- Never include secrets (API keys, tokens, passwords) even if they appeared in the session.
- If `.claude/` is gitignored or doesn't exist yet in the repo, still create the file there — the user can decide whether to commit it.
- Companion skill: `/load-checkpoint` reads the most recent checkpoint back.
