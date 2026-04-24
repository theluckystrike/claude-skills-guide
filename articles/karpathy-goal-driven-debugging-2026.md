---
title: "Fix Claude Code Losing Track of Goals (2026)"
description: "Diagnose and fix Claude Code goal drift — add CLAUDE.md checkpoints, scope declarations, and completion signals to keep sessions on track."
permalink: /karpathy-goal-driven-debugging-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Fix Claude Code Losing Track of Goals (2026)

Claude Code started working on your feature, then drifted into refactoring, then started optimizing, and now you're not sure what it's actually building. Here's how to diagnose and fix goal drift.

## The Problem

Symptoms of goal drift:
- Claude Code modifies files unrelated to the original request
- The session feels longer than the task warrants
- You can't tell from the output whether the original goal is done
- Follow-up responses reference work you didn't ask for
- The diff is 10x larger than expected

## Root Cause

Goal drift has three triggers:

**1. Long context** — after 15+ tool calls, the original request is thousands of tokens back in the conversation. The model's attention on it weakens.

**2. Discovery during work** — Claude Code finds related issues while investigating the original goal. Without constraints, it starts fixing them.

**3. Vague goals** — "improve the auth system" has no clear completion point. Claude Code keeps working until context is exhausted.

## The Fix

### Step 1: Make Goals Explicit

Rephrase vague requests before starting:

**Vague:** "Work on the payment system"
**Explicit:** "Fix the double-charge bug on the /api/checkout endpoint. The bug: when a user clicks 'Pay' twice rapidly, two Stripe charges are created."

### Step 2: Add Checkpoint Rules

```markdown
## Goal Checkpoints
After every 5 tool calls, state:
- **Current goal:** [restate from the start of the task]
- **Progress:** [what's done so far]
- **Remaining:** [what's left]
- **On track:** yes/no

If "no," explain what caused drift and how to return to the goal.
```

### Step 3: Add Completion Signals

```markdown
## Task Completion
When the goal is met:
1. Say "Goal complete" explicitly
2. List all changed files
3. Do NOT continue working unless asked

If you believe additional work is needed, list it as suggestions AFTER
the "Goal complete" statement. Wait for confirmation before starting.
```

### Step 4: Break Large Tasks

If a task takes more than 15-20 tool calls, it's too big for a single goal:

```
User: Rewrite the entire authentication system

Better:
User: Let's rewrite the auth system in phases.
Phase 1: Replace the password hashing from bcrypt to argon2.
Start with Phase 1 only.
```

## CLAUDE.md Rule to Add

```markdown
## Anti-Drift Protocol
- Restate the goal before starting every task
- After every 5 tool calls, verify you're still working toward the stated goal
- When the goal is complete, say "Goal complete" and stop
- Suggest follow-up work in a separate list, don't start it
- If a task requires more than 20 tool calls, suggest breaking it into phases
```

## Verification

Test with a task that typically triggers drift:

```
Fix the date formatting bug in the reports page — dates show
as "Invalid Date" when the timezone is UTC.
```

**Drifted output** (bad):
- Fixes date formatting
- Refactors the date utility library
- Adds timezone detection
- Updates all components to use the new utility
- Changes 8 files, 150 lines

**Goal-driven output** (good):
- Fixes date formatting in the reports page
- 1-3 lines changed
- States "Goal complete"
- Lists observed date issues in other pages as "noticed but not fixed"

## Common Mistakes

1. **Checkpoints that are too frequent** — checking after every single tool call is noise. Every 5 calls balances awareness with flow.

2. **Not breaking down long tasks** — goal drift is nearly guaranteed in 30+ tool call sessions. Break tasks proactively.

3. **Accepting drifted work** — if you use drifted output without pushback, the behavior reinforces. Send it back with "only do what I asked."

4. **Blaming the model for vague instructions** — "make it better" isn't a debuggable goal. Clear goals are your responsibility.

## Related Principles

- [Goal-Driven Execution Principle](/karpathy-goal-driven-execution-principle-2026/) — the underlying principle
- [Implement Goal-Driven Execution](/karpathy-goal-driven-implementation-2026/) — CLAUDE.md templates
- [Fix Claude Code Forgetting Decisions](/claude-code-forgets-previous-decisions-fix-2026/) — related problem
- [The Claude Code Playbook](/playbook/) — session management patterns
