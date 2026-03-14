---
layout: default
title: "Claude Code Resume Flag: How to Use It"
description: "Learn how to use Claude Code's --resume flag to continue interrupted sessions, recover work in progress, and manage long-running tasks effectively."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-resume-flag-how-to-use-it/
---

# Claude Code Resume Flag: How to Use It

When you're in the middle of a complex refactoring task or debugging session with Claude Code, interruptions happen. Maybe your terminal crashed, your computer restarted, or you simply closed the session to free up resources. The `--resume` flag lets you pick up exactly where you left off, without losing context or having to re-explain your task.

## What the Resume Flag Does

The `--resume` flag tells Claude Code to continue from a previous session by loading the conversation history and any relevant project context. It's particularly useful when working on multi-step tasks that span hours or days, or when you need to step away mid-task.

```bash
claude --resume "session-id"
```

The session ID comes from your previous Claude Code interaction. When you start a session, Claude displays a session identifier that you can reference later.

## Finding Your Session ID

Claude Code stores session information in your local project directory. Look for a `.claude` folder in your project root:

```bash
ls -la .claude/
```

This directory contains conversation logs and session metadata. Each session gets a unique identifier. You can also find recent sessions by checking the session logs:

```bash
claude sessions list
```

This command shows all recent sessions with their IDs, timestamps, and brief descriptions of what you were working on.

## Practical Examples

### Resuming a Large Refactor

Imagine you're mid-way through migrating a legacy JavaScript codebase to TypeScript using the claude-code-for-jquery-to-react-migration-workflow. You've made progress on three components but need to stop:

```bash
# Start your session
claude --dangerously-skip-permissions

# Work for a while, then Ctrl+C to interrupt
# Later, resume:
claude --resume "abc123-session-id"
```

Claude will load the previous context and continue from where you stopped, reviewing what's been done and what remains.

### Continuing Debugging Sessions

When debugging complex issues, you might need to step away after identifying the root cause but before implementing the fix. The resume flag works seamlessly with debugging workflows:

```bash
# Start debugging
claude --resume "debug-session-xyz"
```

Claude Code will recall the error logs you were analyzing, the files you examined, and the hypotheses you were testing.

### Multi-Day Project Work

For longer projects that span multiple days, the resume flag maintains continuity:

```bash
# Monday - start building an API
claude "Build a REST API with Express and PostgreSQL"

# Tuesday - continue where you left off
claude --resume "monday-api-session"
```

This approach works well when combined with skills like the tdd skill for test-driven development workflows, where maintaining context across sessions is crucial.

## Combining Resume with Other Flags

The `--resume` flag works alongside other Claude Code flags for enhanced functionality:

```bash
# Resume with permissions bypass (use carefully)
claude --resume "session-id" --dangerously-skip-permissions

# Resume and limit to specific directory
claude --resume "session-id" --path ./src

# Resume with expanded context
claude --resume "session-id" --max-turns 100
```

## When to Use Resume vs. Starting Fresh

The resume flag isn't always the best choice. Here's when to use each approach:

**Use --resume when:**
- You were in the middle of a task with clear progress
- The session had valuable context (file changes, test results, decisions made)
- You want to continue a conversation with the same Claude instance

**Start fresh when:**
- The previous session reached a natural stopping point
- Your task has fundamentally changed
- You're working on a different feature or bug

## Best Practices

### Save Session Context Manually

For critical tasks, periodically save your progress manually before ending a session:

```bash
# In your Claude session, ask for a status summary
"What have we accomplished so far? Please summarize the remaining work."
```

This creates a clear checkpoint you can reference when resuming.

### Use the supermemory Skill

The supermemory skill can supplement session resumes by maintaining persistent context across sessions. This is particularly useful for long-term projects where you want Claude to remember project-specific conventions, architecture decisions, or coding standards:

```
/supermemory remember that we follow the repository pattern for data access
```

### Document Your Progress

After each significant milestone in a task, create a brief summary. This makes resuming much smoother:

```
# Session summary (paste this when resuming):
## Completed:
- Migrated UserService to TypeScript
- Updated authentication middleware
- Fixed 3 failing tests

## Remaining:
- Migrate OrderService
- Update API routes
- Run full test suite
```

## Troubleshooting Resume Issues

If `--resume` doesn't work as expected:

1. **Session not found**: The session may have expired or been garbage collected. Sessions typically expire after a configurable period.

2. **Context mismatch**: If the project changed significantly since the session, Claude may have trouble continuing. Review the current state and provide additional context.

3. **Permission differences**: If you used `--dangerously-skip-permissions` originally, you may need to grant permissions again when resuming.

## Working with Skills After Resume

When you resume a session, Claude automatically reloads any active skills. If you were using the frontend-design skill before interrupting, it will be available when you resume. Similarly, skills like pdf, xlsx, or tdd will be restored to their previous state.

The resume flag preserves skill context, including any custom instructions or configuration you had active. This means your domain-specific workflows continue seamlessly.

## Summary

The `--resume` flag is an essential tool for developers working on complex, multi-session tasks with Claude Code. By maintaining conversation history and project context, it enables workflow continuity that would otherwise require manual state management. Use it alongside good practices like manual progress saves and the supermemory skill for robust, interrupted-task recovery.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
