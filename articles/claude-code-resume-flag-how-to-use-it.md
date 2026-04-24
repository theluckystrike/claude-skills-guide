---

layout: default
title: "Claude Code --resume Flag (2026)"
description: "Use Claude Code --resume to continue interrupted sessions. Recover work in progress and manage long-running tasks effectively."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-resume-flag-how-to-use-it/
reviewed: true
score: 7
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
---

When you're in the middle of a complex refactoring task or debugging session with Claude Code, interruptions happen. Maybe your terminal crashed, your computer restarted, or you simply closed the session to free up resources. The `--resume` flag lets you pick up exactly where you left off, without losing context or having to re-explain your task.

## What the Resume Flag Does

The `--resume` flag tells Claude Code to continue from a previous session by loading the [save Claude Code conversations](/claude-code-save-conversation-guide/) and any relevant project context. It's particularly useful when working on multi-step tasks that span hours or days, or when you need to step away mid-task.

```bash
claude --resume "session-id"
```

The session ID comes from your previous Claude Code interaction. When you start a session, Claude displays a session identifier that you can reference later.

Without `--resume`, starting Claude Code always begins a fresh conversation. Claude has no memory of what you discussed previously, which files you looked at, or what decisions were made. For a ten-minute task this doesn't matter. For a multi-hour refactoring session or a debugging marathon, losing that context wastes significant time.

The resume mechanism works by replaying the conversation history from a stored session file. Claude reads the prior turns, reconstructs the working state, and is ready to continue from the point where the session ended.

## Finding Your Session ID

Claude Code stores session information in your local project directory. Look for a `.claude` folder in your project root:

```bash
ls -la .claude/
```

This directory contains conversation logs and session metadata. Each session gets a unique identifier. The `.claude` directory typically contains:

```
.claude/
 sessions/
 abc123-2026-03-14T09-30-00.jsonl
 def456-2026-03-15T14-22-10.jsonl
 ghi789-2026-03-16T08-05-33.jsonl
 settings.json
 CLAUDE.md
```

Each session file is named with the session ID and a timestamp, making it easy to identify which session corresponds to which work session. The session ID to pass to `--resume` is the prefix before the timestamp (e.g., `abc123`).

If you're unsure which session ID to use, you can inspect the session files directly. They're stored as JSONL (newline-delimited JSON), so you can read the first few lines to see what the session was about:

```bash
head -5 .claude/sessions/abc123-2026-03-14T09-30-00.jsonl
```

This shows the first message from the session, giving you enough context to identify the right one.

## Practical Examples

## Resuming a Large Refactor

Imagine you're mid-way through migrating a legacy JavaScript codebase to TypeScript. You've made progress on three components but need to stop:

```bash
Start your session
claude --dangerously-skip-permissions

Work for a while, then Ctrl+C to interrupt
Later, resume:
claude --resume "abc123-session-id"
```

Claude will load the previous context and continue from where you stopped, reviewing what's been done and what remains.

When you resume, it's good practice to orient Claude explicitly even though it has the session history:

```
We were migrating the JavaScript codebase to TypeScript.
We completed UserService, AuthMiddleware, and ProductController.
Let's continue with OrderService next.
```

This brief orienting message costs nothing and ensures Claude's attention is focused on the right next step rather than re-reading the full conversation history to figure out where things stand.

## Continuing Debugging Sessions

When debugging complex issues, you might need to step away after identifying the root cause but before implementing the fix. The resume flag works smoothly with debugging workflows:

```bash
Start debugging
claude --resume "debug-session-xyz"
```

Claude Code will recall the error logs you were analyzing, the files you examined, and the hypotheses you were testing. For example, if you spent two hours narrowing down a memory leak to a specific service but had to step away before writing the fix, resuming with `--resume` means you don't lose those two hours of investigation. Claude remembers the stack traces, the files you explored, and the conclusions you reached.

This is particularly valuable for intermittent bugs where reproducing the issue takes significant effort. The session history preserves your reproduction steps and observations, so you can hand the investigation back to Claude without starting from scratch.

## Multi-Day Project Work

For longer projects that span multiple days, the resume flag maintains continuity:

