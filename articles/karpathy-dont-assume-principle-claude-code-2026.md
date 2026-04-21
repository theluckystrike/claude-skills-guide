---
title: "Karpathy Don't Assume Principle for Claude Code (2026)"
description: "Apply Karpathy's Don't Assume principle to stop Claude Code from making silent decisions about your architecture, dependencies, and implementation."
permalink: /karpathy-dont-assume-principle-claude-code-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Karpathy Don't Assume Principle for Claude Code (2026)

The "Don't Assume" principle is the first and most impactful rule from Andrej Karpathy's behavioral guidelines for Claude Code. It addresses the root cause of most AI coding frustrations: the agent silently makes decisions that should be yours.

## The Principle

**Don't Assume.** When Claude Code encounters ambiguity in a task, it should ask for clarification rather than picking an interpretation and running with it. This applies to:

- Technology choices (which library, which framework, which pattern)
- Architectural decisions (where to put code, how to structure modules)
- Implementation details (error handling strategy, validation approach)
- Scope boundaries (what's in scope, what's not)

The principle doesn't mean Claude Code should ask about everything. Well-established patterns in the codebase are not assumptions — they're observations. If every route uses Zod validation, adding Zod to a new route isn't an assumption; skipping it would be.

## Why It Matters

Claude Code defaults to confident action. Given "add authentication," it will pick JWT, choose bcrypt, create middleware, add refresh tokens, and write 400 lines of code — all before you can react. If its choices don't match your architecture, you've burned tokens and time on code you'll delete.

The Don't Assume principle front-loads clarification. One round-trip of questions costs far less than generating and reverting a wrong implementation.

Common assumption failures:

- Picking React when the project uses Vue
- Adding a PostgreSQL migration when the project uses MongoDB
- Creating REST endpoints when the API is GraphQL
- Using Jest when the test runner is Vitest
- Implementing pagination when the dataset is always small

## CLAUDE.md Implementation

Add these rules to your project's CLAUDE.md:

```markdown
## Don't Assume (Karpathy Principle)

### Hard Rules
- NEVER choose a library, framework, or tool not already in package.json/requirements.txt without asking
- NEVER create a new file pattern (new directory, new naming convention) without confirming it matches the project structure
- NEVER pick an error handling strategy that differs from existing code without discussion
- NEVER add features beyond what was explicitly requested

### Soft Rules
- When the task has 2+ valid implementation approaches, present options with tradeoffs before coding
- When requirements are ambiguous, list your assumptions and ask for confirmation
- When you're unsure about scope, state what you think is in/out and ask

### Exceptions
- If the codebase already has a clear pattern for the type of change requested, follow it without asking
- Trivial decisions (variable names, comment wording) don't need confirmation
```

## Before/After Examples

### Before (Without Don't Assume)

```
User: Add a cache layer to the API

Claude Code: I'll add Redis caching with a 5-minute TTL to all GET
endpoints. Installing ioredis, creating a CacheService class...
*writes 200 lines across 4 files*
```

### After (With Don't Assume)

```
User: Add a cache layer to the API

Claude Code: Before implementing caching, I need to confirm:

1. Cache backend — Redis, Memcached, or in-memory (node-cache)?
   Your project doesn't currently use any cache.
2. Which endpoints need caching? All GETs, or specific expensive ones?
3. TTL strategy — same TTL for everything, or per-endpoint?
4. Cache invalidation — on write operations, time-based only, or manual?

I see you're on a single-server deployment (from docker-compose.yml),
so in-memory caching is viable if you don't need distributed cache.
```

### Before (Scope Creep)

```
User: Fix the login error message

Claude Code: Fixed the error message. I also noticed the login form
didn't have loading states, so I added a spinner. And the password
field didn't have a show/hide toggle, so I added that too. I also
refactored the form to use react-hook-form for better validation.
*touches 8 files*
```

### After (Scoped)

```
User: Fix the login error message

Claude Code: I found the issue — the error message says "Error"
instead of the specific validation failure. I'll update the error
display in LoginForm.tsx to show the API's error message.

I noticed the form could also benefit from loading states and
better validation, but those are separate changes. Want me to
address those after fixing the error message?
```

## Common Mistakes

1. **Over-applying the principle** — asking about trivial decisions ("Should this variable be named `user` or `currentUser`?") wastes time. Reserve questions for decisions with real consequences.

2. **Listing assumptions without asking** — "I'm assuming X, Y, Z" followed by implementing all of them defeats the purpose. List assumptions AND wait for confirmation.

3. **Asking once, then assuming forever** — the principle applies per-task, not per-session. A new task may have different constraints even in the same project.

4. **Ignoring codebase evidence** — if the project already uses a specific pattern, following it isn't assuming. The principle targets decisions where no pattern exists.

## Related Principles

- **Surface Tradeoffs** — when Don't Assume triggers a question, present tradeoffs with each option
- **Goal-Driven Execution** — staying focused on the stated goal prevents scope-creep assumptions
- **Simplicity First** — the simplest valid interpretation of a task is less likely to involve wrong assumptions
- [Full Karpathy Skills Guide](/karpathy-claude-code-skills-complete-guide-2026/)
- [Implement Don't Assume in CLAUDE.md](/karpathy-dont-assume-implementation-claude-md-2026/)
- [CLAUDE.md Best Practices](/claude-md-file-best-practices-guide/)
