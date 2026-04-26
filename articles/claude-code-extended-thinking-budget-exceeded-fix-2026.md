---
layout: default
title: "Extended Thinking Budget Exceeded — Fix (2026)"
permalink: /claude-code-extended-thinking-budget-exceeded-fix-2026/
date: 2026-04-20
description: "Increase thinking_budget in settings to 32768 tokens with claude config set. Fixes the extended thinking token allocation mismatch error cleanly."
last_tested: "2026-04-21"
---

## The Error

```
Extended thinking budget exceeded: used 32768 tokens of 16384 allowed
```

## The Fix

```bash
# Increase the extended thinking token budget
claude config set thinking_budget 32768
```

## Why This Works

[Sequential thinking in Claude Code](/sequential-thinking-claude-code-guide/) allows Claude to reason through complex problems before responding. When the allocated budget is too low, Claude hits the ceiling mid-reasoning and the request fails. Setting the budget to 32768 tokens gives sufficient room for multi-step reasoning while keeping costs predictable.

## If That Doesn't Work

```bash
# Disable extended thinking entirely if budget errors persist
claude config set thinking_budget 0
# Or break your prompt into smaller, simpler sub-tasks
# that require less reasoning depth
```

If you are on a rate-limited plan, extended thinking tokens count toward your per-minute token limit. Reduce concurrent sessions or wait for the rate window to reset before retrying with a higher budget. You can also check current token usage with `claude config get thinking_budget` to confirm the new value persisted — some workspace-level configs override global settings.

## Prevention

Add to your CLAUDE.md:
```
Extended thinking budget is set to 32768 tokens. For tasks requiring deep analysis (architecture decisions, complex refactors), use explicit step-by-step instructions to reduce reasoning depth needed.
```


## Related

- [Claude Sonnet 4.5 model guide](/claude-sonnet-4-5-20250929-model-guide/) — Guide to the claude-sonnet-4-5-20250929 model and its capabilities

## Related Error Messages

This fix also applies if you see these related error messages:

- `TokenLimitExceeded: max tokens reached`
- `Error: output truncated at max_tokens`
- `Warning: response may be incomplete due to token limit`
- `ModelNotFoundError: model 'claude-3-opus' not available`
- `Error: specified model is deprecated`

## Frequently Asked Questions

### What causes token count mismatches?

Token counts are estimated before sending a request and precisely calculated on the server. The estimation uses a fast local tokenizer that may differ slightly from the server's tokenizer. Small discrepancies (1-3%) are normal and do not affect functionality.

### How do I reduce token consumption in long sessions?

Start new conversations for unrelated tasks. Each message in a conversation includes the full history, so long conversations consume exponentially more tokens. A 50-message conversation may use 10x the tokens of five 10-message conversations.

### Can I see my token usage?

Run `claude usage` to see your current billing period's token consumption broken down by model. The Anthropic console at console.anthropic.com provides detailed usage graphs and per-day breakdowns.

### Which model does Claude Code use by default?

Claude Code uses the latest Claude model available on your account. You can override the model with `claude --model claude-sonnet-4-20250514` or set a default in your configuration with `claude config set model claude-sonnet-4-20250514`.




**Estimate usage →** Calculate your token consumption with our [Token Estimator](/token-estimator/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Fix Skill Exceeded Maximum Output](/claude-code-skill-exceeded-maximum-output-length-error-fix/)
- [Context Window Exceeded — Fix (2026)](/claude-code-context-window-exceeded-mid-conversation-fix-2026/)
- [Fix Claude Rate Exceeded Error (2026)](/claude-rate-exceeded-error-fix/)
- [Fix Claude AI Rate Exceeded Error](/claude-ai-rate-exceeded-error-fix/)

## How Extended Thinking Works

Extended thinking gives Claude more processing time for complex tasks by allowing it to reason through problems step-by-step before producing an output. This is not the same as a longer response -- it is additional internal reasoning that improves accuracy on tasks requiring planning, multi-step logic, or complex code generation.

**When to use extended thinking:** Multi-file refactoring, architecture decisions, debugging complex interactions, writing code that involves multiple interacting systems.

**When NOT to use extended thinking:** Simple questions, single-file edits, formatting changes, or tasks where speed matters more than depth.

**Token cost implications.** Extended thinking tokens count toward your usage but are often worthwhile. A task that takes 3 attempts without thinking (90K tokens total) may succeed on the first attempt with thinking (40K tokens including thinking overhead).

## Configuring Extended Thinking

Extended thinking is controlled by the model parameter and is available on Claude Opus 4.6 and Sonnet 4.6 models. In Claude Code, it activates automatically for complex tasks when using a supported model.

To explicitly request thinking in API calls:

```python
response = client.messages.create(
    model="claude-opus-4-6-20250414",
    max_tokens=16000,
    thinking={"type": "enabled", "budget_tokens": 10000},
    messages=[{"role": "user", "content": prompt}]
)
```

The `budget_tokens` parameter controls how many tokens Claude can use for internal reasoning. Higher budgets allow deeper analysis but cost more. Start with 5,000 and increase if outputs are incomplete.
