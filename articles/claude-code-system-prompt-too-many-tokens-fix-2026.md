---
title: "System Prompt Exceeds Token Limit — Fix"
permalink: /claude-code-system-prompt-too-many-tokens-fix-2026/
description: "Fix 'system prompt exceeds maximum token count' error. Reduce system prompt size or move context to first user message."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error 400: system prompt exceeds maximum token count. Got 32847 tokens, maximum is 16384 for this model.
```

This error fires when your system prompt is too large for the selected model's system prompt allocation. Each model has a different maximum.

## The Fix

1. Count your current system prompt tokens:

```bash
python3 -c "
text = open('system-prompt.txt').read()
# Rough estimate: 1 token per 4 characters
print(f'Estimated tokens: {len(text) // 4}')
print(f'Character count: {len(text)}')
"
```

2. Trim the system prompt to essentials. Move reference data to the first user message:

```python
# Before (too large):
system = huge_context + instructions + examples

# After (fits):
system = instructions_only  # Keep under 8K tokens
first_message = f"Reference context:\n{huge_context}\n\nNow: {user_query}"
```

3. Use prompt caching to reduce costs on the large context:

```python
import anthropic
client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    system=[{"type": "text", "text": short_instructions, "cache_control": {"type": "ephemeral"}}],
    messages=[{"role": "user", "content": context + query}]
)
```

## Why This Happens

The system prompt has a separate token budget from the conversation context. Stuffing entire codebases, documentation, or lengthy instructions into the system prompt exceeds this budget. The limit exists because system prompts are processed differently from user messages in the model's attention mechanism.

## If That Doesn't Work

- Split your system prompt into a short preamble (system) and detailed context (first message).
- Use CLAUDE.md for persistent instructions instead of passing them programmatically.
- Switch to a model with a larger system prompt allowance.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# System Prompt Size
- Keep system prompts under 8,000 tokens (roughly 32,000 characters).
- Put reference data in user messages, not system prompt.
- Use prompt caching for repeated large contexts.
```

## See Also

- [Why Your Claude Prompts Use Too Many Tokens](/claude-cost-why-claude-prompts-use-too-many-tokens/)
- [Claude API System Prompt Too Long Error — Fix (2026)](/claude-api-system-prompt-too-long-error-fix/)
- [File Watcher EMFILE Too Many Open Files Fix](/claude-code-file-watcher-emfile-too-many-open-files-fix-2026/)
- [Claude Code System Prompts Explained (2026)](/claude-code-system-prompts-guide-2026/)
- [Claude Code subagent spawning too many agents — cost control](/claude-code-subagent-spawning-too-many-cost-control/)
