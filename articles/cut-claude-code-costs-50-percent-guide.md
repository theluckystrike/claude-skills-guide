---
layout: default
title: "How to Cut Claude Code Costs by 50% Without Changing Models (2026)"
description: "8 proven techniques to halve your Claude Code spending without downgrading models. CLAUDE.md optimization, /compact, .claudeignore, and prompt engineering."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /cut-claude-code-costs-50-percent-guide/
reviewed: true
categories: [cost-optimization]
tags: [claude, claude-code, cost-optimization, tokens, efficiency]
---

# How to Cut Claude Code Costs by 50% Without Changing Models

Most Claude Code users overspend because of configuration waste, not model choice. A bloated CLAUDE.md, missing `.claudeignore`, and undisciplined session management can double your token consumption without improving output quality. These 8 techniques reduce token usage by 40-60% while keeping the same model and the same quality of results. Run each optimization, then verify the savings with the [Cost Calculator](/calculator/).

## 1. Trim Your CLAUDE.md to Under 2,000 Tokens

Your CLAUDE.md ships with every single API request. A 5,000-token system prompt costs you 5,000 input tokens per message -- even for simple one-line questions.

**Before (5,200 tokens):**

```markdown
# Project Overview
This is a Next.js 14 application using the App Router with TypeScript...
[3 paragraphs of architecture description]

# Coding Standards
We follow the Airbnb style guide with these modifications...
[2 paragraphs of style rules]

# Database
PostgreSQL with Prisma ORM...
[full schema description]

# Testing
Jest with React Testing Library...
[test setup instructions]
```

**After (1,800 tokens):**

```markdown
# Stack
Next.js 14 App Router, TypeScript strict, PostgreSQL/Prisma, Jest/RTL

# Rules
- No `any` types. Use `unknown` + type guards
- Server components by default. Client only for interactivity
- All DB queries through Prisma. No raw SQL
- Tests required for API routes and utils
```

**Savings:** 3,400 tokens per message. At 200 messages/day on Sonnet API, that saves $2.04/day ($61/month).

## 2. Use .claudeignore Aggressively

Without `.claudeignore`, Claude Code indexes and potentially loads large directories that add noise and cost.

```bash
# .claudeignore
node_modules/
.next/
dist/
build/
coverage/
*.lock
*.map
.git/
__pycache__/
*.pyc
.env*
*.log
```

**Savings:** Prevents thousands of irrelevant tokens from entering context. A `node_modules/` directory alone can inject 10,000+ tokens if Claude Code scans dependency files.

## 3. Run /compact Every 15-20 Turns

Conversation history accumulates linearly. After 20 turns, your history may contain 30,000+ tokens of previous messages that are mostly redundant.

```
# Inside Claude Code:
/compact
```

The `/compact` command compresses conversation history into a summary, typically reducing 30,000 tokens to 3,000-5,000. Run it proactively, not when you hit the limit.

**Savings:** 25,000+ tokens removed per compaction. Over a 2-hour session with 3 compactions, saves ~75,000 tokens ($0.23 on Sonnet, $1.13 on Opus).

## 4. Start New Sessions for New Tasks

Every message carries the full conversation history. If you finished a debugging task and start a code review in the same session, the debugging history inflates every review message.

```bash
# Start fresh for each distinct task
claude --new
```

**Rule of thumb:** New session when changing task category (debug -> review -> write -> refactor).

**Savings:** Eliminates 5,000-50,000 tokens of irrelevant history per session. Most developers carry 2-3 stale task contexts in a single session.

## 5. Reference Files by Path Instead of Pasting

Pasting file contents into your prompt adds the full text to input tokens. Referencing by path lets Claude Code read only what it needs.

**Expensive:**
```
Here is my component:
[pastes 200 lines of code]
Fix the TypeScript error on line 45.
```

**Cheap:**
```
Fix the TypeScript error on line 45 of src/components/Dashboard.tsx
```

**Savings:** 500-5,000 tokens per message depending on file size. Claude Code reads the file itself using the Read tool, consuming tokens only once instead of carrying the pasted content through the entire conversation.

## 6. Prune Unused MCP Tools

Each MCP tool definition consumes 200-400 tokens per message. If you have 10 MCP tools installed but only use 3 regularly, the other 7 cost you 1,400-2,800 wasted tokens per message.

```bash
# List all configured MCP tools
claude mcp list

# Remove tools you don't use daily
claude mcp remove unused-tool-name
```

