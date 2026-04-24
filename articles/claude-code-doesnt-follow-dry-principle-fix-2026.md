---
title: "Make Claude Code Follow DRY Principle"
description: "Make Claude Code follow DRY by mapping shared utilities, requiring reuse checks, and adding deduplication rules to your CLAUDE.md."
permalink: /claude-code-doesnt-follow-dry-principle-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Make Claude Code Follow DRY Principle (2026)

Three different files contain the same email validation regex. Two services implement identical retry logic. A formatting function exists in four variations across the codebase. Claude Code creates new implementations instead of reusing existing ones.

## The Problem

DRY (Don't Repeat Yourself) violations from Claude Code:
- Duplicated validation logic across files
- Copy-pasted error handling patterns
- Multiple implementations of the same algorithm
- Repeated configuration objects
- Identical type definitions in different modules

## Root Cause

Claude Code processes one request at a time. When you ask it to add validation to a form, it writes validation code — without checking if identical validation exists elsewhere. The model does not perform a codebase-wide deduplication scan before generating code.

## The Fix

The [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) enforces DRY through its `/sc:implement` command, which checks existing code before creating new code. Combine this with a utility registry in CLAUDE.md.

### Step 1: Create a Shared Code Registry

```markdown
## Shared Code — USE THESE, DO NOT RECREATE

### Validation (src/utils/validation.ts)
- validateEmail, validatePhone, validateUrl
- validateRequired, validateMinLength, validateMaxLength
- validateRange, validatePattern, validateEnum

### Error Handling (src/utils/errors.ts)
- AppError class (code, message, statusCode)
- withErrorHandling(fn) — wraps async functions with try/catch
- retryWithBackoff(fn, maxRetries) — retry with exponential backoff

### Formatting (src/utils/format.ts)
- formatCurrency, formatDate, formatPhoneNumber
- formatFileSize, formatDuration, formatPercentage

### HTTP (src/lib/api.ts)
- apiClient — pre-configured ky instance with auth, retry, error handling
- DO NOT create new HTTP client instances
```

### Step 2: Add the DRY Check Rule

```markdown
## DRY Protocol — MANDATORY
Before writing ANY utility function:
1. Search src/utils/ and src/lib/ for existing implementations
2. If a function does 70%+ of what you need, extend it
3. If extending is not feasible, create a new function in the SAME file as related functions
4. NEVER create a standalone utility file for a single function

Before writing ANY logic that might already exist:
1. grep for key terms (e.g., "retry", "validate", "format")
2. Check existing test files for usage patterns
3. If you find duplicate logic, refactor into shared utility FIRST
```

### Step 3: Enforce Centralized Patterns

```markdown
## Pattern Centralization
These patterns are implemented ONCE and imported everywhere:

### Retry pattern: src/utils/errors.ts → retryWithBackoff()
### Auth check: src/middleware/auth.ts → requireAuth()
### Pagination: src/utils/pagination.ts → paginate()
### Cache wrapper: src/lib/cache.ts → withCache()
### Rate limiting: src/middleware/rate-limit.ts → rateLimit()

If you need one of these patterns, import from the central location.
Do not implement your own version.
```

## CLAUDE.md Code to Add

```markdown
## Deduplication Check
After writing any code:
1. Count how many times the same logic pattern appears in the codebase
2. If the pattern appears 3+ times, extract it into a shared utility
3. If you are about to write logic that is similar to existing code, stop and refactor
```

## Verification

1. Ask Claude Code to add input validation to a new form
2. Check: Does it import from `src/utils/validation.ts`?
3. Ask: "Is there any duplicated logic in this codebase?"
4. Claude Code should identify and propose consolidation

## Prevention

Add code duplication detection to your CI:

```bash
npx jscpd src/ --threshold 3 --reporters console
```

This flags any block of code that appears 3+ times. The [awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit) includes deduplication plugins for ongoing monitoring.

For more on code reuse, see the [duplicate code fix guide](/claude-code-creates-duplicate-code-fix-2026/). For utility organization patterns, read the [CLAUDE.md best practices guide](/claude-md-best-practices-10-templates-compared-2026/). For team standards that prevent duplication, check the [team onboarding playbook](/claude-code-team-onboarding-playbook-2026/).
