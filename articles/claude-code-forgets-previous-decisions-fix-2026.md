---
title: "Fix Claude Code Forgetting Decisions (2026)"
description: "Stop Claude Code from contradicting earlier choices in long sessions — add decision logging, session anchors, and Task Master integration."
permalink: /claude-code-forgets-previous-decisions-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Fix Claude Code Forgetting Decisions (2026)

Halfway through a session, Claude Code contradicts a decision it made 10 messages ago. Different error handling pattern, different naming, different approach. Here's the fix.

## The Problem

In long sessions (15+ tool calls), Claude Code:
- Switches architectural patterns mid-implementation
- Uses a different library than it chose earlier
- Names things inconsistently across files
- Forgets constraints established at the session start
- Re-asks questions already answered

## Root Cause

Context window pressure. As the conversation grows, the model's attention on earlier messages weakens. Decisions made at message 3 lose influence by message 30. The model doesn't have persistent memory across the session beyond what's in the conversation.

## The Fix

### 1. Decision Log in CLAUDE.md

```markdown
## Session Decisions (update during session)
Maintain a running list of decisions made during this session:
- [Decision 1: use argon2 for hashing, not bcrypt]
- [Decision 2: Result<T,E> pattern for error handling]
- [Decision 3: routes in /src/api/v2/]

Reference this list before every implementation step.
```

### 2. Use Task Master for Persistence

[Task Master](/claude-task-master-setup-guide-2026/) persists decisions across sessions via its MCP integration. Decisions become task metadata that the agent queries before acting.

### 3. Session Anchors

At the start of a multi-step task:

```markdown
## Task Anchor (paste at start of multi-step work)
Decisions for this task (reference before every step):
- Auth: argon2 + jose (JWT)
- ORM: Drizzle, schemas in src/db/
- API: tRPC procedures in src/server/routers/
- Tests: Vitest, co-located in __tests__/
- Error pattern: Result<T, E> from src/types/result.ts
```

## CLAUDE.md Rule to Add

```markdown
## Decision Consistency
- Before implementing any step, re-read the decisions made earlier in this session
- If you're about to use a different pattern than what was decided, STOP and flag the inconsistency
- When a decision is made, restate it explicitly so it's easy to find in the conversation
- For multi-session work, record decisions in .claude/decisions.md
```

## Verification

Give Claude Code a 5-step task. At step 4, check:
- Does it still use the same patterns as step 1?
- Are naming conventions consistent?
- Is the error handling approach the same?

If inconsistencies appear, add the specific decision to the session anchor.

Related: [Goal-Driven Execution](/karpathy-goal-driven-execution-principle-2026/) | [Task Master Guide](/claude-task-master-setup-guide-2026/) | [Claude Code Best Practices](/claude-code-best-practices-2026/)
