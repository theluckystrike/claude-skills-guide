---
title: "Stop Claude Code Breaking Working Features (2026)"
description: "Prevent Claude Code from introducing regressions — add test-before-change rules, rollback protocols, and scope guards to your CLAUDE.md."
permalink: /claude-code-breaks-working-features-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Stop Claude Code Breaking Working Features (2026)

You asked Claude Code to add a feature. It worked, but it also broke two existing features in the process. Here's how to prevent regressions.

## The Problem

Claude Code introduces regressions by:
- Modifying shared functions that other features depend on
- Changing type signatures that break downstream callers
- Refactoring utility code that was working fine
- Overwriting configuration values
- Modifying test fixtures used by other tests

## Root Cause

Claude Code doesn't automatically track downstream dependencies. When it modifies a shared function, it doesn't check every caller. Without test-running rules, broken callers aren't detected until you run the test suite manually.

## The Fix

```markdown
## Regression Prevention

### Before Modifying Shared Code
1. Search for all callers/importers of the function/file you're about to change
2. List them explicitly
3. Verify the change won't break any caller
4. If it might, update the callers too

### Test After Every Change
- Run relevant tests after EVERY code modification (not just at the end)
- If tests fail, fix the regression before continuing
- Never leave failing tests "to fix later"

### Rollback Protocol
If a change causes unexpected test failures:
1. Revert the change immediately
2. Analyze why it broke
3. Implement a safer approach
4. Run tests again
```

## CLAUDE.md Rule to Add

```markdown
## No-Regression Rule
- Before modifying any exported function, search for all import/require statements that reference it
- Run the test suite after every file modification, not just at the end
- If a test breaks that isn't directly related to your task, STOP and revert your last change
- Shared utilities (src/utils/, src/lib/) require extra caution: search for all consumers first
```

## Verification

```
Change the `formatDate` utility to use ISO format instead of locale format
```

**Regression-prone:** changes `formatDate()` without checking that 12 components rely on locale formatting
**Safe:** searches for all uses, lists them, and either updates each use or creates a new `formatDateISO()` instead of modifying the existing one

Related: [Karpathy Surgical Changes](/karpathy-surgical-changes-principle-2026/) | [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/) | [Make Claude Code Write Tests First](/claude-code-write-tests-first-tdd-setup-2026/)
