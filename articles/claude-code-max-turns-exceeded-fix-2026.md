---
title: "Claude Code Maximum Turns Exceeded Loop — Fix (2026)"
permalink: /claude-code-max-turns-exceeded-fix-2026/
description: "Increase the --max-turns flag or decompose task to fix agent turn limit. Break large multi-file operations into focused sequential subtasks."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Maximum turns exceeded (50). Agent loop terminated.
```

## The Fix

```bash
# Increase the turn limit for complex tasks using the --max-turns flag
claude --max-turns 100 "Refactor the entire auth module"

# Or set it via environment variable for the session:
export CLAUDE_MAX_TURNS=100
claude "Continue the refactoring task"
```

## Why This Works

Claude Code limits agent loops to 50 turns by default to prevent runaway execution and excessive API costs. Each tool call (read, edit, bash, search) counts as one turn. Complex tasks involving many files can legitimately require more than 50 operations. Raising the limit allows completion while still providing an upper bound.

## If That Doesn't Work

```bash
# Decompose the task into smaller scoped operations
claude "Refactor auth module step 1: extract token validation to src/auth/tokens.ts"
claude "Refactor auth module step 2: update all imports to use new tokens.ts"
claude "Refactor auth module step 3: add tests for extracted functions"

# Or use continue to resume where it left off:
claude "continue"
```

Breaking work into sub-tasks that each complete within 50 turns is more reliable than raising the limit indefinitely.

## Prevention

Add to your CLAUDE.md:
```
Decompose tasks requiring more than 30 file operations into sequential subtasks. Each subtask should target a single module or concern. Use explicit step numbering (step 1, step 2) to maintain progress across sessions.
```
