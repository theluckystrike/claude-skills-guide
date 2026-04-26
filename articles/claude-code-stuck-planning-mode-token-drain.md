---
layout: default
title: "Claude Code stuck in planning mode (2026)"
description: "Fix Claude Code stuck in planning mode that drains 30K-100K tokens on analysis without action, using action-first prompts and CLAUDE.md execution rules."
permalink: /claude-code-stuck-planning-mode-token-drain/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Claude Code stuck in planning mode -- token drain prevention

## The Problem

Claude Code sometimes enters "planning mode" where it reads files, analyzes code, and produces detailed plans without making any actual changes. A planning-mode session can consume 30K-100K tokens ($0.09-$0.30 Sonnet, $0.45-$1.50 Opus) generating multi-paragraph analyses that the developer did not ask for. The token cost is entirely wasted if the developer just wanted the change made, not a dissertation on the change.

## Quick Fix (2 Minutes)

Add an action-first rule to CLAUDE.md:

```markdown
# CLAUDE.md

## Execution Rule
- Make changes directly. Do NOT describe what you plan to do unless asked.
- Act first, explain after (if needed).
- Skip preambles like "I'll analyze the code..." or "Let me review..."
- For simple tasks (bug fix, add feature, edit config): make the change immediately.
- Only plan explicitly when the task involves 5+ files or architectural decisions.
```

For immediate effect in the current session:

```bash
"Stop planning. Make the change now. Edit the file directly."
```

## Why This Happens

Planning mode is triggered by three patterns:

1. **Ambiguous prompts:** "Look at the auth module and improve it" gives no clear action target. Claude defaults to analysis.

2. **Complex task perception:** Claude reads many files and concludes the task is complex, triggering a "plan before act" behavior even when the actual change is small.

3. **Missing execution context:** Without CLAUDE.md rules, Claude defaults to a conservative approach: analyze first, then propose, then wait for approval, then act. Each step costs tokens.

The token breakdown of a planning-mode loop:
- File reads for analysis: 20K-50K tokens
- Plan generation (multi-paragraph): 3K-8K tokens (output)
- User says "go ahead": 100 tokens
- Claude re-reads the files it already read: 20K-50K tokens (context has been polluted with plan text)
- Actual implementation: 10K-20K tokens

Total: 53K-128K tokens. Without planning mode, just the implementation: 30K-70K tokens. **Planning mode adds 77-83% overhead.**

## The Full Fix

### Step 1: Diagnose

Identify if Claude is in planning mode:

```bash
# Signs of planning mode:
# - Response starts with "I'll start by reviewing..." or "Let me analyze..."
# - Response contains numbered steps but no actual file edits
# - Response ends with "Shall I proceed?" or "Would you like me to implement this?"
# - /cost shows high input tokens but no Edit tool calls in the response
```

### Step 2: Fix

**Write action-oriented prompts:**

```bash
# BAD: triggers planning mode
claude "Look at the authentication flow and see if there are any issues"

# GOOD: triggers immediate action
claude "Fix the expired token check in src/auth/validate.ts.
The check on line 34 compares exp with Date.now() but exp is in seconds
and Date.now() returns milliseconds. Divide Date.now() by 1000."
```

```bash
# BAD: vague scope
claude "Improve the error handling in the API"

# GOOD: specific target
claude "Add try-catch to the createUser function in src/services/user.ts.
Catch Prisma errors and return { error: { code: 'DB_ERROR', message: e.message } }"
```

**Configure CLAUDE.md to bias toward action:**

```markdown
# CLAUDE.md

## Execution Protocol
### For tasks under 3 files:
- Execute immediately, no planning phase
- Make the change, run the test, report the result

### For tasks involving 3-5 files:
- State the plan in 3 bullet points maximum (not paragraphs)
- Then execute immediately

### For tasks involving 5+ files:
- Provide a brief plan (5 bullets max)
- Wait for approval before proceeding

### NEVER
- Write multi-paragraph analysis before making changes
- Ask "shall I proceed?" for simple tasks
- Describe what tools you will use (just use them)
- Restate the task back to the developer
```

### Step 3: Prevent

```markdown
# CLAUDE.md -- anti-planning-mode rules

## Response Rules
- First response MUST contain at least one tool call (Read, Edit, Bash)
- Do not start responses with "I'll" or "Let me" or "Here's my plan"
- If the task is clear, the first tool call should be Edit or Bash
- Plans must be under 100 words (approximately 130 tokens)
```

