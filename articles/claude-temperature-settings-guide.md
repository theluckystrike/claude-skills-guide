---
title: "Claude Temperature Settings: How to Adjust (2026)"
description: "Yes, you can adjust Claude's temperature — but only via the API. Full guide to temperature, top_p, top_k, recommended values by task, and code examples."
permalink: /claude-temperature-settings-guide/
last_tested: "2026-04-24"
render_with_liquid: false
---

# Claude Temperature Settings: How to Adjust (2026)

Yes, you can change Claude's temperature — but only through the Anthropic API. Claude.ai (the web interface) and Claude Code (the CLI) do not expose a temperature slider or flag. This guide covers what temperature does, how to set it in the API, recommended values for different tasks, and alternative sampling parameters.

## What Temperature Does

Temperature controls the randomness of the model's output. It modifies the probability distribution that Claude uses to select each token (word or word-piece) in its response.

### Technical Explanation

When Claude generates text, it produces a probability distribution over all possible next tokens. Temperature scales these probabilities before sampling:

- **Temperature = 0.0** — The model always picks the highest-probability token. Output is deterministic. Same input produces the same output every time.
- **Temperature = 0.5** — Moderate randomness. High-probability tokens are still favored, but there is some variation between runs.
- **Temperature = 1.0** — Full probability distribution is used as-is. Output is creative and varied. Default for Claude models.
- **Temperature > 1.0** — Not supported by the Anthropic API. The valid range is 0.0 to 1.0.

Mathematically, temperature divides the logits (raw model scores) before the softmax function converts them to probabilities. Lower temperature makes the distribution sharper (concentrated on top choices). Higher temperature makes it flatter (more spread across options).

### Practical Impact

| Temperature | Behavior | Best For |
|-------------|----------|----------|
| 0.0 | Deterministic, consistent | Code generation, factual answers, data extraction |
| 0.1-0.3 | Mostly consistent, slight variation | Technical writing, code review, analysis |
| 0.4-0.6 | Balanced creativity and coherence | General conversation, explanations |
| 0.7-0.9 | Creative, varied responses | Brainstorming, fiction, marketing copy |
| 1.0 | Maximum variety | Creative exploration, poetry, ideation |

## Setting Temperature in the API

### Python SDK

```python
import anthropic

client = anthropic.Anthropic()

# Low temperature for code generation
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=2048,
    temperature=0.0,
    messages=[
        {
            "role": "user",
            "content": "Write a Python function to merge two sorted arrays."
        }
    ],
)

print(response.content[0].text)
```

```python
# High temperature for brainstorming
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=2048,
    temperature=0.9,
    messages=[
        {
            "role": "user",
            "content": "Give me 10 creative names for a productivity app."
        }
    ],
)

print(response.content[0].text)
```

### TypeScript / JavaScript SDK

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic();

// Deterministic output for data extraction
const response = await client.messages.create({
  model: 'claude-sonnet-4-20250514',
  max_tokens: 1024,
  temperature: 0.0,
  messages: [
    {
      role: 'user',
      content: 'Extract all email addresses from this text: ...',
    },
  ],
});

console.log(response.content[0].text);
```

```typescript
// Creative output for content generation
const creative = await client.messages.create({
  model: 'claude-sonnet-4-20250514',
  max_tokens: 2048,
  temperature: 0.8,
  messages: [
    {
      role: 'user',
      content: 'Write a short story about a robot learning to paint.',
    },
  ],
});

console.log(creative.content[0].text);
```

### cURL (Direct API Call)

```bash
curl https://api.anthropic.com/v1/messages \
  -H "content-type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 1024,
    "temperature": 0.0,
    "messages": [
      {
        "role": "user",
        "content": "Explain the CAP theorem in one paragraph."
      }
    ]
  }'
