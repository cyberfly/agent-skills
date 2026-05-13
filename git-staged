---
name: git-staged
description: Commit specific files without disturbing the existing git index. Use when the user wants to commit only certain files while preserving other already-staged changes, or when managing complex staging scenarios where the index must be carefully maintained across commits.
---

# git-staged

Commit specific files without disturbing already-staged changes in the git index.

## Quick start

```bash
# 1. Save currently staged files
git diff --cached --name-only > /tmp/.git_staged_save

# 2. Clear the index (working tree untouched)
git reset HEAD

# 3. Stage and commit only the target files
git add <target-files>
git commit -m "your message"

# 4. Restore the previously staged files
xargs git add < /tmp/.git_staged_save
```

## Workflows

### Commit specific files, preserve existing index

1. **Record currently staged files**
   ```bash
   git diff --cached --name-only > /tmp/.git_staged_save
   ```

2. **Clear the index**
   ```bash
   git reset HEAD
   ```
   > Working tree is untouched — only the index is cleared.

3. **Stage and commit target files**
   ```bash
   git add <file1> <file2>
   git commit -m "message"
   ```

4. **Restore previously staged files**
   ```bash
   xargs git add < /tmp/.git_staged_save
   ```
   > Files that were just committed will be re-staged with no net change if unmodified.

### Use git stash when hunks are involved

When staged changes include partial hunks (`git add -p`), the file-list approach loses hunk precision. Use stash instead:

1. ```bash
   git stash push --staged -m "save-index"
   ```
2. ```bash
   git add <target-files>
   git commit -m "message"
   ```
3. ```bash
   git stash pop
   ```
   > Resolve conflicts if committed files overlap with stashed changes.

## Scenario guide

| Situation | Approach |
|-----------|----------|
| Staged files have no working-tree changes | Save/restore file list (Quick start) |
| Staged changes include partial hunks | `git stash push --staged` |
| Splitting one large staged change into multiple commits | Repeat stash workflow per commit |

## Notes

- `git reset HEAD` never modifies the working tree — always safe.
- If a previously-staged file has working-tree modifications, re-adding it will stage its current state — verify with `git diff --cached` before the next commit.
- Clean up the temp file when done: `rm /tmp/.git_staged_save`
