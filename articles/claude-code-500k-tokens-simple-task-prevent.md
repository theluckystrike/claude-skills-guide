---
title: "Claude Code used 500K tokens for a simple task — how to prevent"
description: "Claude Code consuming 500K tokens on a simple task is caused by unbounded exploration and retry loops. These 3 fixes prevent it and cap sessions at 50K tokens."
permalink: /claude-code-500k-tokens-simple-task-prevent/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code used 500K tokens for a simple task -- how to prevent

## The Problem

A task that should take 20,000-50,000 tokens -- fix a typo, add a field, update a config value -- consumed 500,000+ tokens and cost $1.50-$3.00 on Sonnet 4.6 ($3/$15 per MTok). This happens when Claude Code enters an unbounded exploration or retry loop, reading dozens of files, running failing commands repeatedly, or expanding scope beyond the original request.

## Quick Fix (2 Minutes)

1. **Set `--max-turns`** to prevent future runaways:
   ```bash
   claude --max-turns 10 -p "Fix the typo in src/config.ts line 42"
   ```

2. **Scope the prompt to exact files**:
   ```bash
   claude -p "In src/config.ts, change 'databse' to 'database' on line 42"
   ```

3. **Add a CLAUDE.md guard rule**:
   ```markdown
   ## Session Rules
   - For single-file fixes: max 5 tool calls
   - If a fix requires reading more than 3 files, stop and ask for guidance
   ```

## Why This Happens

Three root causes drive token blowout on simple tasks:

**1. Vague prompts trigger exploration.** A prompt like "fix the database bug" causes Claude Code to search the entire codebase for database-related files. Each Glob, Grep, and Read call costs 150-245 tokens plus response content. Reading 20 files at 1,000 tokens each = 20,000 tokens just in file content, before any reasoning or edits.

**2. Retry loops on failing commands.** If Claude Code runs a build command that fails, it reads the error, attempts a fix, re-runs the build, encounters a new error, and repeats. Without a retry bound, this loop can run 10-20 times. Each cycle costs 2,000-5,000 tokens. A 15-cycle retry loop burns 30,000-75,000 tokens.

**3. Scope creep.** Claude Code notices a related issue while working on the original task and starts fixing it. Each new issue triggers its own discovery and fix cycle, compounding token usage.

The context accumulation mechanism makes this worse: every tool call and response stays in the conversation history and is re-sent as input on every subsequent turn. By turn 30, the input alone is 200,000+ tokens.

## The Full Fix

### Step 1: Diagnose

Check the session cost to confirm the blowout:

```bash
# At the end of the session, note the /cost output
# "Total cost: $2.47 | Tokens: 512,340"

# Or use ccusage to review historical sessions
npm install -g ccusage
ccusage --sort cost --limit 5
```

Look for sessions with unusually high token counts or tool call counts. Anything over 30 tool calls on a "simple" task indicates exploration or retry loops.

### Step 2: Fix

Apply three defenses:

```bash
# Defense 1: --max-turns for hard cost caps
alias cfix='claude --max-turns 10'

# Defense 2: Scoped prompts (always specify files)
cfix -p "In src/config.ts, line 42: change 'databse' to 'database'"

# Defense 3: Restricted tools for simple edits
alias cedit='claude --max-turns 8 --allowedTools "Read,Edit,Bash"'
cedit -p "Fix the typo in src/config.ts"
```

### Step 3: Prevent

Add permanent prevention rules to CLAUDE.md:

```markdown
# CLAUDE.md -- Cost Prevention Rules

## Task Scoping
- For single-file edits: read only the target file, max 5 tool calls total
- For bug fixes: read the failing test + implementation file, max 10 tool calls
- Never read more than 5 files for a task unless explicitly asked to explore

## Retry Limits
- If a command fails twice with the same error, stop and report the error
- Maximum 3 fix-attempt cycles per task
- If tests fail after 3 fix attempts, stop and report what was tried

## Scope Control
- Fix ONLY what was asked. Do not fix adjacent issues.
- If a related issue is noticed, mention it in the response but do not fix it
```

## Common Patterns That Cause Blowouts

Understanding the specific patterns helps prevent them:

**Pattern 1: The "Fix Everything" Prompt**

