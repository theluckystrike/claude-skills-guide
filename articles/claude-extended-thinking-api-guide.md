---
layout: default
title: "Claude Extended Thinking API Guide (2026)"
description: "Implement Claude extended thinking for enhanced reasoning. Covers budget_tokens, display options, tool use integration, and multi-turn thinking continuity."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-extended-thinking-api-guide/
reviewed: true
score: 7
categories: [guides]
tags: [claude-api, sdk-python, sdk-typescript, extended-thinking]
geo_optimized: true
---

# Claude Extended Thinking API Guide

Extended thinking gives Claude a dedicated reasoning step before responding. This improves accuracy on complex tasks like math, coding, and multi-step analysis. All Claude models support it.

## Quick Fix

Enable extended thinking with one parameter:

```python
import anthropic

client = anthropic.Anthropic()

response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000},
 messages=[{"role": "user", "content": "What is 127 * 389?"}]
)

for block in response.content:
 if block.type == "thinking":
 print(f"Thinking: {block.thinking}")
 elif block.type == "text":
 print(f"Answer: {block.text}")
```

## What You Need

- Any Claude model (Opus 4.6, Sonnet 4.6, Haiku 4.5, etc.)
- `budget_tokens >= 1024` and `budget_tokens < max_tokens`

## Full Solution

### Basic Extended Thinking

```python
import anthropic

client = anthropic.Anthropic()

response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000},
 messages=[{"role": "user", "content": "Explain why the sky is blue, step by step."}]
)

for block in response.content:
 if block.type == "thinking":
 print("=== Thinking ===")
 print(block.thinking)
 print("=== End Thinking ===\n")
 elif block.type == "text":
 print(block.text)
```

### TypeScript Example

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

const response = await client.messages.create({
 model: "claude-sonnet-4-6",
 max_tokens: 16000,
 thinking: { type: "enabled", budget_tokens: 10000 },
 messages: [{ role: "user", content: "Solve: What is 127 * 389?" }]
});

for (const block of response.content) {
 if (block.type === "thinking") {
 console.log("Thinking:", block.thinking);
 } else if (block.type === "text") {
 console.log("Answer:", block.text);
 }
}
```

### Display Options

Control how thinking content is returned:

```python
# Summarized thinking (default for Claude 4 models)
# Returns a summary of the reasoning. Charged for full tokens.
response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000, "display": "summarized"},
 messages=[...]
)

# Omitted thinking
# Returns empty thinking blocks with encrypted signature for continuity
response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000, "display": "omitted"},
 messages=[...]
)
```

### budget_tokens Rules

The `budget_tokens` parameter controls the maximum reasoning budget:

- Must be >= 1024
- Must be strictly less than `max_tokens`
- Claude may use fewer tokens than the budget if the problem is simple

```python
# Good: budget_tokens < max_tokens
response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000},
 messages=[...]
)

# Maximum output on Opus 4.6: 128k tokens
response = client.messages.create(
 model="claude-opus-4-6",
 max_tokens=128000,
 thinking={"type": "enabled", "budget_tokens": 100000},
 messages=[...]
)
```

### Extended Thinking with Tool Use

Thinking works with tools but only with `tool_choice: auto` or `none`:

```python
import anthropic

client = anthropic.Anthropic()

tools = [
 {
 "name": "calculator",
 "description": "Perform arithmetic calculations",
 "input_schema": {
 "type": "object",
 "properties": {
 "expression": {"type": "string", "description": "Math expression to evaluate"}
 },
 "required": ["expression"]
 }
 }
]

response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000},
 tool_choice={"type": "auto"}, # Only "auto" or "none" with thinking
 tools=tools,
 messages=[{"role": "user", "content": "Calculate the compound interest on $10,000 at 5% for 10 years"}]
)
```

Claude supports interleaved thinking between tool calls -- it can think before deciding to call a tool, receive the result, think again, and then respond.

### Multi-Turn Thinking Continuity

Pass thinking blocks back unmodified in multi-turn conversations to maintain reasoning continuity:

```python
# First turn
response1 = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000},
 messages=[{"role": "user", "content": "Analyze the pros and cons of remote work"}]
)

# Build multi-turn messages -- include ALL content blocks
messages = [
 {"role": "user", "content": "Analyze the pros and cons of remote work"},
 {"role": "assistant", "content": response1.content}, # Includes thinking blocks
 {"role": "user", "content": "Now focus on the productivity aspect"}
]

# Second turn
response2 = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000},
 messages=messages
)
```

### Streaming Extended Thinking

```python
import anthropic

