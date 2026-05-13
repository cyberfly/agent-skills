---
name: commit-message
description: Generates a conventional commit message from staged changes using prefixes like feat, fix, chore, docs, refactor, test, style, perf. Use when user asks to write, suggest, or generate a commit message, or when staged changes are ready to commit.
---

# commit-message

Analyze staged changes and produce a commit message following the Conventional Commits format.

## Quick start

```bash
git diff --cached --stat   # overview of what changed
git diff --cached          # full diff for context
```

Then write the message — do not commit automatically unless the user asks.

## Format

```
<type>(<scope>): <subject>

[optional body]
```

## Types

| Prefix | When to use |
|--------|-------------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `chore` | Maintenance, deps, config, tooling (no production code) |
| `docs` | Documentation only |
| `refactor` | Code restructure with no behavior change |
| `test` | Adding or fixing tests |
| `style` | Formatting, whitespace — no logic change |
| `perf` | Performance improvement |
| `build` | Build system or external dependency changes |
| `ci` | CI/CD pipeline changes |
| `revert` | Reverts a previous commit |

## Scope (optional)

Short noun for the area changed: `auth`, `api`, `ui`, `db`, `config`. Omit when changes span many areas.

## Subject rules

- Imperative mood: "add" not "added", "fix" not "fixed"
- Lowercase first letter
- No period at end
- Max 72 characters total for the first line

## Body (optional)

Add a body only when the *why* is non-obvious from the subject. Separate from subject with a blank line.

## Examples

```
feat(auth): add OAuth2 login with Google

fix(api): handle null response from payment gateway

chore: update dependencies to latest versions

refactor(db): extract query builder into separate module

docs: add setup instructions to README

test(utils): add edge case coverage for date parser
```

## Workflow

1. Run `git diff --cached --stat` for a summary
2. Run `git diff --cached` for the full diff
3. Identify the dominant change type
4. Pick a scope if changes are localized to one area
5. Write the subject in imperative mood
6. Add a body only if motivation isn't obvious
7. Present the message to the user — do not commit unless asked
