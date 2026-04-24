---
title: "Debug When Claude Code Assumes Wrong (2026)"
description: "Diagnose and fix Claude Code assumption failures — identify root causes, add targeted CLAUDE.md rules, and prevent repeat mistakes."
permalink: /karpathy-dont-assume-debugging-failures-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Debug When Claude Code Assumes Wrong (2026)

Claude Code assumed wrong, and now you're staring at generated code that doesn't fit your project. This article walks through diagnosing why it assumed, fixing the immediate damage, and adding rules that prevent the same mistake.

## The Problem

Claude Code generated code based on a wrong assumption. Symptoms:

- Wrong library or framework used
- Code placed in the wrong directory
- Implementation pattern doesn't match the codebase
- Features added that weren't requested
- Configuration changed in ways that break other things

## Root Cause

Assumption failures come from three sources:

**1. Missing context** — Claude Code didn't read enough of the codebase to know the right pattern. It defaulted to its training distribution (most common approach).

**2. Ambiguous instructions** — your request had multiple valid interpretations. Claude Code picked one without asking.

**3. Weak CLAUDE.md rules** — your behavioral rules either don't exist or are too vague to prevent the specific assumption.

## The Fix

### Step 1: Identify What It Assumed

Look at the generated code and list every decision Claude Code made without asking:

```
- Used Prisma (project uses Drizzle)
- Created a REST endpoint (project is migrating to tRPC)
- Put the file in /lib/ (existing pattern is /services/)
- Added error handling with try/catch (project uses Result types)
```

### Step 2: Determine the Root Cause

For each assumption, ask:

- Could Claude Code have found the answer by reading the codebase? If yes → missing context
- Was my request ambiguous about this decision? If yes → ambiguous instructions
- Does my CLAUDE.md address this? If no → weak rules

### Step 3: Fix the Immediate Issue

Tell Claude Code to undo and redo with explicit instructions:

```
That implementation used Prisma, but this project uses Drizzle ORM.
Please revert the changes and re-implement using Drizzle, following
the pattern in src/db/schema.ts and src/services/user-service.ts.
```

### Step 4: Add a CLAUDE.md Rule

For each assumption that reached your code, add a targeted rule:

```markdown
## Assumption Prevention
- ORM: Drizzle only. See src/db/schema.ts for patterns.
- API style: tRPC procedures in src/server/routers/. No REST endpoints.
- File placement: services go in src/services/, not src/lib/.
- Error handling: use Result<T, E> pattern from src/types/result.ts. No try/catch for business logic.
```

### Step 5: Verify the Rule Works

Give Claude Code the same or similar task and check whether it follows the new rule or asks for clarification.

## CLAUDE.md Rule to Add

For persistent assumption problems, add a meta-rule:

```markdown
## Assumption Recovery Protocol
When you realize you've made an assumption that might be wrong:
1. STOP immediately — don't continue building on a wrong foundation
2. State the assumption explicitly
3. Ask for confirmation before proceeding
4. If the assumption was wrong, revert and restart from the correct premise
```

## Verification

After adding rules, test with these prompts:

```
# Test 1: Ambiguous task
"Add caching to the database queries"
→ Should ask: which cache (Redis, in-memory?), which queries, what TTL

# Test 2: Technology choice
"Add form validation to the signup page"
→ Should use existing validation library, not install a new one

# Test 3: Scope boundary
"Fix the login error message"
→ Should fix only the error message, not refactor the form
```

If Claude Code still assumes, strengthen the rules with more specific examples or add the exact scenario to your CLAUDE.md as a "DO NOT" item.

## Common Mistakes

1. **Blaming the model instead of the rules** — Claude Code follows instructions. If it assumes wrong repeatedly, the CLAUDE.md rules need improvement.

2. **Adding too many rules at once** — fix the specific assumption that failed, not every possible assumption. Over-constraining produces a different problem (Claude Code asks about everything).

3. **Not including positive examples** — "Don't use Prisma" is weaker than "Use Drizzle ORM following the pattern in src/db/schema.ts." Point to the right answer, not just away from the wrong one.

4. **Forgetting to test the fix** — adding a rule without verifying it works means you'll hit the same problem next session.

## Related Principles

- [Don't Assume Principle](/karpathy-dont-assume-principle-claude-code-2026/) — the underlying principle
- [Implement Don't Assume in CLAUDE.md](/karpathy-dont-assume-implementation-claude-md-2026/) — template rules
- [Fix Claude Code Ignoring Project Context](/claude-code-ignores-project-context-fix-2026/) — a related problem
- [CLAUDE.md Best Practices](/claude-md-best-practices-10-templates-compared-2026/) — structuring effective rules
