---
title: "Extended Thinking Budget Exceeded — Fix (2026)"
permalink: /claude-code-extended-thinking-budget-exceeded-fix-2026/
description: "Increase thinking_budget in settings to 32768 tokens with claude config set. Fixes the extended thinking token allocation mismatch error cleanly."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Extended thinking budget exceeded: used 32768 tokens of 16384 allowed
```

## The Fix

```bash
# Increase the extended thinking token budget
claude config set thinking_budget 32768
```

## Why This Works

[Sequential thinking in Claude Code](/sequential-thinking-claude-code-guide/) allows Claude to reason through complex problems before responding. When the allocated budget is too low, Claude hits the ceiling mid-reasoning and the request fails. Setting the budget to 32768 tokens gives sufficient room for multi-step reasoning while keeping costs predictable.

## If That Doesn't Work

```bash
# Disable extended thinking entirely if budget errors persist
claude config set thinking_budget 0
# Or break your prompt into smaller, simpler sub-tasks
# that require less reasoning depth
```

If you are on a rate-limited plan, extended thinking tokens count toward your per-minute token limit. Reduce concurrent sessions or wait for the rate window to reset before retrying with a higher budget. You can also check current token usage with `claude config get thinking_budget` to confirm the new value persisted — some workspace-level configs override global settings.

## Prevention

Add to your CLAUDE.md:
```
Extended thinking budget is set to 32768 tokens. For tasks requiring deep analysis (architecture decisions, complex refactors), use explicit step-by-step instructions to reduce reasoning depth needed.
```


## Related

- [Claude Sonnet 4.5 model guide](/claude-sonnet-4-5-20250929-model-guide/) — Guide to the claude-sonnet-4-5-20250929 model and its capabilities

