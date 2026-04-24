---
title: "Context Window Exceeded — Fix (2026)"
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

## See Also

- [Claude Code Context Window Exceeded Mid-Chat — Fix (2026)](/claude-code-context-window-exceeded-mid-conversation-fix/)
- [Claude API Billing Quota Exceeded — Fix (2026)](/claude-api-billing-quota-exceeded-mid-request-fix/)
- [Claude Code Context Compression Data Loss — Fix (2026)](/claude-code-context-compression-data-loss-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `ContextWindowExceeded: input exceeds maximum context length`
- `Error: message content too large`
- `TokenLimitExceeded: reduce input size`
- `TokenLimitExceeded: max tokens reached`
- `Error: output truncated at max_tokens`

## Frequently Asked Questions

### What is the context window limit?

Claude's context window is 200,000 tokens. This includes system prompts, conversation history, file contents read during the session, and tool results. When the total exceeds this limit, Claude Code must compress or drop earlier context.

### How does context compression work?

When approaching the context limit, Claude Code summarizes earlier messages to free space for new content. This compression is lossy — specific code snippets and exact line numbers from early in the conversation may be approximated. Starting a fresh conversation avoids compression artifacts.

### How do I work with large codebases without exceeding the context?

Be specific about which files to read. Instead of asking Claude Code to 'understand the whole codebase,' point it to the specific files relevant to your task. Use the Glob and Grep tools to find relevant code before reading it.

### What causes token count mismatches?

Token counts are estimated before sending a request and precisely calculated on the server. The estimation uses a fast local tokenizer that may differ slightly from the server's tokenizer. Small discrepancies (1-3%) are normal and do not affect functionality.