```bash
Monday - start building an API
claude "Build a REST API with Express and PostgreSQL"

Tuesday - continue where you left off
claude --resume "monday-api-session"
```

This approach works well when combined with skills like the tdd skill for test-driven development workflows, where maintaining context across sessions is crucial. The test suite state, the decisions made about test structure, and the coverage goals all persist through the session history.

## Resuming After a System Restart

Sometimes the interruption isn't planned. A power outage, a kernel update requiring a reboot, or a terminal crash can cut a session short. In these cases, `--resume` is a recovery tool:

```bash
After restart, check what sessions are available
ls -lt .claude/sessions/ | head -10

Resume the most recent session
claude --resume "last-session-id"
```

For unplanned interruptions like this, the first thing to do after resuming is ask Claude to summarize what was in progress:

```
Please summarize what we were working on and where we left off.
```

This gets both you and Claude aligned quickly without requiring you to scroll back through hours of conversation.

## Combining Resume with Other Flags

The `--resume` flag works alongside other Claude Code flags for enhanced functionality:

```bash
Resume with permissions bypass (use carefully)
claude --resume "session-id" --dangerously-skip-permissions

Resume and limit to specific directory
claude --resume "session-id" --path ./src

Resume with expanded context
claude --resume "session-id" --max-turns 100
```

## Flag Compatibility Reference

| Flag | Works with --resume? | Notes |
|---|---|---|
| `--dangerously-skip-permissions` | Yes | Must re-specify if needed; not inherited |
| `--path` | Yes | Useful for scoping resumed work to a subdirectory |
| `--max-turns` | Yes | Extend turn limits for long-running resumed sessions |
| `--model` | Yes | You can switch models when resuming |
| `--print` | Yes | Useful for non-interactive resumed sessions in scripts |
| `--output-format json` | Yes | Good for piping resumed session output to other tools |

One important note on `--dangerously-skip-permissions`: permissions granted in a previous session are not automatically carried forward when you resume. You need to re-specify permission flags explicitly. This is a safety feature, it prevents resumed sessions from silently inheriting broad permissions that were intended only for a specific previous task.

## When to Use Resume vs. Starting Fresh

The resume flag isn't always the best choice. Here's when to use each approach:

Use --resume when:
- You were in the middle of a task with clear progress
- The session had valuable context (file changes, test results, decisions made)
- You want to continue a conversation with the same Claude instance
- The interruption was unplanned and you're returning to the same task immediately

Start fresh when:
- The previous session reached a natural stopping point
- Your task has fundamentally changed
- You're working on a different feature or bug
- The codebase changed significantly since the session (e.g., someone else merged a large PR)
- The session was exploratory and you're now ready to execute a specific plan

A good rule of thumb: if you can clearly articulate "we were doing X and we're 60% done," use `--resume`. If you'd have to say "we were doing X but I've since decided to do Y instead," start fresh.

## What Happens When Sessions Expire

Claude Code sessions aren't stored indefinitely. The `.claude/sessions/` directory grows over time, and older sessions is pruned based on your local configuration. If you try to resume an expired session:

```bash
claude --resume "old-session-id"
Error: Session not found or expired
```

When this happens, start a fresh session but provide a summary of what you were working on. If you followed good checkpoint practices (more on this below), you'll have a written summary ready to paste in as context.

## Best Practices

## Save Session Context Manually

For critical tasks, periodically save your progress manually before ending a session:

```bash
In your Claude session, ask for a status summary
"What have we accomplished so far? Please summarize the remaining work."
```

This creates a clear checkpoint you can reference when resuming.

A more structured approach is to ask for a formatted handoff document:

```
Please create a session handoff summary in this format:
- Task: [what we're doing]
- Completed: [list of completed items]
- In Progress: [what we were working on when we stopped]
- Remaining: [what's left to do]
- Key Decisions: [important choices made and why]
- Next Action: [the exact next step to take on resume]
```

Copy this into a notes file or a comment in the codebase. When you resume, paste it back in as the first message to instantly re-orient Claude.

## Use the supermemory Skill

The supermemory skill can supplement session resumes by maintaining persistent context across sessions. This is particularly useful for long-term projects where you want Claude to remember project-specific conventions, architecture decisions, or coding standards:

