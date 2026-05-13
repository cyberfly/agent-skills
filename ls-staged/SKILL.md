---
name: ls-staged
description: Print the list of currently staged files with their relative paths. Use when the user invokes /ls-staged or asks to see, list, or show staged files before a commit.
---

# ls-staged

Print all files currently in the git index (staged for the next commit).

## Quick start

```bash
git diff --cached --name-only
```

That's it. Output is one relative path per line from the repo root.

## With status labels

To also show what changed (modified, added, deleted, renamed):

```bash
git diff --cached --name-status
```

Example output:
```
M  src/index.ts
A  src/utils/helper.ts
D  src/old-file.ts
R  src/foo.ts -> src/bar.ts
```

## Notes

- If output is empty, nothing is staged — say so explicitly.
- Paths are always relative to the repo root, not the current working directory.
- Do not run `git status` as a substitute — it includes unstaged changes and is harder to parse.
