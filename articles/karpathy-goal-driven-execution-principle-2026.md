---
title: "Karpathy Goal-Driven Execution (2026)"
description: "Apply Karpathy's Goal-Driven Execution to keep Claude Code focused on the stated objective — no scope creep, no tangents, no forgotten goals."
permalink: /karpathy-goal-driven-execution-principle-2026/
last_tested: "2026-04-22"
---

# Karpathy Goal-Driven Execution Explained (2026)

Goal-Driven Execution is the fourth principle from Karpathy's behavioral guidelines. It addresses a failure mode that becomes worse in long sessions: Claude Code loses track of the original objective and starts solving adjacent problems.

## The Principle

**Goal-Driven Execution.** Every action Claude Code takes should serve the stated goal. Before each step, the agent should verify it's still working toward the objective. If scope creep is detected, flag it and return to the goal.

This means:
- State the goal before starting work
- Verify alignment at each step
- Resist the pull of "adjacent improvements"
- Flag when a task reveals a larger scope than expected
- Complete the stated goal before suggesting next steps

## Why It Matters

Claude Code sessions drift. A request to "fix the login bug" might evolve into refactoring the auth module, upgrading the JWT library, and adding refresh token support — all reasonable work, but none of it was the goal.

Drift is expensive:
- **Token waste** — work on non-goals consumes budget without delivering the requested feature
- **Review burden** — larger diffs take longer to review
- **Context dilution** — the agent's context window fills with tangential code, reducing quality on the actual task
- **Delayed delivery** — the original goal takes 3x longer because the agent kept wandering

Goal-Driven Execution is the antidote. It creates a feedback loop where every action is evaluated against the original request.

## CLAUDE.md Implementation

```markdown
## Goal-Driven Execution (Karpathy Principle)

### Goal Tracking
- At the start of every task, restate the goal in one sentence
- After every tool call or code change, verify the action serves the goal
- If you notice yourself working on something not directly related to the goal, STOP and flag it

### Scope Gates
- The goal is ONLY what was explicitly requested
- "While I was working on X, I noticed Y" → report Y, don't fix Y
- "This would also benefit from Z" → suggest Z after completing the goal, don't start Z
- If the task is bigger than expected, report the scope increase and ask how to proceed

### Completion Criteria
- A task is done when the stated goal is met, not when all possible improvements are made
- After completing the goal, summarize what was done and explicitly state "Goal complete"
- Only then suggest follow-up work as a separate list
```

## Before/After Examples

### Before (Goal Drift)

```
User: Fix the 500 error on the /api/orders endpoint

Claude Code: I found the error — a null reference when the user has no
shipping address. While fixing this, I noticed:
1. The orders query isn't paginated (could be slow for large datasets)
2. The response doesn't include shipping status
3. The error handling is inconsistent with other endpoints

I've fixed all four issues:
- Null check for shipping address ✓
- Added pagination with cursor-based approach ✓
- Added shipping status to response ✓
- Standardized error handling ✓

Changed 4 files, 120 lines modified.
```

### After (Goal-Driven)

```
User: Fix the 500 error on the /api/orders endpoint

Claude Code: **Goal:** Fix the 500 error on /api/orders.

I found the root cause — `user.shippingAddress.street` throws when
`shippingAddress` is null. Users without a shipping address trigger this.

Fix: Added null check before accessing shipping address fields.

```diff
- street: user.shippingAddress.street,
+ street: user.shippingAddress?.street ?? null,
```

**Goal complete.** 1 line changed in src/routes/orders.ts.

**Noticed but not fixed:**
- Orders query isn't paginated (performance risk for large datasets)
- Response doesn't include shipping status field
- Error handling pattern differs from other endpoints
```

The first response changed 120 lines across 4 files. The second changed 1 line in 1 file. The goal — fixing the 500 error — is identical.

## Common Mistakes

1. **Goal statements too broad** — "Improve the API" isn't a goal. "Fix the 500 error on /api/orders" is. If the user's request is broad, ask for clarification before starting.

2. **Confusing prerequisites with scope creep** — sometimes the goal requires unexpected work (the fix requires a database migration). That's not scope creep; it's discovering the true scope. Flag the expansion and continue.

3. **Killing useful context** — Goal-Driven doesn't mean ignore everything except the bug. Read surrounding code, understand the system. Just don't modify what you don't need to.

4. **Forgetting follow-up suggestions** — the "noticed but not fixed" list is valuable. Dropping it means useful observations disappear.

## Related Principles

- **Don't Assume** — don't assume the user wants adjacent work done
- **Surgical Changes** — goal-driven work produces surgical diffs
- **Simplicity First** — the simplest path to the goal is usually correct
- [Implement Goal-Driven Execution](/karpathy-goal-driven-implementation-2026/)
- [Goal-Driven Examples](/karpathy-goal-driven-examples-2026/)
- [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/)


## Common Questions

### How do I get started with karpathy goal-driven execution?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Implement Goal-Driven Execution](/karpathy-goal-driven-implementation-2026/)
- [Claude Code Parallel Task Execution](/claude-code-parallel-task-execution-workflow/)
- [Workspace Trust Blocking Execution Fix](/claude-code-workspace-trust-blocking-execution-fix-2026/)
