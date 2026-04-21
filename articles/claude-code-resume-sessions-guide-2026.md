---
layout: post
title: "How to Resume Claude Code Sessions 2026"
description: "Resume interrupted Claude Code sessions with --resume flag. Recover context, continue long tasks, and manage session history effectively."
permalink: /claude-code-resume-sessions-guide-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Workflow

Resume interrupted Claude Code sessions to continue where you left off without losing context. Use the `--resume` flag to recover from crashes, continue multi-step tasks across terminal restarts, and manage your conversation history.

Expected time: 2 minutes to learn, immediate use
Prerequisites: Claude Code CLI installed (v1.0+)

## Setup

### 1. Understand Session Storage

```bash
# Claude Code stores sessions in:
ls ~/.claude/sessions/
# Each session is a JSON file with full conversation history
```

Sessions are automatically saved after every interaction, so even crashes preserve your work.

### 2. Resume Your Most Recent Session

```bash
# Resume the last session (most common usage)
claude --resume

# This restores:
# - Full conversation history
# - File context that was loaded
# - Any pending operations
```

The `--resume` flag picks up exactly where you left off.

### 3. Resume a Specific Session by ID

```bash
# List available sessions
claude --list-sessions

# Resume a specific session
claude --resume "session_2026-04-21_143022"
```

### 4. Create Named Sessions for Long Tasks

```bash
# Start a named session for a multi-day task
claude --session "refactor-auth-module"

# Later, resume it by name
claude --resume "refactor-auth-module"
```

Named sessions make it easy to juggle multiple ongoing tasks.

### 5. Verify

```bash
# Start a session, ask something, then exit
claude
> What is 2 + 2?
> /exit

# Resume and verify context is preserved
claude --resume
> What was my last question?
# Expected output:
# Your last question was "What is 2 + 2?"
```

## Usage Example

A real-world workflow for a multi-session refactoring task:

```bash
# Day 1: Start the refactoring
claude --session "migrate-to-drizzle"

> I need to migrate our database layer from Prisma to Drizzle ORM.
> The schema is in prisma/schema.prisma. Let's start by analyzing
> the current models and creating equivalent Drizzle schemas.

# Claude Code analyzes your schema and starts generating Drizzle files
# ... 30 minutes of work ...
# You need to leave for a meeting

> /exit
```

```bash
# Day 1 (later): Resume after meeting
claude --resume "migrate-to-drizzle"

> Let's continue. We had the users and posts tables done.
> Now handle the many-to-many relationships (tags, categories).

# Claude Code remembers all prior context:
# - The original Prisma schema
# - Files already generated
# - Decisions made earlier in the session
```

```bash
# Day 2: Continue the migration
claude --resume "migrate-to-drizzle"

> Yesterday we finished the schema definitions. Now let's
> update the repository layer in src/repositories/ to use
> the new Drizzle client instead of PrismaClient.
```

Managing multiple concurrent tasks:

```bash
# Work on different features in different sessions
claude --session "feature-search"
# ... work on search feature ...
> /exit

claude --session "bugfix-auth-timeout"
# ... fix auth bug ...
> /exit

# Switch between them freely
claude --resume "feature-search"
# or
claude --resume "bugfix-auth-timeout"
```

Session cleanup for completed work:

```bash
# View all sessions with timestamps
claude --list-sessions
# Output:
# migrate-to-drizzle     2026-04-20 14:30 (3 messages)
# feature-search         2026-04-21 09:15 (12 messages)
# bugfix-auth-timeout    2026-04-21 11:00 (5 messages)
# session_2026-04-21_... 2026-04-21 13:45 (1 message)

# Delete old sessions you no longer need
claude --delete-session "migrate-to-drizzle"
```

Using resume with the `--continue` flag for automated scripts:

```bash
# In a script, resume and add a new prompt
claude --resume "nightly-review" --print \
  "Review any new commits since yesterday and summarize changes"

# This appends to the session, maintaining full history
# Useful for daily standup summaries or recurring tasks
```

## Common Issues

- **Session not found after OS update:** Sessions are stored in `~/.claude/sessions/`. If your home directory changed or was migrated, copy the sessions directory to the new location.
- **Resume shows stale file content:** Claude Code re-reads files on resume, but if file paths changed, explicitly tell it: "The auth module moved from src/auth/ to src/modules/auth/".
- **Session too large (slow resume):** For very long sessions (100+ messages), start a fresh session and paste a summary of prior decisions. Context windows have limits.

## Why This Matters

Long development tasks spanning multiple days no longer require re-explaining context. Resume eliminates the 5-10 minutes typically spent re-establishing project context at the start of each coding session.

## Related Guides

- [Claude Code Tmux Session Management](/claude-code-tmux-session-management-multi-agent-workflow/)
- [Best Way to Scope Tasks for Claude Code Success](/best-way-to-scope-tasks-for-claude-code-success/)
- [Best Way to Set Up Claude Code for a New Project](/best-way-to-set-up-claude-code-for-new-project/)
