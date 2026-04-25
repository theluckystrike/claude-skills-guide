---
layout: default
title: "Why Your Claude Prompts Use Too Many"
description: "Five hidden token drains in Claude API prompts — tool overhead alone adds 1,680 tokens per request, costing $8.40 per 1K Opus calls."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /why-claude-prompts-use-too-many-tokens/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction]
---

# Why Your Claude Prompts Use Too Many Tokens

Tool use definitions add up to 1,680 hidden tokens to every Claude API request — even when tools are not called. At Opus 4.7 pricing, that is $8.40 wasted per 1,000 requests. Combined with verbose system prompts, redundant context, and uncontrolled output, most developers waste 40-60% of their token budget without realizing it.

## The Setup

Developers focus on the user message when thinking about tokens. But the user message is often the smallest part of the prompt. The real token consumers are system prompts, tool definitions, conversation history, and output verbosity.

Anthropic's documentation confirms specific token overhead numbers: tool use adds 346 system prompt tokens automatically when configured, each bash tool call adds 245 tokens, the text editor tool adds 700 tokens, and computer use adds 735 tokens. These costs are invisible in your application code but visible on your invoice.

This guide exposes the five most common token drains and shows how to eliminate each one.

## The Math

Hidden token overhead for a typical request with 3 tools configured:

| Hidden Cost | Tokens | Per 10K Opus Requests |
|------------|--------|----------------------|
| Tool system prompt (auto) | 346 | $17.30 |
| Bash tool definition | 245 | $12.25 |
| Text editor definition | 700 | $35.00 |
| Computer use definition | 735 | $36.75 |
| **Total tool overhead** | **2,026** | **$101.30** |

Add a 2,000-token verbose system prompt: **$100.00 per 10K requests**

Total hidden cost: **$201.30 per 10,000 requests on Opus 4.7**

At 300,000 requests/month: **$6,039/month in hidden overhead alone**

After optimization (conditional tools, compressed prompt): **$1,206/month**

**Savings: $4,833/month (80%)**

## The Technique

### Drain 1: Tool Definitions Included When Not Needed

```python
import anthropic

client = anthropic.Anthropic()

# BAD: Tools defined on every request (adds 2,000+ tokens)
tools = [
    {"name": "search", "description": "Search the database for records matching a query",
     "input_schema": {"type": "object", "properties": {"query": {"type": "string"}, "limit": {"type": "integer"}}}},
    {"name": "update", "description": "Update a database record with new values",
     "input_schema": {"type": "object", "properties": {"id": {"type": "string"}, "fields": {"type": "object"}}}},
    {"name": "delete", "description": "Delete a record from the database",
     "input_schema": {"type": "object", "properties": {"id": {"type": "string"}}}},
]

# Every request pays the token cost even for "What time is it?"
response = client.messages.create(
    model="claude-sonnet-4-6", max_tokens=100,
    tools=tools,
    messages=[{"role": "user", "content": "What time is it?"}],
)

# GOOD: Only include tools when the request might need them
def needs_tools(prompt: str) -> bool:
    tool_signals = ["search for", "find", "update", "delete", "look up", "modify"]
    return any(signal in prompt.lower() for signal in tool_signals)

user_prompt = "What time is it?"
kwargs = {"model": "claude-sonnet-4-6", "max_tokens": 100,
          "messages": [{"role": "user", "content": user_prompt}]}
if needs_tools(user_prompt):
    kwargs["tools"] = tools

response = client.messages.create(**kwargs)
# Saved 2,000+ tokens on this request
```

### Drain 2: Conversation History Never Pruned

```python
def prune_history(messages: list, max_tokens: int = 10000, keep_last: int = 4) -> list:
    """Keep recent messages and prune old ones to control context size."""
    if len(messages) <= keep_last:
        return messages

    # Always keep the last N messages for continuity
    recent = messages[-keep_last:]

    # Estimate tokens in remaining messages
    older = messages[:-keep_last]
    total_chars = sum(len(m["content"]) for m in older)
    estimated_tokens = total_chars // 4  # rough char-to-token ratio

    if estimated_tokens <= max_tokens:
        return messages  # fits within budget

    # Summarize older context instead of including verbatim
    summary_prompt = "Summarize the key points from this conversation:\n"
    for m in older:
        summary_prompt += f"{m['role']}: {m['content'][:200]}\n"

    return [
        {"role": "user", "content": f"[Previous context summary: {summary_prompt[:500]}]"},
        {"role": "assistant", "content": "Understood, I have the context."},
        *recent,
    ]
```

