---
title: "Stop Claude Code Adding Extra Dependencies (2026)"
description: "Prevent Claude Code from adding unnecessary npm packages by defining approved dependency lists and native-first rules in CLAUDE.md."
permalink: /claude-code-adds-unnecessary-dependencies-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Stop Claude Code Adding Extra Dependencies (2026)

You ask Claude Code to format dates and it installs `moment.js`. Your project already uses `date-fns`, and the native `Intl.DateTimeFormat` could have handled it anyway. Now your bundle has two date libraries and 200KB of extra code.

## The Problem

Claude Code suggests installing new packages when:
- Equivalent functionality already exists in your dependencies
- Native APIs handle the use case
- A lighter alternative exists
- The dependency is outdated or deprecated

## Root Cause

Claude Code's training data includes millions of tutorials that start with `npm install`. The model associates tasks with packages: dates = moment, HTTP = axios, UUIDs = uuid. It does not evaluate whether your project already covers the need or whether a native API suffices.

## The Fix

Use the dependency governance pattern from [awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit) (1.4K stars), which includes plugin configurations for dependency management.

### Step 1: Define Approved Dependencies

```markdown
## Approved Dependencies — USE ONLY THESE
| Category | Package | Version | NEVER use |
|----------|---------|---------|-----------|
| HTTP | ky | 1.x | axios, got, node-fetch |
| Dates | date-fns | 3.x | moment, dayjs, luxon |
| Validation | zod | 3.x | joi, yup, class-validator |
| Testing | vitest | 2.x | jest, mocha, ava |
| CSS | tailwindcss | 4.x | styled-components, emotion |
| State | zustand | 5.x | redux, mobx, jotai |
| UUID | crypto.randomUUID() | native | uuid package |
```

### Step 2: Prefer Native APIs

```markdown
## Native-First Rule
Before suggesting ANY package, check if a native API handles it:
- Fetch: use native fetch() (Node 22+), not axios
- UUID: use crypto.randomUUID(), not uuid package
- URL parsing: use new URL(), not query-string package
- Date formatting: use Intl.DateTimeFormat for simple cases
- Structured clone: use structuredClone(), not lodash.cloneDeep
- Array operations: use native methods, not lodash
```

### Step 3: Require Justification for New Dependencies

```markdown
## Adding New Dependencies
If a task genuinely requires a package not in the approved list:
1. State what the package does
2. Explain why no existing dependency or native API covers it
3. Show the bundle size impact (bundlephobia.com)
4. Wait for approval before installing

NEVER run npm/pnpm install without explicit approval.
```

## CLAUDE.md Code to Add

```markdown
## Dependency Protocol
1. Check approved list first
2. Check native APIs second
3. Check existing node_modules third
4. Only then suggest a new package (with justification)
5. Prefer packages with zero dependencies over deep dependency trees
```

## Verification

1. Ask Claude Code to "add a debounce to the search input"
2. Check: Does it write a 5-line debounce function instead of installing lodash?
3. Ask: "Format a date as 'Jan 15, 2026'"
4. Check: Does it use `date-fns` (your approved lib) or suggest `Intl.DateTimeFormat`?

## Prevention

Add a lockfile check to your CI:

```bash
# Fail if lockfile changed unexpectedly
git diff --exit-code pnpm-lock.yaml
```

Use the [ccusage](https://github.com/ryoppippi/ccusage) tool to track if sessions are adding packages, and audit them weekly.

For more on managing your project setup, see [The Claude Code Playbook](/playbook/). For CI enforcement of dependency rules, read the [CI/CD integration guide](/claude-code-ci-cd-integration-guide-2026/). For approved dependency lists in CLAUDE.md, see the [CLAUDE.md best practices guide](/claude-md-best-practices-10-templates-compared-2026/).


## Related

- [process exited with code 1 fix](/claude-code-process-exited-code-1-fix/) — How to fix Claude Code process exited with code 1 error
