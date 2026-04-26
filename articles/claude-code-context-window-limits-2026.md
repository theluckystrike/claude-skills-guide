---
layout: default
title: "Claude Code Context Window Limits (2026)"
description: "Claude Code context window sizes for every model, what counts toward the limit, and strategies when you hit the ceiling."
permalink: /claude-code-context-window-limits-2026/
date: 2026-04-26
---

# Claude Code Context Window Limits (2026)

The context window is the total amount of text Claude can process in a single API call. Everything — your message, conversation history, system prompts, tool definitions, and file contents — must fit within this window. When you exceed it, Claude either truncates older messages or refuses to process the request.

Understanding these limits is essential for planning work sessions, especially long ones. Use the [Token Estimator](/token-estimator/) to check how much of your context window you are consuming at any point.

## Context Window Sizes by Model

As of April 2026, these are the context window limits for models available in Claude Code:

| Model | Context Window | Effective Usable* |
|-------|---------------|-------------------|
| Claude Opus 4 | 200,000 tokens | ~150,000 tokens |
| Claude Sonnet 4 | 200,000 tokens | ~160,000 tokens |

*Effective usable is lower than the raw limit because system prompts, tool definitions, and output token reservation consume 20-30% of the window.

### Why effective usable is less than advertised

The 200,000 token context window is the total capacity, but significant portions are reserved:

