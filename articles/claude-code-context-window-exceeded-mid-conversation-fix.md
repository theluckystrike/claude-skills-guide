---
title: "Claude Code Context Window Exceeded"
description: "Fix Claude Code context window exceeded mid-conversation. Compact context and start focused sub-sessions. Step-by-step solution."
permalink: /claude-code-context-window-exceeded-mid-conversation-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Warning: Context window usage at 95% (190,000 / 200,000 tokens).
  Claude Code will begin compacting conversation history.

# Or:
Error: Context window exceeded. Cannot process this request.
  Total tokens (system + messages + tools): 201,347
  Maximum context window: 200,000 tokens
  Please start a new conversation or reduce your prompt.
```

## The Fix

1. **Use the /compact command to summarize and free context space**

```bash
# Inside Claude Code, type:
/compact

# Or with a focus hint:
/compact Focus on the current task: fixing the auth module
```

2. **Start a sub-session for the next task**

```bash
# Exit and start fresh, referencing only what you need
claude -p "Read src/auth/login.ts and fix the null pointer on line 42" --trust --yes

# Or use --continue to resume with compacted context
claude --continue
```

3. **Verify the fix:**

```bash
# Check context usage after compacting
# Inside Claude Code, the status bar shows token usage
# Expected: Context usage drops to 30-50% after /compact
```

## Why This Happens

Claude Code accumulates context with every message exchange: your prompts, Claude's responses, tool calls, tool results (file contents, command output), and internal system prompts. Reading large files, running commands with verbose output, and iterating on code changes all consume tokens rapidly. A single `cat` of a 5,000-line file can use 15,000+ tokens. After extended sessions with many file reads and edits, the 200K token window fills up, and Claude Code can no longer process new requests without dropping older context.

## If That Doesn't Work

- **Alternative 1:** Start a fresh session with a precise prompt that includes only the necessary context: files, error messages, and the exact task
- **Alternative 2:** Split large tasks into smaller, independent sessions — each with a narrow focus
- **Check:** Use `/cost` or check the status bar to see current token usage before starting expensive operations

## Prevention

Add to your `CLAUDE.md`:
```markdown
Use /compact proactively when context exceeds 60%. Avoid reading entire large files — use line ranges instead. Prefer focused sub-tasks over long sprawling sessions. Keep CLAUDE.md under 2K tokens to preserve context for actual work.
```

**Related articles:** [Context Window Management Guide](/claude-code-context-window-management-guide/), [Claude Code Slow Response Fix](/claude-code-slow-response-fix/), [Errors Atlas](/errors-atlas/)

## See Also

- [Claude API Billing Quota Exceeded — Fix (2026)](/claude-api-billing-quota-exceeded-mid-request-fix/)
- [Context Window Exceeded Mid-Conversation Fix](/claude-code-context-window-exceeded-mid-conversation-fix-2026/)
- [Conversation History OOM Crash Fix](/claude-code-conversation-history-oom-fix-2026/)
- [Claude Code Context Compression Data Loss — Fix (2026)](/claude-code-context-compression-data-loss-fix-2026/)
- [Fix Claude Code Losing Context in Sessions (2026)](/claude-code-loses-context-long-sessions-fix-2026/)
