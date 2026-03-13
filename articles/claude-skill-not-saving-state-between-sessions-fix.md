---
layout: post
title: "Claude Skill Not Saving State Between Sessions Fix"
description: "Why Claude skills lose context between sessions and how to fix it. Covers supermemory, external files, and CLAUDE.md for persistent project state."
date: 2026-03-13
categories: [guides, tutorials]
tags: [claude-code, claude-skills, troubleshooting, state-management]
author: "Claude Skills Guide"
reviewed: true
score: 5
---

# Claude Skill Not Saving State Between Sessions Fix

Claude skills are `.md` files — they contain instructions, not running code with variables or caches. When a conversation ends, all context accumulated during that session is gone. There is no built-in state container inside a skill. This is by design: each session starts fresh from the skill's `.md` definition.

If you need information to persist across sessions, you need an external store that Claude can read from and write to. This guide covers the practical approaches.

## Why Skills Lose State

A skill like `/tdd`, `/pdf`, or `/frontend-design` is a plain `.md` file stored in `~/.claude/skills/`. When you invoke it with `/skill-name`, its contents are loaded into the current conversation as instructions for Claude. When the session ends, those instructions and all context derived from them are gone.

This works fine for stateless operations — generating a document, writing tests for a specific function, producing a design component. It breaks down when you want Claude to remember decisions, accumulated knowledge, or work-in-progress state across sessions.

## The Right Approach: External Persistent Storage

Since skills cannot hold state internally, the fix is to use an external file or store that Claude can read at the start of a session and update during it.

### Option 1: Use the `/supermemory` Skill

The `/supermemory` skill is designed for cross-session persistence. It maintains a local notes file and lets you store and retrieve information by instructing Claude:

```
/supermemory
Store: auth module uses JWT with 15-minute access tokens.
Refresh token logic is in src/auth/refresh.ts.
We decided not to use sessions because of horizontal scaling.
```

To retrieve it in a later session:

```
/supermemory
What do we know about the auth module?
```

The skill reads from and writes to a local store. Your notes accumulate across sessions, so returning to a project after weeks does not require re-explaining the architecture.

### Option 2: Maintain a `CLAUDE.md` Project File

For team projects or complex workflows, a `CLAUDE.md` file in your project root is a straightforward persistent context mechanism. Claude Code reads this file automatically when present. Document the information you want available at the start of every session:

```markdown
# Project Context

## Architecture
- Frontend: React with TypeScript in /apps/web
- API: Fastify in /apps/api
- Shared UI: /packages/ui

## Active Decisions
- JWT auth, access tokens 15 min, refresh 30 days
- Tests use Vitest, not Jest — do not suggest Jest

## Current Work in Progress
- PR #142: Add OAuth provider support (branch: feature/oauth)
- Known issue: refresh token race condition under investigation
```

Any skill invoked during a session will have access to this context because it is loaded at session start.

### Option 3: Instruct Claude to Write Output Files

For skills that produce accumulated results — a running test log, a design decision record — instruct Claude explicitly to write the output to a file at the end of each session:

```
/tdd
We're writing tests for the payment module. At the end of
our session, append a summary of tests written to
docs/test-progress.md.
```

In the next session:

```
/tdd
Read docs/test-progress.md to see where we left off,
then continue with the refund processing tests.
```

The file is the state. Claude reads it to restore context and writes to it to update progress.

## Choosing the Right Approach

| Scenario | Recommended approach |
|----------|---------------------|
| Personal project, long-term context | `/supermemory` skill |
| Team project, shared context | `CLAUDE.md` in project root |
| Task-specific progress tracking | Instruct Claude to write/read a file |
| Architecture decisions that every skill should know | `CLAUDE.md` |

## Common Pitfalls

**Not updating the persistent store during the session.** If you rely on `/supermemory` or a notes file but forget to instruct Claude to save new decisions before closing, that context is lost. Build the habit of ending sessions with an explicit save step.

**Expecting skills to remember automatically.** Skills do not watch for state to save. You must explicitly instruct Claude to write to a file or use `/supermemory`. The skill's `.md` file is read-only instructions — it does not accumulate state on its own.

**Using volatile session variables instead of files.** Anything Claude "knows" because you told it earlier in the same conversation is lost when that conversation ends. Only information written to the filesystem (or another external store) survives.

## Summary

Claude skills are stateless by design — they are `.md` instruction files, not running processes with memory. To persist state between sessions, use `/supermemory` for conversational notes, `CLAUDE.md` for project-level context, or instruct Claude to write progress to files that later sessions can read back.

---

## Related Reading

- [Skill MD File Format Explained With Examples](/claude-skills-guide/articles/skill-md-file-format-explained-with-examples/) — Complete skill.md format reference
- [How to Write a Skill MD File for Claude Code](/claude-skills-guide/articles/how-to-write-a-skill-md-file-for-claude-code/) — Step-by-step skill creation guide
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/articles/claude-skills-auto-invocation-how-it-works/) — How skills activate automatically