```
/supermemory remember that we follow the repository pattern for data access
```

The key difference between `--resume` and supermemory is scope. `--resume` restores a specific conversation. The supermemory skill persists information across all future sessions, making it better suited for enduring facts about your project rather than the state of a specific task.

Used together, they form a powerful combination: supermemory holds your project's permanent rules and preferences, while `--resume` holds the ephemeral state of active work.

## Use CLAUDE.md for Persistent Project Context

Another complement to `--resume` is the `CLAUDE.md` file in your project root. This file is automatically read at the start of every Claude Code session, including resumed ones. Use it to capture information that should always be in context:

```markdown
Project: Payment Service

Architecture
- Express API on Node 20
- PostgreSQL via Prisma ORM
- Redis for session storage

Conventions
- Use repository pattern for all data access
- All API responses follow { data, error, meta } shape
- Tests use Vitest, not Jest

Current Sprint
- Implementing refund flow (in progress)
- See /src/refunds/ for work in progress
```

When you resume a session, Claude reads CLAUDE.md first, ensuring it always has foundational context even if the session history is incomplete.

## Document Your Progress

After each significant milestone in a task, create a brief summary. This makes resuming much smoother:

```
Session summary (paste this when resuming):
Completed:
- Migrated UserService to TypeScript
- Updated authentication middleware
- Fixed 3 failing tests

Remaining:
- Migrate OrderService
- Update API routes
- Run full test suite
```

Keeping these summaries in a `PROGRESS.md` or `NOTES.md` file in the project root means they're always findable, even if you return to the project weeks later.

## Troubleshooting Resume Issues

If `--resume` doesn't work as expected, here are the most common causes and fixes:

## Session not found

The session may have expired or been garbage collected. Sessions typically expire after a configurable period. Solution: check `ls -la .claude/sessions/` to confirm the session file exists. If it doesn't, start fresh and provide a context summary.

## Context mismatch

If the project changed significantly since the session, for example, a large refactor was merged, dependencies were updated, or files were renamed, Claude may have trouble continuing. Review the current state and provide additional context when resuming:

```
Heads up: since our last session, the team merged a PR that reorganized
the /src/services directory. UserService is now at /src/services/users/user.service.ts
instead of /src/user.service.ts. Let's adjust and continue.
```

## Permission differences

If you used `--dangerously-skip-permissions` originally, you may need to grant permissions again when resuming. This is expected behavior.

## Session history too large

Very long sessions can sometimes cause performance issues when resuming, as Claude has to process a large amount of prior conversation. If this happens, summarize the session into a CLAUDE.md entry or a context block and start a fresh session with that summary.

## Working with Skills After Resume

When you resume a session, Claude automatically reloads any active skills. If you were using the frontend-design skill before interrupting, it will be available when you resume. Similarly, skills like pdf, xlsx, or tdd will be restored to their previous state.

The resume flag preserves skill context, including any custom instructions or configuration you had active. This means your domain-specific workflows continue smoothly.

One exception: if a skill relies on external state (like an open connection to a database or a browser session via Playwright), that external state is not automatically restored. You may need to re-initialize the connection as part of the resumed session. Claude will typically recognize this need and prompt you, but be prepared to re-run initialization steps for stateful skills.

## Summary

The `--resume` flag is an essential tool for developers working on complex, multi-session tasks with Claude Code. By maintaining conversation history and project context, it enables workflow continuity that would otherwise require manual state management.

Used well, `--resume` turns Claude Code from a session-based assistant into something closer to a persistent collaborator, one that remembers what you were building, what decisions were made, and exactly where you left off. Combine it with good checkpoint practices, a well-maintained CLAUDE.md, and the supermemory skill for the most solid interrupted-task recovery workflow available in Claude Code today.


## Related

- [Claude shortcuts guide](/claude-shortcuts-complete-guide/) — Complete guide to Claude Code keyboard shortcuts and slash commands
---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-resume-flag-how-to-use-it)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide]/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026]/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
- [How to Resume Claude Code Sessions 2026](/claude-code-resume-sessions-guide-2026/)
