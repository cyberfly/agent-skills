# agent-skills

Reusable skills and tools for AI agents across different platforms.

## Skills

| Skill | Description |
|-------|-------------|
| [git-staged](./git-staged/SKILL.md) | Manage complex git staging scenarios — commit specific files without disturbing already-staged files |
| [staged](./staged/SKILL.md) | Stage only files the agent modified this session, leaving manual user edits untouched |
| [list-staged](./list-staged/SKILL.md) | Print a list of currently staged files with relative paths |
| [commit-message](./commit-message/SKILL.md) | Generate a conventional commit message from staged changes using prefixes like feat, fix, chore, docs, refactor |
| [stash-staged](./stash-staged/SKILL.md) | Stash only staged changes (leaving unstaged work untouched) and recover them later |
| [checkpoint](./checkpoint/SKILL.md) | Save important conversation context to a timestamped handoff file so it can be loaded into a new session |
| [load-checkpoint](./load-checkpoint/SKILL.md) | Load a saved checkpoint to restore context from a previous session |
| [pr-description](./pr-description/SKILL.md) | Craft a GitHub PR description (markdown) from the current branch's changes |
| [staticbase](./staticbase/SKILL.md) | Scaffold a new static website project using the staticbase stack (Vite 7, Tailwind CSS 4, Alpine.js 3, markdown blog) |
| [session-log](./session-log/SKILL.md) | Record a session's decisions, tradeoffs, and rationale into a per-branch markdown log under `docs/`, appending a timestamped section each run |
| [playwright-save-test](./playwright-save-test/SKILL.md) | Convert a successful Playwright MCP browser session into a standalone `@playwright/test` spec that replays the flow without AI |

## Structure

Each skill is defined in a `SKILL.md` file containing the name, description, and instructions for the agent.

## Usage

After cloning, run the sync script to symlink all skills into every agent tool directory found on your machine:

```bash
node sync-skills.js
```

This links each skill into `~/.claude/skills`, `~/.codex/skills`, and `~/.agents/skills` — whichever exist. Re-run it whenever you add a new skill.
