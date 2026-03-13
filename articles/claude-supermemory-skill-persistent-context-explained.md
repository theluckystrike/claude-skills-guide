---
layout: post
title: "Claude SuperMemory Skill: Persistent Context Explained"
description: "How the SuperMemory skill stores project context across Claude sessions. Invocation, storage patterns, and when to use it over CLAUDE.md."
date: 2026-03-13
categories: [skills]
tags: [claude-code, claude-skills, supermemory, persistent-context, memory]
author: "Claude Skills Guide"
reviewed: true
score: 6
---

# Claude SuperMemory Skill: Persistent Context Explained

The SuperMemory skill provides persistent context across Claude Code sessions. Where a standard session starts fresh each time, SuperMemory maintains a knowledge base — project preferences, architecture decisions, coding conventions — that Claude loads automatically at the start of subsequent sessions.

## The Context Persistence Problem

When you start a new Claude session, Claude has no memory of previous conversations. For isolated tasks this is fine, but for multi-day projects it creates friction: you re-explain your stack, remind Claude of your conventions, and rebuild shared understanding every time.

Claude Code ships with a built-in partial solution: the `CLAUDE.md` file at the root of your project. That file loads automatically on every session and is the right place for stable, long-lived project context. SuperMemory fills a different niche — it's suited for context that changes over time: solutions you discover mid-session, decisions you make during a sprint, or notes you want preserved without editing `CLAUDE.md` manually.

## Invoking SuperMemory

Skills in Claude Code are `.md` files stored in `~/.claude/skills/`. You invoke them with a slash command:

```
/supermemory
```

Once the skill is active, you interact with it through natural-language instructions within your Claude session. There is no separate CLI binary and no `claude code run supermemory` subcommand — the skill runs inside your Claude Code conversation.

## Storing Context

After invoking the skill, tell Claude what to remember:

```
/supermemory

Remember for this project:
- Stack: React 18, TypeScript, Vite, Tailwind CSS
- Conventions: functional components only, props interfaces prefixed with component name
- Custom hooks live in /hooks, shared types in /types/index.ts
- ESLint config: airbnb-typescript preset
```

The skill stores this in a local file (typically within `~/.claude/memory/` or a project-scoped location defined in the skill's own front matter). The exact storage path depends on how the skill author configured it — check the skill's own `README` or front matter if you need the precise location.

## Practical Examples

### Multi-Session Project Development

On day one of a project, you document an architecture decision:

```
/supermemory

Architecture decision (2026-03-10): chose microservices over monolith.
Three services: auth (JWT, 1h expiry), billing (Stripe), notifications (SendGrid).
Auth service owns the user table; billing and notifications call auth's /verify endpoint.
```

When you return three days later, Claude loads this context before you type your first message. You can ask "continue the billing service" without re-explaining the architecture.

### Preserving Debugging Solutions

When you solve a non-obvious bug, store the solution:

```
/supermemory

Fix: webpack `resolve.fallback` must be set to `false` for the `fs` module in
production builds. Without this, the build throws "Module not found: Error: Can't
resolve 'fs'" for any package that optionally imports Node built-ins.
```

This prevents the same debugging session from happening twice.

### Team Convention Notes

```
/supermemory

Branch naming: feature/TICKET-ID-short-description
PR rules: 2 approvals required, squash merge to main
CI gates: unit tests + lint + build (all must pass)
```

## SuperMemory vs CLAUDE.md

| | `CLAUDE.md` | SuperMemory skill |
|---|---|---|
| **Best for** | Stable project facts | Evolving notes and discoveries |
| **Edited by** | You (text editor) | Claude (during session) |
| **Loaded** | Automatically, always | When skill is active |
| **Scope** | Per-repo (place in project root) | Configurable; often per-user |
| **Versioned** | Yes (it's a tracked file) | Depends on storage path |

For anything you'd want in your repo's git history — tech stack, architecture overview, team conventions — `CLAUDE.md` is the better tool. SuperMemory shines for ephemeral-to-medium-term notes that don't belong in version control.

## Combining SuperMemory with Other Skills

SuperMemory composes well with other skills. The `tdd` skill benefits from remembering where your test files live and which framework you use. The `frontend-design` skill produces better output when it already knows your component library and design tokens. The `pdf` skill can store extraction schemas so you don't re-specify column mappings for recurring document types.

Invoke both in the same session:

```
/supermemory
/tdd

Review my test coverage for src/auth.ts and remember any patterns we agree on.
```

## Limitations

**Storage is local.** Context stored on one machine does not sync to another unless you manually copy the storage file or use a shared path.

**Manual, not automatic.** SuperMemory only stores what you explicitly ask it to. Claude will not silently record everything you discuss.

**Token budget still applies.** If your stored context grows very large, the skill may summarize or truncate older entries to stay within Claude's context window. Prune stale entries periodically.

**No official sub-commands.** Unlike the hallucinated `@supermemory list` or `@supermemory export` syntax you may see in other guides, the skill operates through natural language inside Claude Code. Ask Claude to "show what's stored" or "clear the project context" and it will handle it through its normal tool use.

## When to Use SuperMemory

SuperMemory is worth reaching for when:

- You're working on the same project across multiple sessions over days or weeks
- You want Claude to remember something you discovered mid-session without editing a file manually
- You need a scratchpad for decisions that haven't hardened into `CLAUDE.md` material yet

For quick one-off tasks, the built-in session context is enough. Save SuperMemory for work where continuity matters.

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