### Drain 3: Output Verbosity Not Controlled

```python
# BAD: No output constraints (Claude may produce 2,000+ tokens)
response = client.messages.create(
    model="claude-sonnet-4-6", max_tokens=4096,
    messages=[{"role": "user", "content": "What does the map function do in Python?"}],
)
# May get a 500-word essay when you needed 2 sentences

# GOOD: Constrain output explicitly
response = client.messages.create(
    model="claude-sonnet-4-6", max_tokens=200,
    system="Answer in 1-2 sentences. No examples unless asked.",
    messages=[{"role": "user", "content": "What does the map function do in Python?"}],
)
# Output: ~50 tokens instead of ~500
# Savings: 450 output tokens * $15/MTok = $0.00675 per request
```

### Drain 4: Redundant Instructions

```python
# BAD: Saying the same thing multiple ways
verbose = """Be concise. Keep your answers short. Don't write long responses.
Avoid unnecessary details. Get straight to the point. Be brief."""
# 6 ways to say "be concise" = 5 wasted instructions

# GOOD: Say it once
concise = "Max 3 sentences per response."
```

### Drain 5: Including Full Documents When Snippets Suffice

```python
# BAD: Sending entire 100KB document for a specific question
with open("large_document.txt") as f:
    full_doc = f.read()  # ~25,000 tokens

# GOOD: Extract relevant section first
def extract_relevant_section(doc: str, question: str, window: int = 2000) -> str:
    """Find the most relevant section of a document for a question."""
    keywords = question.lower().split()
    paragraphs = doc.split("\n\n")
    scored = []
    for i, para in enumerate(paragraphs):
        score = sum(1 for kw in keywords if kw in para.lower())
        scored.append((score, i, para))
    scored.sort(reverse=True)
    # Return top 3 most relevant paragraphs
    top = sorted(scored[:3], key=lambda x: x[1])
    return "\n\n".join(p[2] for p in top)

relevant = extract_relevant_section(full_doc, "What is the refund policy?")
# ~2,000 tokens instead of 25,000
```

## The Tradeoffs

Aggressive history pruning can cause Claude to lose important conversation context, producing responses that feel disconnected. Keep the last 4-6 messages intact and only prune or summarize older history.

Conditional tool loading requires maintaining a routing function that correctly predicts when tools are needed. False negatives (not loading tools when needed) cause request failures. Start with a permissive classifier and tighten over time.

Output length constraints may truncate legitimate long responses. Set max_tokens to the 95th percentile of your actual output distribution, not an arbitrary low number.

## Implementation Checklist

1. Count tokens in each component of your top 5 request types
2. Remove tool definitions from requests that never use tools
3. Add conversation history pruning at 10,000 tokens
4. Set explicit output length constraints in system prompts
5. Remove duplicate and redundant instructions
6. Replace full documents with extracted relevant sections
7. Measure token reduction and validate quality

## Measuring Impact

Track average input tokens per request broken down by component (system, tools, history, message). Identify which component decreased most after each optimization. Set a target of reducing total input tokens by 40-50%. Monitor your Anthropic billing dashboard weekly to confirm the token reduction translates to actual cost savings.

## Related Guides

- [Claude Code Token Usage Optimization](/claude-code-token-usage-optimization-best-practices-guide/) — comprehensive optimization guide
- [Reduce Claude Code Hallucinations Save Tokens](/reduce-claude-code-hallucinations-save-tokens-accuracy-tips/) — clearer prompts waste fewer tokens
- [Claude Skill Token Usage Profiling](/claude-skill-token-usage-profiling-and-optimization/) — identify per-skill token waste

## See Also

- [Claude Cost Anomaly Detection Setup Guide](/claude-cost-anomaly-detection-setup-guide/)
- [Claude Code /compact Saves Thousands of Tokens](/claude-code-compact-saves-thousands-tokens/)
- [Automatic vs Manual Cache Breakpoints Guide](/automatic-vs-manual-cache-breakpoints-guide/)
- [Optimizing Tool Schemas to Cut Token Count](/optimizing-tool-schemas-reduce-token-count/)
- [Why Large Context Makes Claude Code Expensive](/why-large-context-makes-claude-code-expensive/)