```bash
# This prompt triggers full-codebase exploration
claude -p "Fix all the TypeScript errors in the project"
# Claude runs: npx tsc --noEmit (finds 47 errors across 23 files)
# Then reads all 23 files, fixes errors one by one, re-runs tsc after each fix
# Each cycle: ~5,000 tokens. 47 errors: ~235,000 tokens.
# Better approach:
claude --max-turns 10 -p "Fix the TypeScript error in src/api/routes/users.ts on line 42"
```

**Pattern 2: The Build-Fix Loop**

```bash
# Claude fixes one error, triggers a new error, fixes that, triggers another...
# This cascade happens when fixes introduce new type errors or test failures
# Each build-fix cycle: 3,000-8,000 tokens
# 10 cycles: 30,000-80,000 tokens

# Prevention: add to CLAUDE.md
# "After making a fix, run npx tsc --noEmit. If new errors appear that were
#  not in the original error set, stop and report them. Do not attempt to fix
#  cascading errors automatically."
```

**Pattern 3: The Documentation Deep-Dive**

```bash
# Claude reads README, CONTRIBUTING, CHANGELOG, multiple docs files
# to understand the project before making a simple change
# Each file: 150 tokens overhead + 500-3,000 tokens content
# 8 doc files: ~15,000 tokens of context that is irrelevant to a config change

# Prevention: scope the prompt
claude -p "In .env.example, add DATABASE_POOL_SIZE=20 after the DATABASE_URL line"
```

## Cost Recovery

The tokens are already spent and cannot be recovered. Future prevention is the only remedy. To minimize the financial impact:

- **Switch to `--max-turns`** for all sessions going forward. A 10-turn cap on simple tasks limits worst-case cost to ~$0.30 on Sonnet 4.6 (vs. $3.00 unbounded).
- **Use Haiku 4.5** for simple tasks: same 500K tokens would cost $0.40 instead of $3.00 on Haiku ($0.80/$4 per MTok).
- **Review sessions weekly** with `ccusage` to catch patterns before they accumulate.

Estimated savings from prevention: $20-$60/month for a developer who previously experienced 2-3 blowout sessions per week.

### Creating a Personal Cost Dashboard

Track session costs to detect blowouts early:

```bash
# Add to ~/.zshrc -- print cost reminder after each Claude session
claude-tracked() {
  echo "Starting Claude Code session (tracked)..."
  echo "Remember: check /cost before ending the session"
  command claude "$@"
  echo ""
  echo "Session ended. Review cost with: ccusage --sort cost --limit 5"
}
alias ct='claude-tracked'
```

This wrapper reminds developers to check costs, creating awareness that prevents "set it and forget it" sessions from spiraling. The reminder costs zero tokens -- it runs before and after the Claude Code process.

## Prevention Rules for CLAUDE.md

Copy and paste this block into the project CLAUDE.md:

```markdown
## Cost Guard Rails
- Max tool calls for simple edits: 5
- Max tool calls for bug fixes: 15
- Max retry cycles for any failing command: 3
- Always read target files before editing (never edit blind)
- Never explore beyond the specified scope without explicit permission
- If a task seems to require more than 20 tool calls, stop and report the complexity
```

### Quick Reference: Expected Token Costs by Task

Use this table to detect blowout sessions. If a simple task exceeds 3x the expected cost, something went wrong:

| Task Type | Expected Tokens | Expected Cost (Sonnet 4.6) | Blowout Threshold |
|-----------|----------------|---------------------------|-------------------|
| Add env variable | 5,000-10,000 | $0.03-$0.06 | >30,000 |
| Fix typo | 3,000-8,000 | $0.02-$0.05 | >25,000 |
| Add import statement | 5,000-12,000 | $0.03-$0.07 | >35,000 |
| Rename variable | 8,000-20,000 | $0.05-$0.12 | >60,000 |
| Simple bug fix | 15,000-40,000 | $0.09-$0.24 | >120,000 |

Any session exceeding the blowout threshold deserves investigation. The most common causes are missing `.claudeignore` (leading to accidental large-file reads), vague prompts (triggering broad codebase exploration), and missing `--max-turns` (allowing unbounded execution).

## Related Guides

- [Claude Code --max-turns Flag: Prevent Runaway Sessions](/claude-code-max-turns-flag-prevent-runaway-sessions/) -- hard caps on session length
- [Claude Code Context Window Management](/claude-code-context-window-management/) -- prevent context accumulation
- [Cost Optimization Hub](/cost-optimization/) -- comprehensive cost reduction
