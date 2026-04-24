---
title: "Fix Claude Code Wrong Abstraction Level (2026)"
description: "Correct Claude Code's abstraction choices — too abstract for simple tasks, too concrete for reusable code. CLAUDE.md rules for calibrated design."
permalink: /claude-code-wrong-abstraction-level-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Fix Claude Code Wrong Abstraction Level (2026)

Claude Code either over-abstracts simple things (factory pattern for a function) or under-abstracts reusable things (copy-pasting instead of extracting). Here's how to calibrate it.

## The Problem

**Over-abstraction:**
- Interface + abstract class + factory for a single implementation
- Generic type system for 2 concrete types
- Plugin architecture for 1 plugin

**Under-abstraction:**
- Copy-pasting the same 20 lines across 5 files
- Inline logic that's used in 4 places
- No shared types for data used across modules

## Root Cause

Claude Code doesn't reason about usage frequency. It abstracts based on pattern recognition ("this looks like it should be a factory") rather than actual reuse needs ("how many callers will there be?").

## The Fix

```markdown
## Abstraction Calibration

### When to Abstract (create shared code)
- The same logic appears in 3+ places
- A function has 5+ callers
- A data shape is used in 3+ files
- An external service is called from 3+ places

### When NOT to Abstract
- Code is used in 1-2 places (inline it or keep it local)
- The "abstraction" would be a thin wrapper around an existing API
- The only reason to abstract is "it might be reused later"

### Abstraction Decision Framework
Before creating an abstraction, answer:
1. How many callers exist RIGHT NOW? (not "might exist")
2. Would the callers be simplified by the abstraction?
3. Is the abstraction more complex than the inlined version?

If <3 callers, or the abstraction is more complex, don't abstract.
```

## CLAUDE.md Rule to Add

```markdown
## Abstraction Level Rule
- ≤2 uses: inline or keep local to the file
- 3+ uses: extract to a shared utility with a clear interface
- NEVER abstract "for future flexibility" — abstract when you have evidence of reuse
- When you see copy-pasted code in the codebase, suggest extraction but don't do it unless asked
```

## Verification

**Task 1:** "Add date formatting to the orders page"
- Over-abstracted: creates DateFormatter class, FormatStrategy, locale registry
- Correct: uses inline `date.toLocaleDateString()` if it's used once

**Task 2:** "The same validation logic is copied in 5 endpoints"
- Under-abstracted: adds it inline again in a 6th place
- Correct: suggests extracting to `src/utils/validation.ts` and refactoring the 5 existing uses

Related: [Karpathy Simplicity First](/karpathy-simplicity-first-principle-claude-code-2026/) | [Fix Overcomplicating](/claude-code-overcomplicates-simplicity-fix-2026/) | [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/)
