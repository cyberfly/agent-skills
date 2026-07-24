---
name: branch-bug-check
description: Review the current git branch for bugs and regressions before merging. Diffs the branch against its base (main), reads the changed code in context, runs the existing tests/build, and reports findings with file:line references, severity, and a suggested fix — without modifying code. Use this whenever the user wants to check a branch for bugs, catch regressions, sanity-check changes before a PR or merge, or asks "did I break anything?", "review my branch", "any bugs on this branch?", "is this safe to merge?". Reach for this over a generic code review when the concern is specifically whether the branch's changes break existing behavior.
---

# branch-bug-check

Review everything that changed on the current branch and answer one question: **will this break anything?**

A "bug" is code that does the wrong thing on its own. A "regression" is subtler and more important here — code that was working before the branch and stops working because of a change on it. Regressions hide in the blast radius of a change: a renamed field a caller still reads, a default that flipped, a guard clause that was removed, an edge case the old code handled and the new code forgot. Most of your attention should go there, because those are the bugs tests and reviewers miss.

You are reporting, not fixing. Give the user a clear, ranked picture of what's risky so they can decide. Do not edit code unless they ask you to afterward.

## 1. Establish what changed

Figure out the base branch and get the full diff of the branch against it.

```bash
# Base is usually main or master. Confirm which exists and what the branch forked from.
base=$(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null || git merge-base HEAD master)
git diff --stat $base...HEAD          # overview: which files, how much
git diff $base...HEAD                 # the actual changes to review
git log --oneline $base..HEAD         # the commits, for intent
```

If the branch has no commits beyond base, fall back to reviewing uncommitted work (`git diff HEAD`) and say so. If you can't determine a base, ask the user which branch to compare against rather than guessing.

Skim the commit messages first — they tell you what the change was *trying* to do, which is what you'll check it actually did.

## 2. Read the change in context, not in isolation

A diff shows you the lines that changed but not what depends on them. That's where regressions live. For each meaningful change:

- **Read the surrounding code**, not just the diff hunk — open the file and understand the function the change sits in.
- **Trace the blast radius.** If a function signature, return shape, exported constant, or data field changed, grep for its callers and check each one still holds. A change that's correct locally can break three call sites you didn't look at.
- **Compare old vs new behavior** for anything the diff removed or altered. Ask: what did the old line handle that the new one doesn't? Removed null checks, changed defaults, narrowed conditions, and altered error handling are classic regression sources.

Prioritize by reach. A change to a shared utility, a public API, auth, data writes, or money/quantity math deserves far more scrutiny than a tweak to a log message or a comment.

## 3. Run the tests and build

Static reading catches a lot, but running the code catches what reading misses. Detect the project's test/build setup and run it — this is what separates this skill from a paper review.

- Look for the runner: `package.json` scripts (`test`, `build`, `lint`, `typecheck`), `Makefile`, `pytest`/`tox.ini`, `cargo test`, `go test ./...`, etc.
- Run the test suite. If it's fast, run all of it; if it's huge, at least run the tests covering the changed files/modules.
- Run typecheck/build and lint if they exist — a type error or broken build is the most concrete regression there is.
- Capture real output. If something fails, tie the failure back to a specific change on the branch. If tests fail for reasons unrelated to the branch (pre-existing, flaky, missing env), say so plainly rather than blaming the branch.

If there's no test or build setup, don't invent one — note that verification was static-only, which lowers confidence, and lean harder on tracing the blast radius.

## 4. Report

Lead with the verdict so the user knows the answer before the detail. Rank findings by severity — a data-loss bug and a cosmetic nit should not look alike. For each finding, the user needs to know *where* it is, *what breaks*, and *how to fix it*, so include all three. Concrete failure scenarios ("if `items` is empty, line 42 divides by zero") are far more useful than vague warnings ("possible edge case").

Use this structure:

```markdown
## Branch bug check: <branch> vs <base>

**Verdict:** <Safe to merge | Issues found — N high, M low | Blocked: tests failing>
Reviewed <X> files across <Y> commits. Tests: <passed | N failed | not present>.

### Findings

#### 🔴 High — <one-line summary>
`path/to/file.ts:42`
**What breaks:** <concrete failure scenario — inputs/state → wrong result>
**Why it's a regression:** <what worked before and no longer does — omit for net-new bugs>
**Suggested fix:** <specific change, not "add validation">

#### 🟡 Low — <one-line summary>
`path/to/other.py:88`
**What breaks:** <…>
**Suggested fix:** <…>

### Test & build results
<what you ran and what happened — paste the relevant failure output>

### Not covered
<anything you couldn't verify: untested paths, external services, static-only review>
```

Severity is about impact, not certainty. Reserve **High** for things that break real behavior — wrong output, crashes, data loss, security holes, a failing build. **Low** is for smells, minor edge cases, and style issues that won't actually bite. If a finding is a guess, say so and explain what would confirm it rather than dropping it or overstating it.

If you find nothing, say so directly — "No bugs or regressions found; tests pass" is a complete and valuable answer. Don't manufacture filler findings to look thorough; a clean branch reported honestly is the goal, not a long list.

## Keep the signal high

The failure mode of a bug check is crying wolf — a wall of maybes trains the user to ignore it. Before you report a finding, make the case for it to yourself: what exact input produces the bad outcome, and can you point to the line? If you can't, it's a question, not a finding — either dig until it's one or leave it out. A short report the user trusts beats a long one they skim.
