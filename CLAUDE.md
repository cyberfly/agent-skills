# CLAUDE.md

## Purpose

This repository is the **skills development folder** — the single source of truth for
authoring agent skills. Each skill lives in its own directory with a `SKILL.md` (plus
any supporting files like `TEMPLATE.md`).

Develop and edit skills **here**, never directly in the synced target directories.

## Syncing to agent skill folders

`sync-skills.js` symlinks every skill directory in this repo into each agent tool's
skills folder that exists on the machine:

- `~/.claude/skills`
- `~/.codex/skills`
- `~/.agents/skills`

Run it after adding or renaming a skill:

```bash
node sync-skills.js
```

Because it creates **symlinks**, edits made here take effect immediately in every
synced location — no re-run needed for content changes, only for new/removed skills.

### Caveat: pre-existing real directories

`sync-skills.js` will **not** overwrite a non-symlink entry already present in a target
(it reports `skipped (non-symlink entry exists)`). If a skill was originally created
directly inside `~/.claude/skills` (etc.), remove that real directory first, then re-run
the sync so the symlink can take over. Copy its contents into this repo before deleting.

## Adding a new skill

1. Create `./<skill-name>/SKILL.md` (with YAML frontmatter: `name`, `description`).
2. Add bundled resources alongside it if needed (templates, scripts).
3. Add a row to the table in `README.md`.
4. Run `node sync-skills.js`.
