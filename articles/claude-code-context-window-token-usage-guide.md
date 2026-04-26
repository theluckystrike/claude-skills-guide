---
layout: default
title: "Claude Code Context Window: How It Affects Tokens (2026)"
description: "Understand Claude Code's 200K context window: how files load, context accumulates, and /compact triggers. Strategies for large codebases to stay under limits."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /claude-code-context-window-token-usage-guide/
reviewed: true
categories: [cost-optimization]
tags: [claude, claude-code, context-window, tokens, optimization]
---

# Claude Code Context Window: How It Affects Tokens

Claude Code operates within a 200,000-token context window. Every file read, tool result, and conversation exchange fills this window. When it overflows, Claude Code automatically compresses older context -- but that compression has a cost. Understanding the context window mechanics lets you keep sessions efficient and avoid hitting the wall mid-task. Use the [Token Estimator](/token-estimator/) to predict whether your task fits within a single context window.

## How the Context Window Fills

The context window holds everything Claude Code needs to process your request. Here is what occupies it, in order of loading:

```
┌──────────────────────────────────────────┐
│ System prompt + tool definitions   ~3,000│
│ CLAUDE.md contents                   ~500│
│ Conversation history (all messages) ~var  │
│ File contents from Read tool        ~var  │
│ Tool results (Bash, Grep, etc)      ~var  │
│ Current user message                ~var  │
├──────────────────────────────────────────┤
│ Available for model response       ~var  │
└──────────────────────────────────────────┘
Total capacity: 200,000 tokens
```

The system prompt and tool definitions consume a fixed ~3,000 tokens. Your CLAUDE.md adds another 200-1,000 tokens depending on length. Everything else is variable and accumulates over the conversation.

## Context Accumulation Over a Session

Each message in the conversation includes all previous messages. This creates exponential growth in token consumption:

| Message # | New Tokens | Cumulative Context | Cost This Message (Sonnet) |
|---|---|---|---|
| 1 | 5,000 | 5,000 | $0.015 |
| 3 | 4,000 | 18,000 | $0.054 |
| 5 | 3,500 | 35,000 | $0.105 |
| 8 | 4,000 | 65,000 | $0.195 |
| 10 | 3,000 | 85,000 | $0.255 |
| 15 | 3,500 | 140,000 | $0.420 |

By message 15, you are paying $0.42 per message even if the new content is only 3,500 tokens. The other 136,500 tokens are resent conversation history.

## When /compact Triggers

Claude Code triggers automatic compaction when the context window approaches capacity. You can also trigger it manually:

```bash
# Manual compaction -- do this after completing a sub-task
/compact

# What happens:
# 1. Full conversation history (e.g., 85,000 tokens)
# 2. Compressed to structured summary (~6,000-10,000 tokens)
# 3. Next message starts from compressed base
# 4. Details from older messages are lost (summarized)
```

Automatic compaction fires when context exceeds roughly 160,000 tokens (80% of the window). At that point, Claude Code summarizes the conversation to free space. The summary retains key decisions and code changes but drops intermediate reasoning and exploration steps.

## Model Choice and Context Limits

Different Claude models have different context windows and pricing:

```bash
# Sonnet (default) -- 200K context
claude --model sonnet
# Best for: daily development, most tasks
# Input: $3/MTok, Output: $15/MTok

# Opus -- 200K context
claude --model opus
# Best for: complex architecture, nuanced decisions
# Input: $15/MTok, Output: $75/MTok

# Haiku -- 200K context
claude --model haiku
# Best for: simple fixes, batch operations
# Input: $0.25/MTok, Output: $1.25/MTok
```

All models share the 200K window, but cost per token varies dramatically. A full-context Opus message at 180,000 input tokens costs $2.70. The same context on Haiku costs $0.045.

## Strategies for Large Codebases

A 100,000-line codebase could fill the entire context window if Claude Code tried to read everything. These strategies prevent context overflow:

### 1. Directory-Scoped Prompts

```bash
# Bad: Claude explores the entire codebase
"How does authentication work in this project?"

# Good: Scoped to a directory
"Explain the auth flow in src/auth/ -- focus on
 src/auth/middleware.ts and src/auth/jwt.ts"
```

### 2. Tiered .claudeignore

