---
layout: default
title: "Claude Code /compact vs /clear: When to Use Each (2026)"
description: "Understand the difference between /compact and /clear in Claude Code. Learn when to compress context vs reset entirely, with impact on tokens and quality."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /claude-code-compact-vs-clear-when-to-use/
reviewed: true
categories: [guides]
tags: [claude, claude-code, compact, clear, context-management, tokens, optimization]
---

# Claude Code /compact vs /clear: When to Use Each (2026)

Two commands manage your conversation context in Claude Code: `/compact` compresses it, `/clear` erases it. Choosing wrong costs you either tokens (keeping bloated context) or time (re-explaining your project from scratch). This guide breaks down exactly what each command does, when to use which, how they affect token usage, and how they impact the quality of Claude's responses. Check your current token usage with `/cost` and explore all commands in the [Command Reference](/commands/).

## What /compact Does

`/compact` takes your entire conversation history and compresses it into a shorter summary. Claude reads through the conversation, identifies the key decisions, code changes, and context, then replaces the full history with a condensed version.

```
Before /compact:
- Full conversation: 85,000 tokens
- Contains: 45 messages, 12 file reads, 8 edits, debugging back-and-forth

After /compact:
- Compressed context: ~15,000 tokens
- Contains: Summary of decisions, current file states, active task description
```

### What /compact Preserves

- Key decisions made during the conversation
- Current state of files being edited
- The active task and its requirements
- Important constraints you mentioned
- Project conventions discussed

### What /compact Loses

- Exact wording of earlier messages
- Step-by-step debugging traces
- Alternative approaches that were considered and rejected
- Nuanced reasoning from earlier in the conversation
- Specific error messages that were resolved

## What /clear Does

`/clear` completely erases the conversation. Every message, decision, and context point is gone. Claude starts fresh as if you just opened a new session.

```
Before /clear:
- Full conversation: 85,000 tokens
- Claude knows: your project, conventions, current task, decisions made

After /clear:
- Context: 0 tokens (plus CLAUDE.md if it exists)
- Claude knows: only what is in CLAUDE.md and the project files
```

The only context that survives `/clear` is:
- The `CLAUDE.md` file (loaded automatically)
- Memory items (set via `/memory`)
- MCP server connections
- Permission settings

## Side-by-Side Comparison

| Aspect | /compact | /clear |
|--------|----------|--------|
| **Context preserved** | Yes (summarized) | No |
| **Token reduction** | 60-80% typically | 100% |
| **Task continuity** | Maintained | Lost |
| **Speed** | Takes 5-15 seconds to compress | Instant |
| **Token cost** | Costs tokens to generate summary | Zero cost |
| **Quality risk** | May lose nuance | Loses everything |
| **Best for** | Long sessions, same task | Task switching, fresh start |

## Decision Framework

### Use /compact When:

**1. You are running low on context but still working on the same task.**

```
Session: 2 hours debugging a payment flow
Context: 78,000 tokens
Task: Still fixing the same bug

→ /compact (preserves your debugging progress)
```

**2. Claude's responses are getting slower or less focused.**

Large context windows can cause Claude to lose track of the primary goal. Compressing refreshes focus while keeping key context.

**3. You want to reduce costs without losing progress.**

```
Before: 80,000 input tokens per message (~$0.24/message)
After /compact: 15,000 input tokens per message (~$0.045/message)
Savings: ~80% per subsequent message
```

**4. You are about to start a related sub-task.**

If you finished part 1 of a feature and are starting part 2, `/compact` carries forward the architectural decisions without the implementation details.

### Use /clear When:

**1. You are switching to a completely unrelated task.**

```
Previous task: Fixing CSS layout bugs
New task: Writing database migrations

→ /clear (old context is irrelevant and wastes tokens)
```

**2. Claude is stuck in a loop or giving incorrect responses.**

Sometimes the conversation history contains misleading context. A fresh start with `/clear` lets Claude approach the problem without bias from earlier failed attempts.

**3. You want to test Claude's response to a clean prompt.**

```
→ /clear
"Read src/auth.ts and identify any security vulnerabilities"

# Claude analyzes with fresh eyes, no prior assumptions
```

**4. The conversation has diverged too far from your goal.**

If you went down multiple rabbit holes and the conversation is a mess, `/clear` is faster than trying to redirect.

## Impact on Response Quality

### After /compact

Claude's responses remain contextually aware but may miss details that were in the compressed portions:

