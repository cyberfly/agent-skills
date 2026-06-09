---
name: load-checkpoint
description: Load a saved checkpoint from .claude/checkpoints/ to restore important context from a previous session. Defaults to the most recent file; lets the user pick if they want a different one. Use when the user invokes /load-checkpoint, starts a new session referencing previous work, says "resume where we left off", or wants to pick up from a handoff written by /checkpoint.
---

# load-checkpoint

Read a previously-saved checkpoint and ground the new session in that context.

## Workflow

1. **Locate checkpoints**
   ```bash
   ls -1t .claude/checkpoints/*.md 2>/dev/null
   ```
   - If the directory doesn't exist or is empty: tell the user there are no checkpoints and stop.
   - If exactly one file: use it.
   - If multiple files: default to the **most recent** (top of `ls -1t`). Mention the others exist and offer to load a different one if the user wants.

2. **Read the checkpoint**
   Use the `Read` tool on the chosen file. Do not pipe through `cat`.

3. **Acknowledge and summarize**
   In 4–6 lines, restate to the user:
   - What the task was
   - Where the previous session left off (last completed step)
   - What the next step should be, per the checkpoint's "Open questions / next steps"

   Do not parrot the whole file back — the user can read it. Show that you've internalized it.

4. **Verify before acting**
   Checkpoints can go stale. Before doing work based on the checkpoint:
   - Check that referenced files still exist and contain the lines/symbols mentioned.
   - Check `git status` and `git log` to see what changed since the checkpoint was written.
   - If the world has moved on, flag the divergence to the user before proceeding.

5. **Proceed** with the next step from the checkpoint, or wait for the user's direction.

## Notes

- The most recent file is the default — only ask which to load when the user signals they want an older one.
- Never delete or modify checkpoint files automatically. They are the user's record.
- If the checkpoint references decisions or files that no longer exist, treat that as a signal the checkpoint is outdated, not as a reason to recreate them blindly.
- Companion skill: `/checkpoint` writes these files.
