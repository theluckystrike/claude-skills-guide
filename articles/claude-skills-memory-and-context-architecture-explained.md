---
layout: default
title: "Claude Skills Memory and Context (2026)"
description: "How Claude skills manage context and memory across turns and sessions: context_files injection, the supermemory skill, and stateful session design."
date: 2026-03-13
last_modified_at: 2026-04-17
categories: [advanced]
tags: [claude-code, claude-skills, memory, context, supermemory, state-management]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-skills-memory-and-context-architecture-explained/
geo_optimized: true
---

# Claude Skills Memory and Context Architecture Explained

One of the most misunderstood aspects of Claude Code skills is how memory and context actually work. Many developers expect skills to "remember" things the way a human colleague would. across sessions, across projects, without any setup. The reality is more precise and more controllable than that.

Understanding the memory and context architecture is not just academic. It directly affects whether your skills produce consistent, high-quality output or drift off course the moment a session ends. This guide walks through every layer of the system: how Claude holds information right now, how to persist state between sessions, and how to design multi-skill workflows that share context cleanly.

## The Context Window: Your Skill's Working Memory

Every Claude skill operates within a context window. The context window holds everything Claude can "see" at any given moment:

- The skill's system prompt (the skill body from the `.md` file)
- The conversation history for the current session
- Tool outputs from the current session
- The user's current message

When the context window fills up, older conversation history is dropped. Tool outputs are typically more aggressively truncated than conversation text.

A key point: skills do not share context windows. If you switch from your [`tdd` skill](/best-claude-skills-for-developers-2026/) to your `frontend-design` skill mid-session, the new skill starts with only the shared conversation history. it does not inherit the previous skill's context or tool outputs.

Think of the context window as RAM, not disk. It is fast, immediate, and limited. When the process ends, it is gone. Everything you want to persist must be written to "disk". which in practice means files, `CLAUDE.md`, or the `/supermemory` skill.

## How Context Fills Up in Practice

A typical skill invocation might consume context in this order:

1. System prompt injection (the skill `.md` file body): 500–2,000 tokens
2. `CLAUDE.md` content: 200–1,000 tokens
3. File reads requested by the skill: 1,000–10,000+ tokens depending on file size
4. Conversation history: grows with each turn
5. Tool outputs: can be large (e.g., full file contents, grep results)

For a model with a 200,000-token context window, this is plenty for most workflows. But if your skill instructs Claude to read many large files at the start of every invocation, the available space for conversation history shrinks. A skill that reads five 500-line source files at startup is consuming roughly 10,000–15,000 tokens before a single message is exchanged.

The practical implication: keep file injection targeted. Read the specific sections relevant to the task, not entire codebases.

## CLAUDE.md: Project-Level Context

Claude Code loads a `CLAUDE.md` file from the project root (if it exists) into every session's context window automatically. This is not skill-specific. it is available to all skills and to Claude in its default mode.

Use `CLAUDE.md` for project-wide context that every skill needs:

```markdown
Project Context

This is a Next.js 15 app using TypeScript, Tailwind CSS, and PostgreSQL via Prisma.
We use pnpm as the package manager.
All API routes are in src/app/api/. All components are in src/components/.
Tests use Jest + React Testing Library. Run tests with pnpm test.
```

With a well-written `CLAUDE.md`, you can write leaner skill bodies that do not repeat project basics.

## What Belongs in CLAUDE.md vs. Skill System Prompts

A common design mistake is duplicating information between `CLAUDE.md` and individual skill prompts. The right mental model is:

- `CLAUDE.md`: facts that are always true about the project (tech stack, directory layout, naming conventions, run commands)
- Skill system prompt: behavior instructions specific to that skill's role (what to generate, how to structure output, what to avoid)

This separation keeps skill files concise and means a change to the tech stack only needs to happen in one place. If you rename your test runner from `pnpm test` to `pnpm run test:unit`, you update `CLAUDE.md` and every skill that needs that information picks it up automatically.

## Nested CLAUDE.md Files

