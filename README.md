# agent-skills

Reusable skills and tools for AI agents across different platforms.

## Skills

| Skill | Description |
|-------|-------------|
| [git-staged](./git-staged/SKILL.md) | Manage complex git staging scenarios — commit specific files without disturbing already-staged files |
| [staged](./staged/SKILL.md) | Stage only files the agent modified this session, leaving manual user edits untouched |
| [list-staged](./list-staged/SKILL.md) | Print a list of currently staged files with relative paths |

## Structure

Each skill is defined in a `SKILL.md` file containing the name, description, and instructions for the agent.

## Usage

After cloning, run the sync script to symlink all skills into every agent tool directory found on your machine:

```bash
node sync-skills.js
```

This links each skill into `~/.claude/skills`, `~/.codex/skills`, and `~/.agents/skills` — whichever exist. Re-run it whenever you add a new skill.
