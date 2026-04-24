---
layout: default
title: "Fix: Claude Code High Token Usage"
description: "Claude Code burning through tokens on simple queries? Understand why context accumulates and how to control token consumption."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-high-token-usage/
reviewed: true
score: 8
categories: [troubleshooting]
tags: [claude-code, performance, tokens, costs, context-window]
geo_optimized: true
---

# Fix: Claude Code Unexpected High Token Usage

## The Error

You ask Claude Code a few simple questions and discover it consumed far more tokens than expected. Simple queries should not cost much, but context accumulation makes each subsequent message more expensive.

## Quick Fix

1. Check your token usage: `/cost` in Claude Code
2. Use `/compact` to reduce context size
3. Switch to a smaller model for simple queries: `/model sonnet`

## What Causes This

Token consumption in Claude Code is driven by **input tokens** (the full conversation context sent with every request), not just output tokens.

### 1. Full Context Sent Every Request

Every message you send includes the entire conversation history plus the system prompt plus any file contents that have been read in the session. Each subsequent message sends everything again. If Claude read files or generated long responses, the context grows rapidly.

### 2. Extended Thinking Tokens

Extended thinking is enabled by default because it improves performance on complex planning and reasoning tasks. Thinking tokens are billed as output tokens, and the default budget can be tens of thousands of tokens per request depending on the model. For simpler tasks where deep reasoning is not needed, this is wasted spend.

### 3. Model Pricing

Token costs vary significantly by model:

| Model | Input (per MTok) | Output (per MTok) |
|-------|-------------------|-------------------|
| Opus 4.6 | $5 | $25 |
| Sonnet 4.6 | $3 | $15 |
| Haiku 4.5 | $1 | $5 |

Using Opus for simple questions costs significantly more than Sonnet or Haiku.

## Full Solution

### 1. Check Current Usage

```text
/cost
```

This shows your token consumption for the current session. For API users, this reflects actual billing. For Max and Pro subscribers, use `/stats` to view usage patterns instead.

### 2. Compact Regularly

```text
/compact
```

This summarizes the conversation history to reduce the context sent with each message. You can add focus instructions:

```text
/compact Focus on code samples and API usage
```

Run `/compact` after every major task completion or when switching topics.

### 3. Use the Right Model

For simple questions that do not require deep reasoning:

```text
/model sonnet
```

Sonnet handles most coding tasks well at lower cost. Reserve Opus for complex architectural decisions or multi-step reasoning.

### 4. Control Thinking Budget

Reduce the effort level for simple queries:

```text
/effort low
```

The `/effort` command accepts `low`, `medium`, `high`, `max`, and `auto`. The `low`, `medium`, and `high` settings persist across sessions. You can also set the `MAX_THINKING_TOKENS` environment variable to cap thinking token usage:

```bash
export MAX_THINKING_TOKENS=8000
```

### 5. Start New Sessions for New Topics

Instead of continuing a long conversation that has accumulated context:

```bash
# Start a new session for a new topic
claude

# Use /clear to reset context without exiting
/clear
```

Use `/clear` when switching to unrelated work. Stale context wastes tokens on every subsequent message.

### 6. Minimize File Reads

Be specific about what you want Claude to look at:

```text
# Instead of: "Look at my project and tell me about the architecture"
# Try: "Read src/index.ts and explain the main function"
```

Each file read adds its entire content to the conversation context for all subsequent messages.

### 7. Use Subagents for Verbose Operations

Running tests, fetching documentation, or processing log files can consume significant context. Delegate these to subagents so the verbose output stays in the subagent's context while only a summary returns to your main conversation.

## Prevention

- **Compact after every task**: run `/compact` when switching topics
- **Use `/model sonnet`** for simple questions, switch to Opus only for complex reasoning
- **Start fresh sessions** for new topics rather than continuing stale conversations
- **Set effort to low or medium** for routine tasks with `/effort`
- **Be specific with file reads** -- do not let Claude scan your entire project
- **Move specialized instructions to skills** -- keep CLAUDE.md under 200 lines

---

---

<div class="mastery-cta">

Claude Code is expensive because it's reading your entire codebase every time. A CLAUDE.md tells it what matters upfront — architecture, conventions, boundaries. Less scanning. Fewer wrong turns. Lower bills.

I spend $200+/month on Claude subs. These configs are how I keep the output worth the cost.

**[Get the configs →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-perf&utm_campaign=claude-code-high-token-usage)**

$99 once. Pays for itself in saved tokens within a week.

</div>

## Related Guides

- [Fix: Claude Code Slow Response Times](/claude-code-slow-response-fix/)
- [Claude Code Cost for Agencies and Consultancies](/claude-code-cost-for-agencies-and-consultancies/)
- [Claude Code Cost per Project Estimation Calculator Guide](/claude-code-cost-per-project-estimation-calculator-guide/)
- [Fix: Claude Code Timeout 2m Bash Command Limit](/claude-code-timeout-2m-fix/)



- [Claude rate exceeded error fix](/claude-rate-exceeded-error-fix/) — Fix Claude rate exceeded and rate limit errors

- [Claude AI rate exceeded error fix](/claude-ai-rate-exceeded-error-fix/) — Fix the Claude AI rate exceeded error message

- [Claude Code router guide](/claude-code-router-guide/) — How model routing affects token costs