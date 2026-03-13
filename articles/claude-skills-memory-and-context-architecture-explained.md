---
layout: default
title: "Claude Skills Memory and Context Architecture Explained"
description: "How Claude skills manage context and memory across turns and sessions — covering context_files injection, the supermemory skill, and stateful session design."
date: 2026-03-13
author: theluckystrike
---

# Claude Skills Memory and Context Architecture Explained

One of the most misunderstood aspects of Claude Code skills is how memory and context actually work. Many developers expect skills to "remember" things the way a human colleague would — across sessions, across projects, without any setup. The reality is more precise and more controllable than that.

## The Context Window: Your Skill's Working Memory

Every Claude skill operates within a context window. The context window holds everything Claude can "see" at any given moment:

- The skill's system prompt (the skill body from the `.md` file)
- Any `context_files` injected at invocation
- The conversation history for the current session
- Tool outputs from the current session
- The user's current message

When the context window fills up, older conversation history is dropped. Tool outputs are typically more aggressively truncated than conversation text.

A key point: **skills do not share context windows**. If you switch from your `tdd` skill to your `frontend-design` skill mid-session, the new skill starts with only the shared conversation history — it does not inherit the previous skill's injected context files.

## Context Files: Deterministic Injection

The simplest form of skill memory is `context_files`. These are declared in the skill's front matter and are loaded fresh every time the skill is invoked:

```yaml
---
name: frontend-design
description: Builds React components with Tailwind CSS
context_files:
  - docs/design-tokens.md
  - src/components/Button.tsx
  - src/styles/globals.css
---
```

When this skill runs, those three files are read from disk and inserted into the context window before Claude processes your message. This gives the skill awareness of your current design system state without you having to paste it every time.

Context files are re-read on every invocation. If you update `design-tokens.md`, the next time `frontend-design` is invoked it will see the updated version. There's no caching.

### Dynamic Context Files

Context files can reference shell output using `$()` syntax in a special `dynamic_context` field:

```yaml
dynamic_context:
  - command: "git log --oneline -10"
    label: "Recent commits"
  - command: "npm list --depth=0 2>/dev/null"
    label: "Installed packages"
```

The output of these commands is injected as text into the context window alongside the static `context_files`. This is how skills like `tdd` can be aware of your current test suite without you explicitly telling it.

## Session Memory: Within a Single Session

Within a single Claude Code session, memory is implicit — it's the conversation history. Claude remembers what you said earlier in the session because that history is in the context window.

This is stateful within a session but ephemeral across sessions. When you close Claude Code and reopen it, that conversation history is gone.

Skills can leverage within-session memory by reading from the session state:

```
User: "Remember that we're using PostgreSQL for this project."
Claude: [tdd skill active] "Got it. When writing integration tests, I'll use pg-specific patterns."
...
User: "Now write tests for the user authentication flow."
Claude: [still in tdd skill, with PostgreSQL context still in window] Writes pg-aware tests.
```

## The `supermemory` Skill: Cross-Session Persistence

The `supermemory` skill is a first-class integration that solves the cross-session memory problem. It maintains a structured memory store that persists between sessions and is queryable by skills.

### How supermemory Works

The `supermemory` skill runs as a pre-hook before other skills fire. It:

1. Embeds your current message
2. Queries the memory store for semantically similar past context
3. Injects the relevant memories into the context window
4. Releases control to the primary skill (or normal Claude)

The memory store itself is a local vector database stored in `~/.claude/supermemory/` (or a remote Supabase/Postgres instance if configured). Each memory entry has:

- The original text
- An embedding vector
- Metadata (project name, timestamp, skill that created it, tags)

### Writing to supermemory

When a skill has `memory: true` in its front matter, Claude can write to the memory store using a special `remember()` function call pattern:

```yaml
---
name: tdd
memory: true
---
You are a TDD assistant. When you learn something important about this project's testing
patterns, conventions, or constraints, use the remember() function to save it.
```

Claude will naturally call `remember("This project uses Jest with React Testing Library. All component tests use @testing-library/user-event for interaction simulation.")` when it encounters important context worth persisting.

### Memory Scoping

Memories are scoped to prevent cross-project leakage:

- **Project-scoped memories**: Associated with a specific `project_root` path. Only available when working in that project.
- **Global memories**: Associated with the user but no specific project. Available in all sessions (e.g., coding style preferences).
- **Skill-scoped memories**: Associated with a skill name. Only surfaced when that skill is active.

Configure the default scope in the skill front matter:

```yaml
memory: true
memory_scope: project  # or "global" or "skill"
```

## CLAUDE.md: Project-Level Context

Beyond skills, Claude Code loads a `CLAUDE.md` file from the project root (if it exists) into every session's context window automatically. This is not skill-specific — it's available to all skills and to Claude in its default mode.

Use `CLAUDE.md` for project-wide context that every skill needs:

```markdown
# Project Context

This is a Next.js 15 app using TypeScript, Tailwind CSS, and PostgreSQL via Prisma.
We use pnpm as the package manager.
All API routes are in src/app/api/. All components are in src/components/.
Tests use Jest + React Testing Library. Run tests with `pnpm test`.
```

With a well-written `CLAUDE.md`, you can write leaner skill bodies that don't repeat project basics.

## Context Architecture for Multi-Skill Workflows

When you have multiple skills that hand off to each other, context continuity matters. Here's a pattern that works:

### Shared Context via Project Memory

Have each skill write key outputs to a shared project memory file (a regular `.md` file in your project, not the supermemory vector store):

```
.claude/
  context/
    current-sprint.md     # Written by your planning skill
    architecture.md       # Written by your design skill
    test-patterns.md      # Written by your tdd skill
```

Reference these in multiple skills' `context_files`:

```yaml
# tdd skill
context_files:
  - .claude/context/test-patterns.md
  - .claude/context/current-sprint.md

# frontend-design skill
context_files:
  - docs/design-tokens.md
  - .claude/context/architecture.md
  - .claude/context/current-sprint.md
```

This creates a lightweight shared memory layer that's transparent (it's just files), version-controllable, and not dependent on any external service.

## What Skills Cannot Remember

Understanding the limits of the memory architecture prevents design mistakes:

**Skills cannot remember across sessions without supermemory**: The conversation history is ephemeral. If you tell Claude something important, either save it to a file, use the supermemory skill, or put it in CLAUDE.md.

**Skills cannot share context within a session without it being in the conversation history**: If skill A learns something and you switch to skill B, skill B cannot access skill A's injected context files.

**Large context files reduce available conversation space**: Every byte in `context_files` is a byte not available for conversation history. Keep context files focused and concise.

**supermemory retrieval is probabilistic**: The semantic search retrieves what it thinks is relevant, which may not always match what you'd consider relevant. Important project facts should be in `CLAUDE.md` or explicit `context_files`, not just trusted to supermemory.

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
