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

# Recover (restore as staged changes)
git stash pop
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

```bash
# Pop (apply and remove from stash list)
git stash pop

# Apply without removing (keeps it in the list)
git stash apply stash@{0}
```

> `pop` restores as unstaged changes. Re-stage with `git add` if needed.

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
| Recover and keep in list | `git stash apply` |
| Recover and remove from list | `git stash pop` |
| Stash everything (staged + unstaged) | `git stash push` |