- **System prompt:** 2,000-5,000 tokens (Anthropic's instructions to Claude Code)
- **Tool definitions:** 3,000-8,000 tokens (all registered tools and MCP servers)
- **CLAUDE.md and memory:** 500-3,000 tokens (your project context)
- **Output reservation:** ~4,000 tokens (space reserved for Claude's response)

This means your conversation history and file contents share roughly 150,000-160,000 tokens, not the full 200,000.

## What Counts Toward the Limit

Every piece of data in the API request counts toward the context window:

### Always present (every call)
- Anthropic system prompt
- Your CLAUDE.md file
- Memory entries
- Tool definitions for all available tools
- Permission configuration

### Grows over time
- Full conversation history (all messages sent and received)
- File contents from Read operations (stay in context as tool results)
- Search results from Grep and Glob operations
- Output from Bash commands

### Present only during that call
- Your current message
- Claude's response (counts toward the limit for that specific call)

The critical insight is that conversation history grows monotonically until you compact or clear. After 30 exchanges, you might have 80,000+ tokens of history, leaving less than half the window for new work.

## How to Know When You Are Near the Limit

### Check with /cost

```
/cost
```

This shows your current token usage including a rough percentage of context consumed. If you are above 60%, response quality may start degrading as Claude prioritizes fitting within the window.

### Warning signs

- Claude's responses become shorter or less detailed
- Claude "forgets" things you discussed earlier in the session
- Response latency increases noticeably
- Claude explicitly warns about context length

### Use the Token Estimator

The [Token Estimator](/token-estimator/) lets you check token counts for specific text. Paste your CLAUDE.md to see its overhead, or paste a file you are about to have Claude read to predict the context impact.

## What Happens When You Hit the Limit

Claude Code handles context overflow through truncation. Older messages at the beginning of the conversation are dropped first, preserving your most recent exchanges. This means:

1. You lose context about decisions made early in the session
2. Claude may contradict earlier guidance because it no longer sees it
3. Code referenced early in the conversation disappears from context

This silent truncation is worse than hitting a hard error because you may not realize context has been lost. Proactive management prevents this entirely.

## Strategies for Managing the Context Window

### Strategy 1: Proactive compacting

The highest-impact strategy. Run `/compact` before you hit the limit:

```
/compact focus on the current implementation task
```

Compact at 40% usage, not 80%. This keeps response quality high and prevents the gradual degradation that happens as context fills up. See the [context window management guide](/claude-code-context-window-management-2026/) for detailed timing strategies.

### Strategy 2: Session segmentation

Break large tasks into focused sessions:

1. Architecture decisions (Session 1, then `/clear`)
2. Implementation (Session 2, then `/clear`)
3. Testing (Session 3, then `/clear`)

Each session starts fresh with full context available. Document key decisions in your CLAUDE.md or in code comments so they persist across sessions.

### Strategy 3: Minimize file reads

Every file Claude reads stays in context. Guide Claude to specific files:

```
Read only src/api/auth.ts — the bug is in the validateToken function around line 45
```

Do not let Claude explore your codebase broadly unless necessary. Each exploratory read consumes context that could be used for actual work.

### Strategy 4: Use the right model

Both Opus and Sonnet have 200K context windows, but Sonnet uses fewer tokens for its system overhead, giving you slightly more usable space. For routine tasks, Sonnet is the better choice on multiple dimensions.

### Strategy 5: Lean CLAUDE.md

Your CLAUDE.md repeats on every call. Keep it under 300 words (roughly 400 tokens). That saves 400 tokens per call, which across 50 calls in a session is 20,000 tokens of recovered context space.

## Try It Yourself

Open the [Token Estimator](/token-estimator/) and run this experiment:

1. Paste your CLAUDE.md file and note the token count
2. Paste a typical source file from your project
3. Multiply the CLAUDE.md tokens by 50 (a typical session's API calls)
4. Compare that to the source file tokens

This shows you how project context overhead compares to actual work content. Most developers are surprised by how much CLAUDE.md costs over a full session.

## Context Window Planning Table

| Session Type | Expected Duration | Recommended Compact Frequency |
|-------------|-------------------|-------------------------------|
| Quick bug fix | 5-10 minutes | Not needed |
| Feature implementation | 30-60 minutes | Every 15-20 messages |
| Architecture review | 60-120 minutes | Every 10-15 messages |
| Large refactor | 2+ hours | Every 10 messages, or segment into sessions |

## Frequently Asked Questions

**Can I increase the context window size?**

No. The context window is a model-level limit set by Anthropic. You cannot configure a larger window. Your only option is to manage what goes into it more efficiently.

**Does the context window reset between sessions?**

Yes. Starting a new Claude Code session (or running `/clear`) resets the conversation history. Only CLAUDE.md, memory entries, and tool definitions carry over.

**What is the difference between context window and token budget?**

The context window is the maximum tokens per API call (input + output combined). A token budget is a spending limit you set to control costs across multiple calls and sessions. They are related but distinct concepts.

**Why does Claude forget things I said earlier?**

Most likely because context overflow caused truncation of older messages. Check with `/cost` — if you are near the limit, compact or clear to prevent further loss.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Can I increase the context window size?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. The context window is a model-level limit set by Anthropic. You cannot configure a larger window. Your only option is to manage what goes into it more efficiently."
      }
    },
    {
      "@type": "Question",
      "name": "Does the context window reset between sessions?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Starting a new Claude Code session or running /clear resets conversation history. Only CLAUDE.md, memory entries, and tool definitions carry over."
      }
    },
    {
      "@type": "Question",
      "name": "What is the difference between context window and token budget?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The context window is the maximum tokens per API call. A token budget is a spending limit you set to control costs across multiple calls and sessions. They are related but distinct."
      }
    },
    {
      "@type": "Question",
      "name": "Why does Claude forget things I said earlier?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Most likely because context overflow caused truncation of older messages. Check with /cost and if you are near the limit, compact or clear to prevent further loss."
      }
    }
  ]
}
</script>



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

- [Token Estimator](/token-estimator/) — Check token counts and context usage
- [Context Window Management](/claude-code-context-window-management-2026/) — Full management strategies
- [Token Usage Explained](/claude-code-token-usage-explained-2026/) — How tokens work
- [Reduce Token Usage](/reduce-claude-code-token-usage-2026/) — Cut consumption by 50%+
- [Context Window Full Fix](/claude-code-context-window-full-in-large-codebase-fix/) — Emergency recovery