Claude Code also supports `CLAUDE.md` files in subdirectories. If you invoke a skill while your working directory is `src/components/`, Claude will load both the root `CLAUDE.md` and `src/components/CLAUDE.md` (if present). Use this for sub-project context:

```
my-monorepo/
 CLAUDE.md # Monorepo-level conventions
 packages/
 api/
 CLAUDE.md # API package specifics: Fastify, Zod schemas, route patterns
 web/
 CLAUDE.md # Web package specifics: Next.js, React Query, component patterns
```

## Session Memory: Within a Single Session

Within a single Claude Code session, memory is implicit. it is the conversation history. Claude remembers what you said earlier in the session because that history is in the context window.

This is stateful within a session but ephemeral across sessions. When you close Claude Code and reopen it, that conversation history is gone.

Skills can use within-session memory naturally:

```
User: "Remember that we're using PostgreSQL for this project."
Claude: [tdd skill active] "Got it. When writing integration tests, I'll use pg-specific patterns."
...
User: "Now write tests for the user authentication flow."
Claude: [still in tdd skill, with PostgreSQL context still in window] Writes pg-aware tests.
```

## When Within-Session Memory Breaks Down

Within-session memory is reliable as long as the relevant information stays in the context window. Two failure modes to watch for:

Long sessions with many tool calls. If a session runs long enough that early turns are truncated from the context window, Claude may appear to "forget" something you mentioned an hour ago. The information was there. it just aged out. Solution: summarize critical facts in a file mid-session if the session is expected to run long.

Switching skills mid-session. When you invoke a new skill, the system prompt changes. The conversation history is still visible, but the framing shifts. The new skill's system prompt may not direct Claude to look for earlier context in the same way. If something you said earlier in the session matters for the new skill, restate it or have a shared context file both skills read.

## The /supermemory Skill: Cross-Session Persistence

The [`/supermemory` skill](/claude-skills-token-optimization-reduce-api-costs/) solves the cross-session memory problem. It maintains a storage layer that persists between sessions.

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

## When to Use Supermemory vs. Files

Supermemory and file-based context serve different use cases. Use this table to decide:

| Use Case | Supermemory | CLAUDE.md / Files |
|---|---|---|
| One-time decisions made during a session | Yes | No. too transient for a committed file |
| Stable project conventions | No | Yes. commit it to the repo |
| Personal preferences (not project-wide) | Yes | No. not everyone's preference |
| Architecture decisions with rationale | Sometimes | Yes. belongs in docs |
| "Remember we decided X last week" | Yes | No |
| Team-shared knowledge | No | Yes. it should be in the repo |

The rule of thumb: if the information belongs in version control, put it in a file. If it is personal, ad hoc, or session-specific but needs to survive session restarts, use supermemory.

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

## Structuring Context Files for Efficient Injection

A context file that Claude reads at skill startup should be dense but scannable. Long prose wastes tokens. Prefer structured formats:

```markdown
API Conventions

Base URL: /api/v2
Auth: Bearer token in Authorization header
Errors: Always return { error: string, code: string }. never 200 with error body
Pagination: cursor-based, return { data: [], nextCursor: string | null }

Endpoint patterns
- GET /api/v2/{resource}. list (paginated)
- GET /api/v2/{resource}/{id}. single item
- POST /api/v2/{resource}. create
- PATCH /api/v2/{resource}/{id}. partial update
- DELETE /api/v2/{resource}/{id}. soft delete (sets deletedAt)
```

This kind of document communicates a lot of specific, actionable information in a small number of tokens. Compare it to a paragraph version that says the same thing in three times the space. the dense version leaves more room for actual work.

## Skills That Write Their Own Context Files

An advanced pattern is having a skill write context files as part of its work, so that downstream skills can read them. For example, a planning skill might write:

```markdown
Current Sprint Context (auto-generated by /planning skill)
Sprint goal: Complete user authentication MVP
In scope: login, signup, password reset, session management
Out of scope: OAuth, SSO, 2FA (next sprint)
Current blocker: Design spec for password reset email not finalized
```

