---
layout: default
title: "Claude Skill Not Saving State Between Sessions Fix"
description: "Fix Claude Code skills losing state between sessions. Covers supermemory setup, CLAUDE.md project context, file-based state persistence, and common pitfalls."
date: 2026-03-13
author: theluckystrike
---

# Claude Skill Not Saving State Between Sessions Fix

Every Claude Code session starts fresh. When you close a session — or it times out — everything Claude knew from that conversation is gone. Skills like `tdd`, `pdf`, `frontend-design`, and even `supermemory` do not automatically remember what happened in the previous session unless you have explicitly configured persistence. This guide explains the mechanics and gives you practical fixes.

## Why Claude Skills Are Stateless

A Claude Code skill is a `.md` file stored in `~/.claude/skills/`. When you invoke `/tdd`, Claude reads that file and uses its instructions to shape behavior for the current session. The file is **read-only instructions** — it does not accumulate state, write logs, or remember previous sessions.

This is by design. Skills are instruction templates, not running services. They are stateless in the same way a Bash alias is stateless: the alias is always the same, but the effect depends on what you pass it each time.

**What gets lost between sessions:**
- File modifications Claude made on your behalf (these DO persist — they are on disk)
- Claude's understanding of your project architecture (does NOT persist)
- Decisions you explained during the session (does NOT persist)
- Work-in-progress context ("we are on step 3 of 7") (does NOT persist)

## Fix 1: Use `supermemory` for Cross-Session Notes

The `supermemory` skill is the primary tool for cross-session persistence. It reads from and writes to a local file store on your machine.

**Saving state at end of session:**
```
/supermemory
Save: [project:myapp] Auth module uses JWT. Access tokens expire 15 min.
Refresh logic is in src/auth/refresh.ts. We chose JWT over sessions
for horizontal scaling. PR #142 adds OAuth, in review.
```

**Restoring state at start of next session:**
```
/supermemory
Load all notes tagged [project:myapp]. Summarize current state.
```

**Important: `supermemory` only works if you invoke it explicitly.** It does not auto-save. Build the habit of ending every significant session with a save command.

### Configure the storage path

By default `supermemory` writes to a path relative to your home directory. If that path ends up on a read-only or synced volume, saves will silently fail. Configure an explicit path in `.claude/settings.json`:

```json
{
  "skills": {
    "supermemory": {
      "storagePath": "/Users/yourname/.claude-memory"
    }
  }
}
```

Verify the path exists and is writable:
```bash
mkdir -p ~/.claude-memory
touch ~/.claude-memory/.test && rm ~/.claude-memory/.test && echo "Writable"
```

## Fix 2: Use `CLAUDE.md` for Project-Level Context

`CLAUDE.md` in the project root is read automatically at the start of every Claude Code session. It is not a skill — it is a context file that any skill can access.

Use it to document things that should be available in every session:

```markdown
# Project: MyApp

## Architecture
- Frontend: React + TypeScript in /apps/web
- API: Fastify in /apps/api, Node 22
- Database: PostgreSQL via Prisma

## Active Decisions
- Use Vitest for all tests — not Jest
- JWT auth: 15-min access tokens, 30-day refresh
- No Redux — use Zustand for state management

## Work in Progress (update manually)
- PR #142: OAuth provider — branch feature/oauth, in code review
- Issue #87: Refresh token race condition — root cause not yet found
```

Any skill you invoke during the session will have this context automatically. The `tdd` skill will know to use Vitest. The `frontend-design` skill will know the tech stack.

**Keep `CLAUDE.md` updated manually.** It is a living document, not auto-updated. After each significant session, add new decisions to it.

## Fix 3: Use File-Based State for In-Progress Tasks

For tasks that span multiple sessions — implementing a feature, writing a test suite, building a component library — instruct Claude to write progress to a dedicated file:

**End of session:**
```
/tdd
Before we close, write a progress summary to docs/tdd-progress.md.
Include: tests written so far, tests remaining, any blocked items.
```

**Start of next session:**
```
/tdd
Read docs/tdd-progress.md. Continue from where we left off.
Start with the first remaining test listed.
```

The file IS the state. Claude writes to it, reads from it, and updates it. This works for any skill.

**Example progress file format:**
```markdown
# TDD Progress: PaymentService

## Completed Tests
- [x] processPayment returns order ID on success
- [x] processPayment throws on declined card
- [x] refund validates amount against original charge

## Remaining Tests
- [ ] processPayment handles network timeout
- [ ] refund fails if order not found
- [ ] webhook signature validation

## Blocked
- Stripe test mode credentials needed for webhook tests
```

## Fix 4: Combine `supermemory` With `CLAUDE.md`

For teams or long-running projects, use both:

- `CLAUDE.md` — project-wide decisions and architecture (shared in git, readable by all)
- `supermemory` — personal session notes and task-specific context (local, not committed)

Workflow:
```
Session start:
1. CLAUDE.md loads automatically (project context)
2. /supermemory — load my personal notes for this project

Session end:
1. /supermemory — save any new decisions or progress
2. Update CLAUDE.md manually if a project-wide decision was made
```

## Fix 5: Automate Session-End Saves With a Hook

Claude Code supports hooks that run at session end. You can use a hook to automatically prompt for a `supermemory` save:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Session ended. Remember to save to supermemory.'"
          }
        ]
      }
    ]
  }
}
```

This is a reminder, not an automated save — Claude still needs to be given a save command before the session closes.

## Common Pitfalls

**Expecting skills to auto-save.** No Claude Code skill auto-saves state. You must explicitly instruct Claude to write to a file or call `supermemory` before the session ends.

**Closing the session before saving.** If you close the terminal window or the session times out, any unsaved in-session context is gone permanently. Save early, save often.

**`supermemory` writes failing silently.** Check the storage path is writable. On macOS, some directories need explicit permission grants in System Settings > Privacy & Security.

**Outdated `CLAUDE.md` causing confusion.** If `CLAUDE.md` says "PR #142 is in review" but it merged months ago, Claude gets incorrect context. Keep the file current.

## Summary: Choosing the Right Approach

| What you want to persist | Use |
|---|---|
| Architecture decisions (team-wide) | `CLAUDE.md` in project root |
| Personal session notes | `supermemory` skill |
| Task progress (tests written, files changed) | Explicit file (e.g., `docs/progress.md`) |
| All of the above | Combine all three |

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