## Cost Recovery

When Claude is stuck in planning mode mid-session:

```bash
# Interrupt the plan
"Stop. Do not explain. Make the change now. Edit src/auth/validate.ts line 34."

# If context is bloated from planning text
/compact

# Resume with action bias
"Now make the change. No planning."
```

## Prevention Rules for CLAUDE.md

```markdown
## Action-First Protocol
- Simple tasks (1-2 files): act immediately, no planning
- Medium tasks (3-4 files): 3-bullet plan, then act
- Complex tasks (5+ files): 5-bullet plan, wait for go-ahead
- Plans must be under 100 words
- First response must include at least one tool call
- Never ask "shall I proceed?" for tasks clearly requesting a change
- Never restate or paraphrase the task before starting work
```

Expected savings: eliminating planning mode overhead saves 23K-58K tokens per incident. At 3-5 planning-mode incidents per week on Sonnet: **$1.14-$2.87/week or $5-$13/month.** The bigger win is time saved -- planning mode adds 2-5 minutes of unnecessary waiting per incident.

## Planning Mode vs Appropriate Planning

Not all planning is wasteful. The distinction:

### Wasteful Planning (Token Drain)

- Multi-paragraph analysis of a simple bug fix
- Restating the task back to the developer
- Listing tools that will be used ("I'll use the Read tool to...")
- Asking "shall I proceed?" for clearly actionable tasks
- Describing the project architecture before making a one-line change

### Appropriate Planning (Value-Add)

- A 3-bullet plan before a 5+ file refactoring
- Identifying potential risks before a destructive operation
- Proposing two approaches and asking which to take
- Flagging that a task is more complex than it appears

The CLAUDE.md rules should discourage the first category while allowing the second:

```markdown
# CLAUDE.md

## Planning Rules
### Skip Planning For (execute immediately)
- Tasks mentioning specific files
- Tasks with clear instructions ("change X to Y")
- Tasks with fewer than 3 target files
- Follow-up tasks ("now do the same for...")

### Brief Plan Required For (3 bullets max, then execute)
- Tasks involving 3-5 files
- Tasks that could be interpreted multiple ways
- Refactoring tasks without specific targets

### Full Plan Required For (5 bullets, wait for approval)
- Architecture changes
- Tasks involving 5+ files
- Destructive operations (delete, migrate, reset)
- Changes to shared interfaces used by many files
```

## Prompt Patterns That Prevent Planning Mode

These prompt structures consistently trigger immediate action:

```bash
# Pattern 1: Direct instruction
"Edit src/auth/validate.ts line 34: change Date.now() to Math.floor(Date.now()/1000)"

# Pattern 2: Copy-this-pattern
"Add a DELETE endpoint to src/routes/users.ts following the same pattern as the DELETE in src/routes/posts.ts"

# Pattern 3: Specific scope + action
"In src/services/user.ts, add try-catch around the Prisma call in createUser(). Return {error: {code: 'DB_ERROR', message: e.message}} on failure."

# Pattern 4: File-first
"Read src/auth/middleware.ts and fix the token expiration check. The exp field is in seconds but we're comparing to milliseconds."
```

Each pattern gives Claude a clear target and action, eliminating the uncertainty that triggers planning mode.

## Measuring Planning Mode Waste

```bash
# Indicator: tokens consumed before first Edit/Write tool call
# in a session where the task is clearly actionable

# Before CLAUDE.md anti-planning rules:
# First Edit at: turn 4, ~35K input tokens
# Most tokens spent on: Read (orientation), planning text

# After CLAUDE.md anti-planning rules:
# First Edit at: turn 2, ~8K input tokens
# Savings: 27K tokens per task = $0.08 Sonnet

# Monthly impact (10 planning-mode-prone tasks/week):
# 27K x 10 x 4 = 1.08M tokens = $3.24/month Sonnet
```



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [How to Stop Claude Code Retry Loops](/stop-claude-code-retry-loops-token-waste/) -- another common token drain pattern
- [CLAUDE.md Token Optimization](/claude-md-token-optimization-rules-save-money/) -- configuring Claude's behavior
- [Cost Optimization Hub](/cost-optimization/) -- all optimization techniques