...to `.claude/context/current-sprint.md`. Every other skill that reads this file now has sprint context without the user having to repeat it.

## Context Architecture for Multi-Skill Workflows

When you have multiple skills that hand off to each other, context continuity matters. Use a shared context directory that each skill is instructed to read:

```
.claude/
 context/
 current-sprint.md # Written by your planning skill
 architecture.md # Written by your design skill
 test-patterns.md # Written by your tdd skill
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

This creates a lightweight shared memory layer that is just files. inspectable, version-controllable, and not dependent on any external service.

## The Context Handoff Pattern

A well-designed multi-skill workflow treats context handoffs explicitly. Here is a complete example:

1. User invokes `/planning` to plan a feature. The skill writes `.claude/context/feature-auth.md` describing the feature scope, acceptance criteria, and technical decisions.

2. User invokes `/architect`. The skill reads `feature-auth.md`, designs the data model and API surface, then writes `.claude/context/architecture.md`.

3. User invokes `/tdd`. The skill reads both `feature-auth.md` and `architecture.md` to write tests that match the agreed design.

4. User invokes `/implement`. The skill reads all three context files, sees the feature spec, the architecture, and the test structure, and generates implementation code.

Each skill in this chain does focused work and produces an artifact that feeds the next. None of them need to ask the user to repeat information that was already captured.

## What Skills Cannot Remember

Understanding the limits of the memory architecture prevents design mistakes:

Skills cannot remember across sessions without supermemory. The conversation history is ephemeral. If you tell Claude something important, either save it to a file, use the `/supermemory` skill, or put it in `CLAUDE.md`.

Skills cannot share context within a session without it being in the conversation history. If skill A learns something and you switch to skill B, skill B cannot access skill A's prior context files unless the file-based approach described above is used.

Large context reduces available conversation space. Every byte of file content Claude reads is a byte not available for conversation history. Keep injected context focused and concise.

Tool outputs compete with conversation history for context space. A skill that runs many shell commands or reads many files in a single session will fill the context window faster than one that focuses on conversation. If a skill is running out of space, consider splitting the task across multiple sessions with file-based handoffs.

## Practical Checklist for Memory-Aware Skill Design

Before finalizing any skill, run through these questions:

1. What does this skill need to know that is stable across the whole project? Put that in `CLAUDE.md`, not the skill body.
2. What does this skill need to know that is specific to its role? Put that in dedicated context files and instruct the skill to read them.
3. What does this skill produce that other skills need? Instruct the skill to write it to a named file in `.claude/context/`.
4. What information will users want to persist across sessions but not commit to the repo? Point them toward `/supermemory`.
5. Is the skill reading any file that is not strictly necessary for the task? Remove it to save context space.

Following this checklist consistently produces skills that behave predictably, share context cleanly, and do not waste tokens on information they do not need.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-skills-memory-and-context-architecture-explained)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/) - The memory architecture described here directly affects token consumption
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/) - Covers supermemory and context-aware skills in practical terms
- [Building Stateful Agents with Claude Skills](/building-stateful-agents-with-claude-skills-guide/) - File-based state patterns in depth
- [Claude Code Keeps Switching to Wrong File Context](/claude-code-keeps-switching-to-wrong-file-context/)
- [Fix Claude Code MCP Tools Excessive Context — Quick Guide](/claude-code-mcp-tools-excessive-context-fix/)
- [How to Use Memory Optimization for Large Codebases (2026)](/claude-code-for-memory-allocation-optimization-guide/)
- [Tab Suspender Memory Saver Chrome Extension Guide (2026)](/chrome-extension-tab-suspender-memory-saver/)
- [Chrome Task Manager Memory — Developer Guide](/chrome-task-manager-memory/)
- [Chrome Extension Firebase Debugger](/chrome-extension-firebase-debugger/)
- [Broken Link Finder Chrome Extension Guide (2026)](/chrome-extension-broken-link-finder/)
- [Claude Code Expensive? Here Are 7 Fixes](/claude-code-expensive-7-fixes/)

Built by theluckystrike - More at [zovo.one](https://zovo.one)


