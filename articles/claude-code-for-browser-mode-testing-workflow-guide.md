---
layout: default
title: "Claude Code for Browser Mode Testing"
description: "Run Vitest browser mode tests with Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-browser-mode-testing-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, browser-mode-testing, workflow]
---

## The Setup

You are testing frontend components with Vitest Browser Mode, which runs tests in a real browser instead of jsdom or happy-dom. Browser Mode uses Playwright or WebDriverIO to launch an actual browser, giving you real DOM APIs, real CSS rendering, and real event handling. Claude Code can write Vitest tests, but it generates tests that assume jsdom environment and miss Browser Mode's capabilities.

## What Claude Code Gets Wrong By Default

1. **Uses jsdom-specific workarounds.** Claude adds `jest.fn()` for `window.matchMedia` or mocks `IntersectionObserver`. In Browser Mode, real browser APIs are available — these mocks are unnecessary and can cause conflicts.

2. **Tests with `render` from testing-library.** Claude imports `render` from `@testing-library/react`. Browser Mode uses `@vitest/browser/context` for page interaction and can use testing-library through `@testing-library/vue` or `@testing-library/react` but with the browser provider handling actual rendering.

3. **Skips visual assertions.** Claude only tests functionality, not appearance. Browser Mode runs in a real browser — you can test CSS properties, computed styles, layout, and even take screenshots for visual regression.

4. **Ignores browser-specific configuration.** Claude sets up Vitest with default config. Browser Mode requires `browser: { enabled: true, provider: 'playwright', name: 'chromium' }` in `vitest.config.ts`.

## The CLAUDE.md Configuration

```
# Vitest Browser Mode Testing

## Testing
- Runner: Vitest with Browser Mode
- Browser: Playwright provider (chromium/firefox/webkit)
- Real DOM: No jsdom — tests run in actual browser
- Config: vitest.config.ts with browser section

## Browser Mode Rules
- Config: browser.enabled = true, browser.provider = 'playwright'
- No jsdom mocks needed — real browser APIs available
- Use page from @vitest/browser/context for interactions
- Use locator API: page.getByRole, page.getByText
- Real CSS: test computed styles, layout, visibility
- Screenshots: page.screenshot() for visual regression
- No window/document mocks — they are real

## Conventions
- Test files: *.browser.test.ts for browser tests
- Setup: playwright installed as dev dependency
- Use locator API over direct DOM queries
- Test accessibility with real screen reader semantics
- Test responsive: resize viewport in browser tests
- Use expect(element).toBeVisible() — real visibility check
- CI: run with headless browser (default in CI)
```

## Workflow Example

You want to test a dropdown menu component that depends on CSS positioning and keyboard navigation. Prompt Claude Code:

"Write Vitest Browser Mode tests for a DropdownMenu component. Test that the menu opens on click, positions below the trigger, handles arrow key navigation between items, and closes on Escape. Use the Playwright locator API."

Claude Code should configure the browser test with `import { page } from '@vitest/browser/context'`, use `page.getByRole('button')` to find the trigger, click it, verify the menu is visible with real DOM checks, test arrow key navigation with `keyboard.press('ArrowDown')`, and verify Escape closes the menu.

## Common Pitfalls

1. **Mixing jsdom and browser tests.** Claude puts all tests in the same config. Browser Mode tests should be in separate files or use workspace config — jsdom tests and browser tests cannot share the same Vitest instance.

2. **Not waiting for animations.** Claude asserts immediately after triggering a transition. In a real browser, CSS animations take time. Use `waitFor` or `expect.poll` to wait for the element to reach its final state.

3. **Forgetting headless mode for CI.** Claude runs browser tests without configuring headless mode. In CI environments, set `browser.headless: true` in vitest config to run without a visible browser window.

## Related Guides

- [Claude Code Integration Testing Strategy Guide](/claude-code-integration-testing-strategy-guide/)
- [Claude Code for Playwright MCP Workflow Guide](/claude-code-for-playwright-mcp-workflow-guide/)
- [Claude Code for Storybook Test Workflow Guide](/claude-code-for-storybook-test-workflow-guide/)

## See Also

- [Claude Code for Storybook Component Testing Workflow](/claude-code-for-storybook-component-testing-workflow/)
- [Claude Code for Spike Testing Workflow Tutorial Guide (2026)](/claude-code-for-spike-testing-workflow-tutorial-guide/)
- [Claude Code + Percy Visual Testing (2026)](/claude-code-for-percy-visual-testing-workflow-guide/)
- [Claude Code Verbose Mode: Debug Output Guide 2026](/claude-code-verbose-mode-debug-output-2026/)
- [Claude Code for Runbook Testing Workflow Tutorial](/claude-code-for-runbook-testing-workflow-tutorial/)
