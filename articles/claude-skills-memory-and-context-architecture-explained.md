---
layout: post
<<<<<<< Updated upstream
title: "Claude Skills Memory and Context Architecture Explained"
description: "How Claude skills manage context and memory across turns and sessions: context_files injection, the supermemory skill, and stateful session design."
=======
title: "Claude Skills Memory and Context Architecture"
description: "How Claude skills manage context and memory across turns and sessions: context window, CLAUDE.md, supermemory skill, and file-based state patterns."
>>>>>>> Stashed changes
date: 2026-03-13
categories: [advanced, guides]
tags: [claude-code, claude-skills, memory, context, supermemory, state-management]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Claude Skills Memory and Context Architecture Explained

One of the most misunderstood aspects of Claude Code skills is how memory and context actually work. Many developers expect skills to "remember" things the way a human colleague would — across sessions, across projects, without any setup. The reality is more precise and more controllable than that.

## The Context Window: Your Skill's Working Memory

Every Claude skill operates within a context window. The context window holds everything Claude can "see" at any given moment:

- The skill's system prompt (the skill body from the `.md` file)
- The conversation history for the current session
- Tool outputs from the current session
- The user's current message

When the context window fills up, older conversation history is dropped. Tool outputs are typically more aggressively truncated than conversation text.

A key point: **skills do not share context windows**. If you switch from your `tdd` skill to your `frontend-design` skill mid-session, the new skill starts with only the shared conversation history — it does not inherit the previous skill's context or tool outputs.

## CLAUDE.md: Project-Level Context

Claude Code loads a `CLAUDE.md` file from the project root (if it exists) into every session's context window automatically. This is not skill-specific — it is available to all skills and to Claude in its default mode.

Use `CLAUDE.md` for project-wide context that every skill needs:

```markdown
# Project Context

This is a Next.js 15 app using TypeScript, Tailwind CSS, and PostgreSQL via Prisma.
We use pnpm as the package manager.
All API routes are in src/app/api/. All components are in src/components/.
Tests use Jest + React Testing Library. Run tests with pnpm test.
```

With a well-written `CLAUDE.md`, you can write leaner skill bodies that do not repeat project basics.

## Session Memory: Within a Single Session

Within a single Claude Code session, memory is implicit — it is the conversation history. Claude remembers what you said earlier in the session because that history is in the context window.

This is stateful within a session but ephemeral across sessions. When you close Claude Code and reopen it, that conversation history is gone.

Skills can leverage within-session memory naturally:

```
User: "Remember that we're using PostgreSQL for this project."
Claude: [tdd skill active] "Got it. When writing integration tests, I'll use pg-specific patterns."
...
User: "Now write tests for the user authentication flow."
Claude: [still in tdd skill, with PostgreSQL context still in window] Writes pg-aware tests.
```

## The /supermemory Skill: Cross-Session Persistence

The `/supermemory` skill solves the cross-session memory problem. It maintains a storage layer that persists between sessions.

To store something important, invoke the skill explicitly:

```
/supermemory
Store this project context:
This project uses msw for API mocking in tests. All component tests use
@testing-library/user-event for interaction simulation. Run tests with pnpm test.
```

To retrieve it in a future session:

```
/supermemory
Retrieve stored context and conventions for this project.
```

The supermemory skill operates as a regular skill invoked via the `/supermemory` slash command. It does not run as an automatic pre-hook, and it does not inject context without being asked.

## File-Based State: Deterministic Injection

The most reliable approach for giving skills access to project-specific context is writing it to files and including those files in the skill's system prompt body. Reference specific files the skill should read:

```markdown
---
name: frontend-design
description: Builds React components with Tailwind CSS
---

At the start of every invocation, read these files to understand the current
design system:
- docs/design-tokens.md
- src/components/Button.tsx (as a component reference)
- src/styles/globals.css

Then respond to the user's component request using the established patterns.
```

This approach is transparent (the files are on disk and inspectable), version-controllable, and completely predictable. If you update `design-tokens.md`, the next invocation of the skill will see the updated version.

## Context Architecture for Multi-Skill Workflows

When you have multiple skills that hand off to each other, context continuity matters. Use a shared context directory that each skill is instructed to read:

```
.claude/
  context/
    current-sprint.md     # Written by your planning skill
    architecture.md       # Written by your design skill
    test-patterns.md      # Written by your tdd skill
```

Reference these in multiple skills' system prompt bodies:

```markdown
---
name: tdd
---

Before generating tests, read .claude/context/test-patterns.md for established
testing conventions in this project, and .claude/context/current-sprint.md
for current sprint context.
```

This creates a lightweight shared memory layer that is just files — inspectable, version-controllable, and not dependent on any external service.

## What Skills Cannot Remember

Understanding the limits of the memory architecture prevents design mistakes:

**Skills cannot remember across sessions without supermemory**: The conversation history is ephemeral. If you tell Claude something important, either save it to a file, use the `/supermemory` skill, or put it in `CLAUDE.md`.

**Skills cannot share context within a session without it being in the conversation history**: If skill A learns something and you switch to skill B, skill B cannot access skill A's prior context files.

**Large context reduces available conversation space**: Every byte of file content Claude reads is a byte not available for conversation history. Keep injected context focused and concise.

---

## Related Reading

- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) - The memory architecture described here directly affects token consumption
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) - Covers supermemory and context-aware skills in practical terms
- [Building Stateful Agents with Claude Skills](/claude-skills-guide/articles/building-stateful-agents-with-claude-skills-guide/) - File-based state patterns in depth

Built by theluckystrike - More at [zovo.one](https://zovo.one)
