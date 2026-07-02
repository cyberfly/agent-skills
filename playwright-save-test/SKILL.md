---
name: playwright-save-test
description: Converts a Playwright MCP browser-automation session (e.g. trial-and-error form filling, login, or checkout) into a standalone, deterministic Playwright Test (.spec.ts) file that replays the same flow without AI. Use when the user asks to save/turn a Playwright MCP session into a test or script, wants to make a browser flow repeatable, or after a multi-step Playwright MCP task succeeds and re-running AI for the same flow next time would be wasteful.
---

# Playwright Flow to Test

Turns a successful Playwright MCP session into a reusable `@playwright/test` spec, so the next run is a fast deterministic script instead of an AI-driven exploration.

## When this applies

- The user just finished (or is finishing) a form-fill/login/checkout flow using the Playwright MCP tools (`browser_navigate`, `browser_click`, `browser_type`, `browser_fill_form`, `browser_select_option`, etc.)
- The user asks to "save this", "make a test out of this", "turn this into a script", or "don't make me re-run AI for this next time"

## Quick start

1. Complete (or finish completing) the task with the Playwright MCP tools, confirming success (a confirmation message, redirect, or new page state).
2. While doing so, keep a running log of every meaningful action: the accessible **role + name** (or label/placeholder/test-id) shown in the `browser_snapshot` output at the time — never the MCP `ref` id, which is session-scoped and meaningless outside the MCP session.
3. Translate the log into a Playwright Test file using the mapping table and locator priority in [REFERENCE.md](REFERENCE.md).
4. Save it (see "Where to save" below).
5. Verify it passes standalone: `scripts/verify-test.sh <path-to-spec>`.
6. Report the file path and the rerun command to the user.

## Where to save

- If a `playwright.config.{ts,js,mjs}` exists in the target project, read its `testDir` and save to `<testDir>/generated/<slug>.spec.ts`.
- Otherwise save to `tests/generated/<slug>.spec.ts` (create the directory).
- `<slug>` is a kebab-case name for the flow (e.g. `signup-form`, `checkout-guest`), derived from the page/form purpose or the user's description.

## Building the script

- One `test()` block per flow, named after the slug.
- Prefer locators in this order: `getByRole` → `getByLabel` → `getByPlaceholder` → `getByTestId` → `getByText` → CSS as last resort. Full mapping in [REFERENCE.md](REFERENCE.md).
- Assert the same success condition the MCP session observed (visible text, URL change, element state) with `expect(...)`, not a raw `waitForTimeout`.
- Do not hardcode secrets (passwords, API keys) observed during the MCP session — replace with a placeholder and a comment, or read from `process.env`.

## Verifying

Run `scripts/verify-test.sh <path-to-spec>`. It runs the spec headless via `npx playwright test` and reports pass/fail.

- If it fails, inspect the error (locator not found is the most common cause — the accessible name may differ slightly from what was logged), fix, and re-verify.
- After 2 failed fix attempts, stop and show the user the failure plus the script as-is rather than looping indefinitely.

## Reporting back

Tell the user:
- The saved file path
- The exact rerun command (e.g. `npx playwright test tests/generated/signup-form.spec.ts`)
- That next time, running the script directly skips the AI/MCP exploration entirely

## Reference

See [REFERENCE.md](REFERENCE.md) for the full MCP-tool → Playwright-API mapping table and a template skeleton.
