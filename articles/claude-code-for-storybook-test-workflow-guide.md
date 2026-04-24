---
layout: default
title: "Claude Code for Storybook Test (2026)"
description: "Claude Code for Storybook Test — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-storybook-test-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, storybook, workflow]
---

## The Setup

You are using Storybook's testing features — interaction tests, visual regression testing, and accessibility checks — to test UI components in isolation. Claude Code can write stories and tests, but it generates Jest/Vitest unit tests instead of Storybook's play function-based interaction tests.

## What Claude Code Gets Wrong By Default

1. **Writes Jest tests for component behavior.** Claude creates `component.test.tsx` files with `render()` and `fireEvent`. Storybook tests use `play` functions inside stories: `play: async ({ canvasElement }) => { }` with Testing Library queries.

2. **Skips the Component Story Format (CSF).** Claude writes stories with the old `storiesOf()` API. Modern Storybook uses CSF3: `export const Primary: Story = { args: { ... }, play: async () => { } }`.

3. **Tests in isolation from visual context.** Claude's unit tests render components without design system providers, themes, or realistic props. Storybook stories render in the full visual context, catching styling and layout issues.

4. **Does not use Storybook's test runner.** Claude runs tests with Jest/Vitest separately. Storybook has `@storybook/test-runner` that executes all play functions as tests: `npx test-storybook`.

## The CLAUDE.md Configuration

```
# Storybook Component Testing

## Testing
- Framework: Storybook 8 with interaction tests
- Test runner: @storybook/test-runner
- Visual: Chromatic for visual regression
- Accessibility: @storybook/addon-a11y

## Storybook Test Rules
- Stories in CSF3 format: export const Story: Story = { }
- Interaction tests in play function, not separate test files
- Use @storybook/test for expect, userEvent, within
- Canvas queries: within(canvasElement).getByRole(...)
- Async interactions: await userEvent.click(button)
- Test runner: npx test-storybook (runs all play functions)
- Accessibility: auto-checked per story with a11y addon

## Conventions
- Stories colocated: Button.stories.tsx next to Button.tsx
- One story per component state (Primary, Disabled, Loading)
- Play functions for interactive behavior (click, type, submit)
- Args for component prop variations
- Decorators for providers (theme, router, store)
- Visual tests via Chromatic CI integration
- Never write separate .test.tsx files for visual components
```

## Workflow Example

You want to test a form component with interaction tests. Prompt Claude Code:

"Create Storybook stories for the LoginForm component with play function tests. Test the happy path (fill email, fill password, submit), validation errors (empty fields), and loading state during submission."

Claude Code should create CSF3 stories with `play` functions using `userEvent.type()` for filling fields, `userEvent.click()` for submission, `expect(element).toBeInTheDocument()` for assertions, and `waitFor()` for async validation and loading state transitions.

## Common Pitfalls

1. **Importing test utilities from wrong package.** Claude imports `expect` from `@jest/globals` or `vitest`. Storybook tests use `import { expect, userEvent, within } from '@storybook/test'` — a wrapper that works in both the browser and test runner.

2. **Not awaiting user interactions.** Claude writes `userEvent.click(button)` without `await`. Storybook interactions are async — missing await causes tests to pass before the interaction completes, creating false positives.

3. **Play function running in wrong order.** Claude defines multiple stories expecting sequential execution. Each story's play function runs independently. For multi-step flows, use a single story with all steps in one play function or use `step()` for named sub-steps.

## Related Guides

- [Claude Code Accessibility Regression Testing](/claude-code-accessibility-regression-testing/)
- [Best Claude Code Skills for Frontend Development](/best-claude-code-skills-for-frontend-development/)
- [Claude Code Cypress Component Testing Guide](/claude-code-cypress-component-testing-guide/)

## Related Articles

- [PostHog A/B Testing with Claude Code Guide](/claude-code-posthog-multivariate-test-implementation-guide/)
- [Claude Code Vcr Test Recording — Complete Developer Guide](/claude-code-vcr-test-recording-workflow/)
- [Claude Code Statsig Ab Test — Complete Developer Guide](/claude-code-statsig-ab-test-experiment-setup-guide/)
- [Claude Code for Test Driven Development Workflow Tutorial](/claude-code-for-test-driven-development-workflow-tutorial/)
- [How QA Engineers Use Claude Code for Test Automation](/how-qa-engineers-use-claude-code-for-test-automation/)
- [Claude Code for Chromatic Visual Test — Guide](/claude-code-for-chromatic-visual-test-workflow-guide/)
- [How To Make Claude Code Use My — Complete Developer Guide](/how-to-make-claude-code-use-my-preferred-test-framework/)
- [Claude Code JUnit5 Test Patterns Guide](/claude-code-junit5-test-patterns-guide/)