client = anthropic.Anthropic()

with client.messages.stream(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000},
 messages=[{"role": "user", "content": "Solve a complex problem..."}]
) as stream:
 for text in stream.text_stream:
 print(text, end="", flush=True)

message = stream.get_final_message()
```

### Output Token Limits by Model

| Model | Max Output Tokens | Max with Batch API |
|-------|------------------|-------------------|
| Claude Opus 4.6 | 128,000 | 300,000 (beta) |
| Claude Sonnet 4.6 | 64,000 | 300,000 (beta) |
| Claude Haiku 4.5 | 64,000 | 300,000 (beta) |

### Caching with Extended Thinking

Changing thinking parameters invalidates cached messages, but system prompts and tools remain cached:

```python
# The system prompt cache survives thinking parameter changes
response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000},
 cache_control={"type": "ephemeral"},
 system="Large system prompt...", # This stays cached
 messages=[...] # These are re-processed if thinking params change
)
```

## Prevention

1. **Set budget_tokens appropriately**: Simple questions need 1024-4096. Complex reasoning needs 10000+. Always keep it less than max_tokens.
2. **Use auto for tool_choice**: `any` and specific tool names are not supported with thinking.
3. **Never modify thinking blocks**: Return them exactly as received in multi-turn conversations.
4. **Use 1-hour cache**: For workloads with extended thinking, the 1-hour cache TTL avoids frequent cache invalidation from thinking parameter changes.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-extended-thinking-api-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

## Related Guides

- [Claude Extended Thinking Not Working](/claude-extended-thinking-not-working/) -- troubleshoot thinking parameter errors.
- [Claude Tool Use Not Working](/claude-tool-use-not-working/) -- fix tool_choice conflicts with thinking.
- [Claude Prompt Caching API Guide](/claude-prompt-caching-api-guide/) -- optimize caching alongside thinking.
- [Claude Streaming API Guide](/claude-streaming-api-guide/) -- stream thinking output in real time.
- [Claude API Error 400 invalid_request_error Fix](/claude-api-error-400-invalidrequesterror-explained/) -- the error returned for invalid thinking parameters.

## See Also

- [Extended Thinking Budget Exceeded — Fix (2026)](/claude-code-extended-thinking-budget-exceeded-fix-2026/)


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


## Best Practices

1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency.

2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed.

3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions.

4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops).

5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like "refactor auth, add tests, and update docs" produce better results when broken into three separate prompts, each building on the previous result.


## Common Issues

**Claude Code ignores the configuration:** Ensure the configuration file is in the correct location. CLAUDE.md must be in the project root (the directory where you run `claude`). Settings go in `.claude/settings.json`. Verify with `ls -la CLAUDE.md .claude/settings.json`.

**Changes are not taking effect:** Claude Code reads CLAUDE.md at the start of each session. If you modify it during a session, the changes apply to new conversations but not the current one. Start a new session to pick up configuration changes.

**Slow performance on large projects:** Add a `.claudeignore` file to exclude large directories (node_modules, .git, dist, build, vendor). This reduces file scanning time and prevents Claude from reading irrelevant files. The format is identical to `.gitignore`.

**Unexpected file modifications:** Check `.claude/settings.json` for overly broad permission patterns. Narrow the allow list to specific commands and file patterns. For sensitive directories, add explicit deny rules.


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., \"Always use single quotes\" or \"Never modify files in the config/ directory\"). 1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency. 2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed. 3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions. 4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops). 5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like \"refactor auth, add tests, and update docs\" produce better results when broken into three separate prompts, each building on the previous result. **Claude Code ignores the configuration:** Ensure the configuration file is in the correct location. CLAUDE.md must be in the project root (the directory where you run `claude`). Settings go in `.claude/settings.json`. Verify with `ls -la CLAUDE.md .claude/settings.json`. **Changes are not taking effect:** Claude Code reads CLAUDE.md at the start of each session. If you modify it during a session, the changes apply to new conversations but not the current one. Start a new session to pick up configuration changes. **Slow performance on large projects:** Add a `.claudeignore` file to exclude large directories (node_modules, .git, dist, build, vendor). This reduces file scanning time and prevents Claude from reading irrelevant files. The format is identical to `.gitignore`. **Unexpected file modifications:** Check `.claude/settings.json` for overly broad permission patterns. Narrow the allow list to specific commands and file patterns. For sensitive directories, add explicit deny rules."
      }
    }
  ]
}
</script>
