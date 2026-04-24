---
title: "Stop Claude Code Creating Duplicate"
description: "Prevent Claude Code from creating duplicate functions and modules by mapping existing utilities in CLAUDE.md and enforcing reuse rules."
permalink: /claude-code-creates-duplicate-code-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Stop Claude Code Creating Duplicate Code (2026)

You ask Claude Code to add email validation to a form, and it writes a new `validateEmail()` function. You already have one in `src/utils/validators.ts`. Now you have two validation functions with slightly different regex patterns, and neither knows about the other.

## The Problem

Claude Code creates new utility functions, helper modules, and service classes even when equivalent code already exists in your project. This leads to:
- Duplicate logic with subtle differences
- Increased bundle size
- Maintenance burden when you need to update logic in multiple places
- Inconsistent behavior across features

## Root Cause

Claude Code does not automatically inventory your existing utilities before writing new ones. It reads files on demand, and if it has not been pointed to your utility directory, it defaults to creating new code. The model optimizes for completing your request quickly, not for reuse.

## The Fix

Create a utility registry in your `CLAUDE.md` using the pattern from [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework). SuperClaude's `/sc:implement` command enforces a "check before create" workflow with its 16 built-in agents.

### Step 1: Register Your Utilities

```markdown
## Existing Utilities — USE THESE, DO NOT RECREATE

### Validation (src/utils/validators.ts)
- validateEmail(email: string): boolean
- validatePhone(phone: string): boolean
- validateUrl(url: string): boolean
- validatePassword(pw: string): { valid: boolean, errors: string[] }

### Formatting (src/utils/formatters.ts)
- formatCurrency(cents: number, locale?: string): string
- formatDate(date: Date, format?: string): string
- formatPhoneNumber(phone: string): string
- truncateText(text: string, maxLength: number): string

### HTTP (src/lib/api-client.ts)
- apiGet<T>(path: string): Promise<T>
- apiPost<T>(path: string, body: unknown): Promise<T>
- apiPut<T>(path: string, body: unknown): Promise<T>
- apiDelete(path: string): Promise<void>
```

### Step 2: Add the Reuse Rule

```markdown
## Code Reuse — MANDATORY
Before creating ANY new function:
1. Check if a similar function exists in src/utils/ or src/lib/
2. If a function does 80%+ of what you need, extend it — do not duplicate
3. If you must create a new utility, add it to the appropriate existing file
4. NEVER create a new utils file if one exists for that category
```

### Step 3: Map Component Libraries

```markdown
## Shared Components (src/components/ui/)
- Button, Input, Select, Textarea, Modal, Toast, Card, Badge, Avatar
- ALWAYS use these instead of creating one-off styled elements
- Check src/components/ui/index.ts for the full export list
```

## CLAUDE.md Code to Add

```markdown
## Deduplication Protocol
When asked to implement any feature:
1. Read the relevant utils/ and lib/ directories first
2. List any existing functions that overlap with the requirement
3. Propose extending existing code before writing new code
4. If creating something new is necessary, explain why existing code is insufficient
```

## Verification

1. Ask Claude Code: "Add phone number formatting to the signup form"
2. It should import `formatPhoneNumber` from `src/utils/formatters.ts`
3. It should NOT create a new formatting function
4. Ask: "What utility functions are available for validation?"
5. It should list functions from your CLAUDE.md registry

## Prevention

Run periodic deduplication audits. Tools like [jscpd](https://github.com/kucherenko/jscpd) detect copy-paste patterns. Add this to your CI:

```bash
npx jscpd src/ --threshold 5
```

The [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) index lists several deduplication skills that integrate directly with Claude Code sessions.

For more on enforcing code quality patterns, see our [Claude Code best practices guide](/karpathy-skills-vs-claude-code-best-practices-2026/). Learn how to build custom skills that enforce reuse in [our skills guide](/claude-skills-directory-where-to-find-skills/). For DRY principle enforcement specifically, read our [DRY principle article](/claude-code-doesnt-follow-dry-principle-fix-2026/).
