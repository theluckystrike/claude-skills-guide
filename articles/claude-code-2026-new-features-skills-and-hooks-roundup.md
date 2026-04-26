---
layout: default
title: "Claude Code 2026 Features Roundup"
description: "Claude Code 2026 skills and hooks roundup: pdf, tdd, supermemory, webapp-testing, and hook system with real invocation examples and config patterns."
date: 2026-03-13
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills, hooks, pdf, tdd, supermemory, webapp-testing]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-code-2026-new-features-skills-and-hooks-roundup/
geo_optimized: true
---

# Claude Code 2026 New Features: Skills and Hooks Roundup

Claude Code has expanded significantly in 2026. [The skills ecosystem now covers over fifty specialized capabilities](/best-claude-code-skills-to-install-first-2026/), and the hook system gives developers structured control over when and how Claude acts. This roundup covers the most impactful additions.

[Skills are `.md` files in `~/.claude/skills/`, invoked with `/skill-name`](/claude-skill-md-format-complete-specification-guide/) Hooks are shell commands configured in `~/.claude/settings.json` that fire before and after Claude's actions.

## Skills Overview

The table below summarizes the key skills added or significantly expanded in 2026. Each section below goes deeper on invocation patterns and practical use.

| Skill | Primary Use |
|---|---|
| `pdf` | Extract, batch-process, and merge PDF documents |
| `frontend-design` | Generate components and audit UI against design specs |
| `tdd` | Write test-first suites with edge case and property-based coverage |
| `supermemory` | Persist and semantically retrieve context across sessions |
| `webapp-testing` | Playwright-driven E2E testing and visual regression |
| `xlsx` | Generate and modify spreadsheets with charts and formulas |

## PDF Processing with the pdf Skill

The [`pdf` skill](/best-claude-skills-for-data-analysis/) handles technical documentation, contracts, and data extraction. It supports batch processing and encrypted documents:

```
/pdf process all files in invoices/ and extract the vendor, amount, and date from each. Format as a markdown table.
```

```
/pdf extract the data table from page 7 of technical-spec.pdf. The table has columns: Parameter, Type, Default, Description.
```

```
/pdf merge cover-letter.pdf and portfolio.pdf into application-packet.pdf
```

The skill integrates into documentation pipelines by pulling code examples, API signatures, and configuration blocks from PDF-based resources. technical docs distributed as PDFs are no longer a dead end.

## Frontend Design with the frontend-design Skill

The `frontend-design` skill generates component code and validates UI implementations:

```
/frontend-design create a responsive card component in React with Tailwind: image top, title H3, description text, CTA button. Primary color #1A73E8, 8px spacing grid.
```

```
/frontend-design audit this component for WCAG 2.1 AA violations. check contrast ratios, aria labels, and keyboard navigation: [paste component]
```

```
/frontend-design verify this implementation matches the Figma spec: [paste spec details and component code]
```

The skill's Figma integration (paste spec, receive code) is the most-used new capability in 2026 for frontend teams.

## Test-Driven Development with the tdd Skill

The [`tdd` skill](/best-claude-skills-for-developers-2026/) guides test-first development and generates meaningful test cases:

```
/tdd write Jest tests for UserService.authenticate(). include valid credential tests, invalid credential tests, and network timeout handling
```

```
/tdd given this failing test, implement the function that makes it pass: [paste test]
```

```
/tdd add property-based tests for this pure function using fast-check: [paste function]
```

Property-based testing support and fuzz input generation are new in 2026. the skill can now generate randomized inputs to find edge cases that manually written tests miss.

## Memory Management with the supermemory Skill

The [`supermemory` skill](/claude-skills-token-optimization-reduce-api-costs/) provides persistent context across sessions:

```
/supermemory store: project-stack = Next.js 14, TypeScript, PostgreSQL, Prisma, Railway deployment
```

```
/supermemory store: linting = ESLint Airbnb config, Prettier, 2-space indent, single quotes
```

```
/supermemory What is the project stack?
```

The semantic search capability added in 2026 makes retrieval more flexible:

```
/supermemory What decisions did we make about the database setup?
```

Previously this required remembering exact key names. Now the skill searches stored context by meaning.

## Web Testing with the webapp-testing Skill

The `webapp-testing` skill provides Playwright integration for frontend testing:

