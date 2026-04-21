---
title: "Implement Goal-Driven Execution in CLAUDE.md (2026)"
description: "Copy-paste CLAUDE.md rules that enforce Karpathy's Goal-Driven Execution — goal tracking, scope gates, and completion criteria for Claude Code."
permalink: /karpathy-goal-driven-implementation-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Implement Goal-Driven Execution in CLAUDE.md (2026)

Production-ready CLAUDE.md blocks that keep Claude Code locked on the stated goal. Three versions from lightweight to strict, each with goal tracking, scope gates, and completion signaling.

## The Principle

Every action serves the stated goal. See the [full principle guide](/karpathy-goal-driven-execution-principle-2026/).

## Why It Matters

Sessions without goal tracking accumulate drift. A 30-minute session can spend 20 minutes on tangential work that wasn't requested. Goal-Driven rules create checkpoints that catch drift early.

## CLAUDE.md Implementation

### Minimal Version

```markdown
## Goal Focus
- State the goal before starting work
- Only modify code that directly serves the goal
- Report unrelated issues separately, don't fix them
- When the goal is complete, say so explicitly
```

### Standard Version

```markdown
## Goal-Driven Execution

### Before Starting
Restate the goal in this format:
**Goal:** [one sentence describing what will be done]
**Files likely affected:** [list]
**Out of scope:** [anything the user might expect but isn't part of this task]

### During Work
- Before each tool call, verify it serves the stated goal
- If you discover the task is larger than expected, pause and report:
  "This task requires [additional work]. Proceed, or adjust scope?"
- Do NOT start work on adjacent improvements

### After Completing
**Goal complete.** [summary of what was done]
**Changed:** [file list with line counts]
**Noticed but not fixed:** [list of adjacent issues, or "None"]
**Suggested follow-ups:** [optional list of related work]
```

### Strict Version

```markdown
## Goal-Driven Execution — Strict Protocol

### Goal Contract
At the start of every task, produce:
- **Goal:** [exact objective]
- **Success criteria:** [how to verify the goal is met]
- **Boundary:** [what this task does NOT include]
- **Estimated scope:** [files and approximate line count]

Get user confirmation before proceeding.

### Drift Detection
After every 3 tool calls, run a mental check:
- Is the current action directly serving the goal?
- Have I modified any file not in the estimated scope?
- Am I adding features or improvements not in the goal?

If any answer is yes, stop and explain the deviation.

### Completion Protocol
1. State: "Goal complete."
2. Run the success criteria check
3. List all files modified with justification
4. List anything noticed but not fixed
5. Suggest follow-up tasks (clearly marked as NOT done)

### Hard Limits
- Do NOT exceed estimated scope by more than 50% without confirmation
- Do NOT modify configuration files unless the goal requires it
- Do NOT install or upgrade dependencies unless the goal requires it
```

## Before/After Examples

### Before: Silent Scope Expansion

```
User: Add input validation to the signup form

Claude Code: I've added validation to the signup form. I also:
- Refactored the form to use react-hook-form
- Added loading states during submission
- Implemented error display with toast notifications
- Created a reusable FormField component

Changed 6 files.
```

The user wanted validation. They got a form rewrite.

### After: Goal-Driven

```
User: Add input validation to the signup form

Claude Code:
**Goal:** Add input validation to the signup form.
**Files likely affected:** src/components/SignupForm.tsx
**Out of scope:** form refactoring, UX improvements, new components

I'll add validation rules for email format, password strength,
and required fields. The current form uses controlled inputs with
useState — I'll add validation within that existing pattern.

[implements validation]

**Goal complete.** Added validation for 3 fields in SignupForm.tsx.
**Changed:** src/components/SignupForm.tsx (+22 lines)
**Noticed but not fixed:**
- Form could benefit from react-hook-form for cleaner state management
- No loading state during submission
- Error display is inline only, no toast notifications
```

Same goal. 1 file instead of 6.

## Common Mistakes

1. **Goal contract too detailed** — the goal statement should be 1-2 sentences, not a specification document. Keep it focused.

2. **Not using the "noticed" list** — suppressing observations is worse than goal drift. The list captures them without acting on them.

3. **Strict mode on trivial tasks** — "fix the typo in line 12" doesn't need a goal contract. Reserve strict mode for tasks where drift is likely (features, refactors, multi-file changes).

## Related Principles

- [Goal-Driven Examples](/karpathy-goal-driven-examples-2026/) — real project scenarios
- [Fix Claude Code Losing Track](/karpathy-goal-driven-debugging-2026/) — debugging goal drift
- [CLAUDE.md Best Practices](/claude-md-file-best-practices-guide/) — where goal rules fit
- [The Claude Code Playbook](/the-claude-code-playbook/) — workflow patterns