**Savings:** 200-400 tokens per removed tool, per message. Removing 5 unused tools at 300 tokens each saves 1,500 tokens/message, or $0.90/day on Sonnet at 200 messages.

## 7. Write Precise Prompts

Vague prompts cause Claude Code to read more files, run more tools, and generate longer responses -- all of which consume tokens.

**Expensive prompt:**
```
Something is wrong with the user auth. Can you look into it?
```
Claude reads 10+ files, runs multiple greps, generates a lengthy analysis.

**Efficient prompt:**
```
The login function in src/auth/login.ts returns undefined instead of the user object when the email contains a plus sign. Fix the email validation regex on line 23.
```
Claude reads 1 file, fixes 1 line, done.

**Savings:** 50-80% fewer tool calls per task. Each tool call adds 500-2,000 tokens round-trip.

## 8. Use Model Routing

Not every task needs your most expensive model. Use Haiku for simple operations and Sonnet for standard work. Reserve Opus for tasks that genuinely require it.

```bash
# Quick formatting fix — use Haiku
claude --model claude-haiku "Fix the indentation in src/utils.ts"

# Standard refactoring — use Sonnet
claude --model claude-sonnet-4-20250514 "Refactor the auth module to use async/await"

# Complex architecture — use Opus
claude --model claude-opus-4-20250514 "Design the migration strategy from REST to GraphQL for the user service"
```

**Savings:** Haiku is 12x cheaper than Sonnet and 60x cheaper than Opus per token. Routing 50% of your tasks to Haiku cuts your average cost by 40%.

Check the [Token Estimator](/token-estimator/) to see exactly how many tokens each operation consumes.

## Try It Yourself

Apply all 8 optimizations and verify the savings. The **[Cost Calculator](/calculator/)** lets you input your usage pattern, model mix, and CLAUDE.md size, then shows your monthly cost before and after optimization.

**[Try the Calculator -->](/calculator/)**

## Common Questions

<details><summary>Which optimization has the biggest impact?</summary>
CLAUDE.md trimming, because it affects every single message. A 3,000-token reduction saves more than any other single change over a month of usage. Start there before touching anything else.
</details>

<details><summary>Does /compact lose important context?</summary>
Compact preserves the essential facts and decisions from your conversation but discards verbatim message text. For most workflows, this is fine. If you are mid-way through a specific file edit, finish that edit before running /compact.
</details>

<details><summary>Can I automate model routing?</summary>
Not natively in Claude Code yet. However, you can create shell aliases: <code>alias ch="claude --model claude-haiku"</code>, <code>alias cs="claude --model claude-sonnet-4-20250514"</code>, <code>alias co="claude --model claude-opus-4-20250514"</code>. Use the appropriate alias for each task type.
</details>

<details><summary>How do I measure my current token usage?</summary>
Check <code>~/.claude/logs/</code> for session logs that include <code>input_tokens</code> and <code>output_tokens</code> per request. Sum them up for a session to see total consumption. The Cost Calculator can then convert that to dollars.
</details>

<script type="application/ld+json">
{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[
{"@type":"Question","name":"Which optimization has the biggest impact?","acceptedAnswer":{"@type":"Answer","text":"CLAUDE.md trimming has the biggest impact because it affects every single message. A 3,000-token reduction saves more than any other single change over a month."}},
{"@type":"Question","name":"Does /compact lose important context?","acceptedAnswer":{"@type":"Answer","text":"Compact preserves essential facts and decisions but discards verbatim message text. Finish any in-progress file edits before running /compact."}},
{"@type":"Question","name":"Can I automate model routing?","acceptedAnswer":{"@type":"Answer","text":"Not natively yet. Create shell aliases like alias ch='claude --model claude-haiku' for quick access to different models per task type."}},
{"@type":"Question","name":"How do I measure my current token usage?","acceptedAnswer":{"@type":"Answer","text":"Check ~/.claude/logs/ for session logs with input_tokens and output_tokens per request. Sum them for total consumption per session."}}
]}
</script>

## Related Guides

- [Claude Code Pricing Explained](/claude-code-pricing-every-plan-model-explained/)
- [Token Estimator Tool](/token-estimator/)
- [CLAUDE.md Generator](/generator/)
- [Commands Reference](/commands/)
- [Cost Calculator](/calculator/) -- estimate monthly spend