```
/webapp-testing verify the checkout flow on http://localhost:3000: add item to cart, proceed to checkout, fill in test card 4242424242424242, submit, confirm redirect to /confirmation
```

```
/webapp-testing take a baseline screenshot of /dashboard and save as dashboard-baseline.png
```

```
/webapp-testing compare the current /dashboard against dashboard-baseline.png and report visual differences above 5%
```

Visual regression testing is the most impactful new capability. screenshot comparisons catch layout regressions without manual inspection.

## Spreadsheet Automation with the xlsx Skill

The `xlsx` skill generates and modifies Excel spreadsheets programmatically, including chart types that are cumbersome to configure manually:

```
/xlsx create a waterfall chart in budget.xlsx showing starting balance, monthly inflows, monthly outflows, and ending balance for Q1
```

```
/xlsx add sparklines to the summary row in metrics.xlsx showing the 12-month trend for each KPI
```

```
/xlsx build a pivot table in sales-data.xlsx grouped by region and product line, showing total revenue and unit count
```

Waterfall charts, treemaps, and sparklines were added in 2026. chart types previously requiring manual steps in Excel are now one-command operations.

## Hook System

Claude Code's hook system lets you intercept and modify behavior at key decision points. Hooks are shell commands, not JavaScript functions. Configure them in `~/.claude/settings.json`:

```json
{
 "hooks": {
 "preToolUse": [
 {
 "matcher": "Bash",
 "hooks": [
 {
 "type": "command",
 "command": "echo 'Running bash command: ' >> ~/.claude/audit.log"
 }
 ]
 }
 ],
 "postToolUse": [
 {
 "matcher": "Write",
 "hooks": [
 {
 "type": "command",
 "command": "npx prettier --write \"$CLAUDE_TOOL_OUTPUT_PATH\""
 }
 ]
 }
 ]
 }
}
```

## Available Hook Types

- PreToolUse. fires before Claude executes a tool (Bash, Write, Edit, etc.)
- PostToolUse. fires after tool execution with access to the output
- Notification. fires when Claude sends a notification

Hooks receive context about the current operation as environment variables. `CLAUDE_TOOL_NAME`, `CLAUDE_TOOL_INPUT`, and `CLAUDE_TOOL_OUTPUT_PATH` are available depending on the hook type.

## Practical Hook Uses

Auto-format writes: Run Prettier after every file write.

Audit logging: Log every bash command to a file for review.

Enforce commit hooks: Run lint-staged before any git commit the agent makes.

Block dangerous operations: Exit with a non-zero code in a PreToolUse hook to block a specific operation and surface an error to Claude.

```json
{
 "hooks": {
 "preToolUse": [
 {
 "matcher": "Bash",
 "hooks": [
 {
 "type": "command",
 "command": "if echo \"$CLAUDE_TOOL_INPUT\" | grep -q 'rm -rf'; then echo 'Blocked: rm -rf not allowed' >&2; exit 1; fi"
 }
 ]
 }
 ]
 }
}
```

## Combining Skills with Hooks

The real use comes from combining skills with hooks in automation pipelines. For example, a documentation-to-test workflow:

```
Step 1: /pdf extract all function signatures from api-docs.pdf
Step 2: /tdd generate unit tests for each of these function signatures: [paste output]
```

Add a PostToolUse hook that runs your test suite after every Write operation, so you immediately know if a generated test file is syntactically valid:

```json
{
 "hooks": {
 "postToolUse": [
 {
 "matcher": "Write",
 "hooks": [
 {
 "type": "command",
 "command": "if [[ \"$CLAUDE_TOOL_OUTPUT_PATH\" == *.test.* ]]; then npx jest \"$CLAUDE_TOOL_OUTPUT_PATH\" --passWithNoTests 2>&1 | tail -5; fi"
 }
 ]
 }
 ]
 }
}
```

This gives you immediate feedback on generated tests without manually switching to the terminal.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-2026-new-features-skills-and-hooks-roundup)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/). Top skills every developer should know
- [Claude Skills vs Prompts: Which Is Better?](/claude-skills-vs-prompts-which-is-better/). Decide when skills beat plain prompts
- [Claude Skills Auto Invocation: How It Works](/claude-skills-auto-invocation-how-it-works/). How skills activate automatically


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

*Built by theluckystrike. More at [zovo.one](https://zovo.one)
*


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