```

### Valid Range

- **Minimum:** 0.0
- **Maximum:** 1.0
- **Default:** 1.0

Values outside this range will return an API error. The API does not support temperatures above 1.0.

## Claude Code and Temperature

### No Direct Temperature Flag

Claude Code does not have a `--temperature` CLI flag. When you run `claude` in the terminal, the temperature is managed internally by the Claude Code client.

### Influencing Output Style via CLAUDE.md

While you cannot set a numeric temperature in Claude Code, you can influence the output style through your CLAUDE.md instructions:

For more deterministic behavior, add to your project's `CLAUDE.md`:

```markdown
# Code Style
- Always produce the most standard, conventional solution
- Avoid creative or unconventional approaches
- Match existing code patterns exactly
- Do not improvise when a standard pattern exists
```

For more creative behavior:

```markdown
# Approach
- Explore multiple solution approaches before picking one
- Consider unconventional or novel solutions
- Propose creative alternatives when the standard approach has drawbacks
```

This is not temperature control — it is prompt engineering. But it achieves a similar practical effect.

### API Provider Mode

If you are using Claude Code with the `--api-key` flag connected to the Anthropic API, the temperature is handled by the Claude Code client. To get true temperature control, build a custom integration using the API directly.

## Recommended Temperatures by Task

### Code Generation: 0.0

Deterministic output ensures the same correct solution every time. At temperature 0.0, Claude produces the most likely (usually most conventional and correct) code.

```python
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=4096,
    temperature=0.0,
    messages=[{"role": "user", "content": "Implement a binary search tree in Python with insert, delete, and search methods."}],
)
```

### Code Review: 0.0

Consistency matters for code review. You want the same issues flagged every time.

```python
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=4096,
    temperature=0.0,
    messages=[{"role": "user", "content": f"Review this code for bugs and performance issues:\n\n{code}"}],
)
```

### Technical Documentation: 0.1-0.2

Slight variation produces more natural writing while maintaining accuracy.

### Creative Writing: 0.7-1.0

Higher temperatures produce more surprising word choices, varied sentence structures, and creative ideas.

```python
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=4096,
    temperature=0.9,
    messages=[{"role": "user", "content": "Write a poem about debugging at 3 AM."}],
)
```

### Brainstorming and Ideation: 0.8-1.0

Maximum creativity for generating diverse ideas.

### Data Analysis and Extraction: 0.0

Precision is critical when extracting structured data from unstructured text.

### Summarization: 0.0-0.2

Low temperature ensures the summary sticks to the source material without embellishment.

### Translation: 0.0-0.1

Accuracy over creativity for translation tasks.

## Alternative Sampling Parameters

Temperature is not the only way to control output randomness. The Anthropic API supports additional parameters.

### top_p (Nucleus Sampling)

`top_p` limits the model to choosing from the smallest set of tokens whose cumulative probability exceeds the specified value.

```python
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    top_p=0.9,
    messages=[{"role": "user", "content": "Explain quantum computing."}],
)
```

- **top_p = 1.0** — Consider all tokens (default)
- **top_p = 0.9** — Only consider tokens in the top 90% of cumulative probability
- **top_p = 0.1** — Very restrictive, only the most likely tokens

### top_k

`top_k` limits the model to choosing from only the top K most likely tokens.

```python
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    top_k=40,
    messages=[{"role": "user", "content": "List common design patterns."}],
)
```

- **top_k = 1** — Always pick the single most likely token (equivalent to temperature 0)
- **top_k = 40** — Consider the top 40 tokens
- **top_k = -1 or not set** — No limit (default)

### Combining Parameters

You can use temperature together with top_p and top_k:

```python
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=2048,
    temperature=0.7,
    top_p=0.95,
    top_k=50,
    messages=[{"role": "user", "content": "Suggest innovative features for a task management app."}],
)
```

Anthropic recommends either adjusting temperature or top_p, not both simultaneously in most cases. Using both can produce unexpected interactions.

## Temperature and Model Selection

Different Claude models may behave differently at the same temperature:

- **Claude Opus** — most capable model, temperature 0.0 produces high-quality deterministic output
- **Claude Sonnet** — balanced speed and quality, good across all temperature ranges
- **Claude Haiku** — fastest model, lower temperatures recommended for accuracy-critical tasks

The temperature parameter works identically across all models — the valid range is always 0.0 to 1.0.

## Frequently Asked Questions

### Can I set temperature in Claude.ai?

No. The Claude.ai web interface does not expose a temperature control. Claude.ai uses Anthropic's default settings. To control temperature, use the API directly.

### What is the default temperature for Claude?

The default temperature is 1.0. If you do not specify a temperature in your API call, Claude uses the full probability distribution for sampling.

### Does lower temperature mean better code?

Not necessarily better, but more consistent and conventional. Temperature 0.0 produces the most standard solution, which is usually what you want for production code. But for exploring alternative approaches, a slightly higher temperature (0.2-0.4) can reveal solutions you would not have considered.

### Can I set temperature per-message in a conversation?

Temperature is set per API call, not per message. In a multi-turn conversation, you can change the temperature between calls, but you must include the full conversation history each time.

### Does temperature affect Claude's reasoning quality?

At very high temperatures (0.9-1.0), Claude may occasionally produce less coherent reasoning because the sampling is more random. For tasks requiring careful logical reasoning, lower temperatures (0.0-0.3) generally produce more reliable results.

### Is temperature 0.0 truly deterministic?

Nearly. At temperature 0.0, the API uses greedy decoding (always selecting the highest-probability token). In practice, results are very consistent, though minor variations can occur due to floating-point arithmetic in distributed systems.

### How does temperature interact with system prompts?

Temperature and system prompts are independent controls. A well-crafted system prompt can constrain output style regardless of temperature. Using both together gives you fine-grained control — the system prompt sets the frame, and temperature controls variation within it.

### Should I use temperature or top_p?

For most use cases, temperature is simpler and more intuitive. Use top_p when you want to cap the randomness without affecting the relative probabilities of the top tokens. Anthropic's general recommendation is to adjust one or the other, not both.

## Related Guides

- [The Claude Code Playbook](/the-claude-code-playbook/) — comprehensive workflow reference
- [Claude Code Best Practices](/claude-code-claude-md-best-practices/) — optimize your setup
- [Claude Code Configuration Hierarchy](/claude-code-configuration-hierarchy-explained-2026/) — understand settings files
- [Claude Upload Limit Guide](/claude-upload-limit-guide/) — file size and type limits
- [Claude Code Token Usage Optimization](/claude-code-token-usage-optimization-best-practices-guide/) — manage costs
- [Claude Code REST API Design](/claude-code-rest-api-design-best-practices/) — API integration patterns
- [Claude Code Getting Started](/claude-code-getting-started-terminal-setup/) — initial CLI setup
- [Best MCP Servers for Claude Code](/best-mcp-servers-for-claude-code-2026/) — extend capabilities
- [Claude Code Save Conversation Guide](/claude-code-save-conversation-guide/) — session management
