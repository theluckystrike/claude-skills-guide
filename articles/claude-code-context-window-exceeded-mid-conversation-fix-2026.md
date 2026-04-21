---
title: "Context Window Exceeded Mid-Conversation Fix"
permalink: /claude-code-context-window-exceeded-mid-conversation-fix-2026/
description: "Run /compact to fix context window exceeded mid-conversation in Claude Code. Reduces token count and lets you continue without losing work."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: Context window limit exceeded (200,000 tokens).
Cannot process further messages. Please start a new conversation or compact the current one.
```

This appears mid-conversation when your accumulated messages, tool outputs, and file reads push past the model's context limit.

## The Fix

```bash
/compact
```

1. Type `/compact` in your Claude Code session to summarize the conversation history and free up token space.
2. If that is not enough, use `/compact` with a focus prompt: `/compact focus on the database migration task only`.
3. Continue your work in the same session with the reduced context.

## Why This Happens

Claude Code accumulates tokens from every message, tool call result, file read, and code output. Large file reads (especially `cat` on big files) and verbose tool outputs consume thousands of tokens per turn. Once the running total hits the 200K token limit, no new messages can be processed.

## If That Doesn't Work

Use `/clear` to reset the conversation entirely and start fresh:

```bash
/clear
```

Break your task into smaller pieces and work on one file at a time:

```bash
claude "Refactor only src/auth.ts — do not read other files"
```

Start a new session with a targeted CLAUDE.md that limits scope:

```bash
echo "Only work on files in src/api/" > CLAUDE.md
claude
```

## Prevention

```markdown
# CLAUDE.md rule
When reading files, use line ranges instead of full reads. Run /compact proactively after every 50 messages. Avoid reading files larger than 500 lines in a single operation.
```