```
Good: "Based on our earlier decision to use JWT tokens, here is the refresh flow..."
Risk: "I don't recall the specific error message you mentioned — could you share it again?"
```

Mitigation: After running `/compact`, re-state any critical details that Claude might need.

### After /clear

Claude starts completely fresh. Quality is high for the new task but zero continuity exists:

```
Good: Fresh analysis without prior bias
Risk: "I don't have context about your project — could you describe the architecture?"
```

Mitigation: Keep your `CLAUDE.md` file updated with project context. Claude reads it automatically after `/clear`.

## Token Usage Patterns

Track your token usage to decide when to act:

```
/cost

# If you see:
# Input tokens: 100,000+ → Consider /compact
# Session cost: $2.00+ → Evaluate if /clear would be cheaper
# Cache hits: <50% → Context may be too large for effective caching
```

### Optimal Workflow

```
Start session
│
├── Work on task (0-50K tokens) → Keep going
│
├── 50K-80K tokens → Run /compact
│   └── Continue same task with compressed context
│
├── 80K+ tokens → Evaluate:
│   ├── Same task? → /compact
│   └── New task? → /clear
│
└── Stuck/confused? → /clear regardless of token count
```

## Practical Examples

### Long Refactoring Session

```
# Hour 1: Read codebase, plan refactoring
# Hour 2: Implement changes to 15 files
# Token count: 95,000

/compact
# Token count: ~20,000
# Claude remembers: which files changed, the refactoring pattern, remaining work
# Continue refactoring without re-explaining the plan
```

### Switching Between Features

```
# Feature A complete
/clear
# Start Feature B with clean context
# Claude reads CLAUDE.md for project context
```

### Debugging That Is Not Working

```
# 45 minutes of debugging, no solution found
# Claude keeps suggesting the same failed approaches

/clear
# Fresh start
"The payment webhook in src/stripe.ts returns 500 when processing subscription updates. Here is the error: [paste error]"
# Claude approaches the problem without bias from failed attempts
```

## Try It Yourself

Monitor your context usage and experiment with both commands. The [Command Reference](/commands/) includes detailed documentation for `/compact`, `/clear`, and every other slash command. Track your spending with the [Token Estimator](/token-estimator/) to see the direct cost impact.

<details>
<summary>Does /compact cost tokens to run?</summary>
Yes. Running /compact requires Claude to read and summarize the entire conversation, which costs tokens. Typically the compression cost is 5-10% of the original context size. The savings come from reduced input tokens on every subsequent message.
</details>

<details>
<summary>Can I undo /clear?</summary>
No. /clear is irreversible. The conversation history is permanently erased. If you think you might need to reference earlier context, use /compact instead or save important decisions to CLAUDE.md before clearing.
</details>

<details>
<summary>How often should I use /compact?</summary>
A good rule of thumb is to compact when your context exceeds 50,000-60,000 tokens (check with /cost). For complex tasks, you might compact 2-3 times in a long session. For simple tasks, you may never need it.
</details>

<details>
<summary>Does /compact affect MCP server connections?</summary>
No. MCP server connections, permissions, and memory items are not part of the conversation context. They persist through both /compact and /clear operations.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does /compact cost tokens to run?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Running /compact requires Claude to read and summarize the entire conversation, which costs tokens. Typically the compression cost is 5-10% of the original context size. The savings come from reduced input tokens on every subsequent message."
      }
    },
    {
      "@type": "Question",
      "name": "Can I undo /clear?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. /clear is irreversible. The conversation history is permanently erased. If you think you might need to reference earlier context, use /compact instead or save important decisions to CLAUDE.md before clearing."
      }
    },
    {
      "@type": "Question",
      "name": "How often should I use /compact?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "A good rule of thumb is to compact when your context exceeds 50,000-60,000 tokens (check with /cost). For complex tasks, you might compact 2-3 times in a long session. For simple tasks, you may never need it."
      }
    },
    {
      "@type": "Question",
      "name": "Does /compact affect MCP server connections?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. MCP server connections, permissions, and memory items are not part of the conversation context. They persist through both /compact and /clear operations."
      }
    }
  ]
}
</script>

## Related Guides

- [Command Reference](/commands/) — Full interactive command explorer
- [Token Estimator](/token-estimator/) — Calculate token usage and costs
- [Cost Optimization for Claude Code](/cost-optimization/) — Reduce your spending
- [Best Practices for Claude Code](/best-practices/) — Workflow optimization tips
- [Claude Code Configuration Guide](/configuration/) — Settings and preferences
