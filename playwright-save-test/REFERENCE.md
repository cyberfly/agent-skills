# Reference: MCP session → Playwright Test

## Locator priority (most to least stable)

1. `getByRole(role, { name })` — from the accessible role + accessible name shown in `browser_snapshot`
2. `getByLabel(text)` — form fields with an associated `<label>`
3. `getByPlaceholder(text)`
4. `getByTestId(id)` — only if the snapshot/HTML shows a `data-testid` (or configured test-id attribute)
5. `getByText(text)` — exact text match; last resort, and only for elements with stable, non-dynamic text
6. CSS/XPath selector — avoid; use only when nothing above uniquely identifies the element, and prefer a structural selector (`form >> nth=0`) over relying on generated class names

Never use the MCP tool's internal `ref` (e.g. `"e12"`) in the generated script. It is an id into that specific `browser_snapshot` call and does not exist outside the MCP session — a script built on it will not run.

## MCP tool → Playwright Test API mapping

| MCP tool call | Playwright Test equivalent |
|---|---|
| `browser_navigate(url)` | `await page.goto(url)` |
| `browser_click(element, ref)` | `await page.getByRole(role, { name }).click()` |
| `browser_type(element, ref, text)` | `await page.getByRole(role, { name }).fill(text)` |
| `browser_fill_form(fields[])` | one `.fill()` / `.check()` / `.selectOption()` per field |
| `browser_select_option(element, ref, values)` | `await page.getByRole('combobox', { name }).selectOption(values)` |
| `browser_press_key(key)` | `await page.keyboard.press(key)` |
| `browser_wait_for({ text })` | `await expect(page.getByText(text)).toBeVisible()` |
| `browser_wait_for({ textGone })` | `await expect(page.getByText(textGone)).toBeHidden()` |
| `browser_hover(element, ref)` | `await page.getByRole(role, { name }).hover()` |
| `browser_drag(startRef, endRef)` | `await source.dragTo(target)` |
| `browser_file_upload(paths)` | `await page.getByLabel(name).setInputFiles(paths)` |
| `browser_snapshot` (used to confirm state) | `await expect(locator).toBeVisible()` / `.toHaveValue()` / `.toHaveURL()` as appropriate |

Collapse consecutive MCP calls that target the same field (e.g. several `browser_type` calls while correcting a typo) into a single final `.fill()` in the generated script — the script should reflect the *correct* path, not the trial-and-error.

## Template skeleton

```ts
import { test, expect } from '@playwright/test';

test('<slug — e.g. "signup form">', async ({ page }) => {
  await page.goto('<url>');

  await page.getByLabel('Full name').fill('<value>');
  await page.getByLabel('Email').fill('<value>');
  await page.getByRole('combobox', { name: 'Country' }).selectOption('<value>');
  await page.getByRole('button', { name: 'Submit' }).click();

  await expect(page.getByText('<success message observed in the MCP session>')).toBeVisible();
});
```

Notes:
- Replace any secret values (passwords, tokens) observed during the MCP session with `process.env.SOME_VAR` and a comment, not the literal value.
- If the flow spans multiple pages, split long chains with a comment per page/step rather than one dense block.
