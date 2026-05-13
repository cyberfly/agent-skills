# agent-skills

Reusable skills and tools for AI agents across different platforms.

## Skills

| Skill | Description |
|-------|-------------|
| [git-staged](./git-staged/SKILL.md) | Manage complex git staging scenarios — commit specific files without disturbing already-staged files |

## Structure

Each skill is defined in a `SKILL.md` file containing the name, description, and instructions for the agent.

## Usage

Skills are loaded by Claude Code from `~/.claude/skills/`. This repository is symlinked there so skills are available across projects.