```bash
# .claudeignore for large codebases
# Tier 1: Always exclude (build artifacts)
node_modules/
dist/
.next/
coverage/

# Tier 2: Exclude generated code
src/generated/
prisma/generated/
*.g.ts

# Tier 3: Exclude rarely-needed modules
docs/archive/
scripts/one-off/
legacy/
```

### 3. Session Partitioning

Break large tasks into focused sessions:

```bash
# Session 1: Understand the current architecture
claude "Map the data flow from API routes in src/routes/
        to database queries in src/db/. Output a summary."
# Save the summary to a file

# Session 2: Implement changes (fresh context)
claude "Based on the architecture in ARCHITECTURE.md,
        add pagination to the /api/users endpoint.
        Modify src/routes/users.ts and src/db/users.ts."
```

### 4. Progressive File Loading

When you know Claude Code will need multiple files, feed them in order of relevance:

```bash
# First message: core files only
"Read src/payments/charge.ts and add retry logic
 for failed Stripe API calls."

# Only if needed: "Also check src/payments/types.ts
# for the error type definitions"
```

## Monitoring Context Usage

Track how much of the context window is consumed during a session:

```bash
# Claude Code shows token usage in the session footer
# Watch for:
# - Input tokens climbing steeply (context accumulation)
# - "Compacting conversation" messages (automatic trigger)
# - Slow responses (approaching context limit)

# Preventive action: run /compact when you see
# input tokens exceeding 80,000 in the session summary
```

## Try It Yourself

The [Token Estimator](/token-estimator/) models context window usage for your project. Enter your codebase size and typical task scope. It calculates how many messages you can exchange before hitting the context limit and recommends when to compact.

## Frequently Asked Questions

<details>
<summary>What happens when the context window is completely full?</summary>
Claude Code automatically compacts the conversation before hitting the absolute limit. If a single message plus its file reads exceed 200K tokens, Claude Code will fail to process it and return an error. This is rare -- it requires reading extremely large files (50,000+ lines) in a single operation. Split large file reads across multiple focused requests.
</details>

<details>
<summary>Does .claudeignore affect the context window?</summary>
Yes, significantly. Files in .claudeignore are never read into context, which directly reduces context window consumption. A typical Node.js project with node_modules excluded saves 50,000-100,000 potential context tokens. See <a href="/configuration/">Configuration</a> for .claudeignore setup.
</details>

<details>
<summary>Can I increase the context window beyond 200K?</summary>
No. The 200K token limit is set by the Claude model architecture. You cannot increase it through configuration. The strategies in this guide focus on using the available window efficiently rather than expanding it. The <a href="/commands/">Commands Reference</a> covers /compact and other context management tools.
</details>

<details>
<summary>Does /compact lose important information?</summary>
It can. Compaction summarizes the conversation, which means specific code snippets, exact error messages, and detailed reasoning from earlier messages may be reduced to brief summaries. Run /compact at natural task boundaries where earlier details are no longer needed, not mid-task when Claude Code is actively reasoning about a problem.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What happens when Claude Code's context window is completely full?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code automatically compacts the conversation before hitting the absolute limit. If a single message plus its file reads exceed 200K tokens, Claude Code will fail to process it and return an error. Split large file reads across multiple focused requests."
      }
    },
    {
      "@type": "Question",
      "name": "Does .claudeignore affect the Claude Code context window?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, significantly. Files in .claudeignore are never read into context, reducing context window consumption. A typical Node.js project with node_modules excluded saves 50,000-100,000 potential context tokens."
      }
    },
    {
      "@type": "Question",
      "name": "Can I increase Claude Code's context window beyond 200K tokens?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. The 200K token limit is set by the Claude model architecture and cannot be increased through configuration. Focus on using the available window efficiently with strategies like .claudeignore and /compact."
      }
    },
    {
      "@type": "Question",
      "name": "Does /compact lose important information in Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "It can. Compaction summarizes the conversation, which means specific code snippets and detailed reasoning may be reduced to brief summaries. Run /compact at natural task boundaries, not mid-task."
      }
    }
  ]
}
</script>

## Related Guides

- [Token Estimator](/token-estimator/) -- Predict context window usage for your project
- [Commands Reference](/commands/) -- Full /compact documentation and usage patterns
- [Model Selector](/model-selector/) -- Compare context costs across Claude models
- [Configuration Guide](/configuration/) -- .claudeignore and context management settings
- [Advanced Usage](/advanced-usage/) -- Power user strategies for context optimization
