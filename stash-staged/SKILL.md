---
name: stash-staged
description: Stash only staged changes (leaving unstaged work untouched) and recover them later. Use when user wants to stash staged files, shelve staged changes without affecting unstaged work, or pop/apply a stash of staged changes back.
---

# stash-staged

Stash only staged changes and recover them — unstaged work stays in the working tree.

## Quick start

```bash
# Stash only staged changes
git stash push --staged -m "my staged work"

# Recover and re-stage
git stash pop && git add -u
```

> Requires Git 2.35+. Check with `git --version`.

## Stash staged changes

```bash
git stash push --staged
# or with a label
git stash push --staged -m "feature: auth changes"
```

- Staged changes move into the stash
- Unstaged working-tree changes are left untouched
- Index is cleared after the stash

## Recover the stash

`git stash pop` restores changes as **unstaged** — always re-stage afterward:

```bash
# Pop and re-stage all restored files
git stash pop && git add -u

# Apply without removing (keeps it in the list), then re-stage
git stash apply stash@{0} && git add -u
```

If you used `git add -p` (partial hunks) when originally staging, re-stage manually with `git add -p` instead of `git add -u` to avoid staging more than intended.

## List and inspect stashes

```bash
git stash list                   # show all stashes
git stash show -p stash@{0}      # inspect a specific stash
```

## Drop a stash you no longer need

```bash
git stash drop stash@{0}
```

## Scenario guide

| Situation | Command |
|-----------|---------|
| Stash staged, keep unstaged | `git stash push --staged` |
| Recover and keep in list | `git stash apply stash@{0} && git add -u` |
| Recover and remove from list | `git stash pop && git add -u` |
| Stash everything (staged + unstaged) | `git stash push` |
