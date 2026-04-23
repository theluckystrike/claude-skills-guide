---
title: "Claude Sonnet 4.5 (20250929): Model Guide (2026)"
description: "Claude Sonnet 4.5 model ID explained. Capabilities, pricing, API usage, and comparisons with Sonnet 4 and Opus 4 for coding and analysis tasks."
permalink: /claude-sonnet-4-5-20250929-model-guide/
last_tested: "2026-04-24"
render_with_liquid: false
---

# Claude Sonnet 4.5 (20250929): Model Guide (2026)

`claude-sonnet-4-5-20250929` is the model ID for Claude Sonnet 4.5, released on September 29, 2025. This guide covers what the model can do, how to use it, current pricing, and when to choose it over newer alternatives.

## What the Model ID Means

Anthropic's model IDs follow a consistent format:

```
claude-{family}-{version}-{date}
```

Breaking down `claude-sonnet-4-5-20250929`:

| Part | Meaning |
|------|---------|
| `claude` | Claude model family |
| `sonnet` | Sonnet tier (mid-range performance and cost) |
| `4-5` | Version 4.5 |
| `20250929` | Release date: September 29, 2025 |

The date suffix is important. It identifies the exact model snapshot. Anthropic may release updated versions of the same model family (like Sonnet 4 after Sonnet 4.5), and the date lets you pin to a specific version.

## Model Capabilities

Claude Sonnet 4.5 was the most capable Sonnet model at the time of its release. Key capabilities:

### Context Window
- **200,000 tokens** — approximately 150,000 words or 500 pages of text
- Supports long documents, full codebases, and extended conversations

### Coding Performance
- Strong at code generation, review, and debugging
- Supports all major programming languages
- Handles multi-file edits and refactors

### Extended Thinking
- Supports extended thinking mode for complex reasoning
- When enabled, the model "thinks" before responding, improving accuracy on hard problems
- Particularly useful for math, logic, and multi-step analysis

### Vision and Multimodal
- Accepts images as input (screenshots, diagrams, charts)
- Can analyze UI mockups, read text from images, and describe visual content

### Tool Use
- Full tool use (function calling) support
- Can call multiple tools in sequence as part of an agent loop
- Compatible with the Claude Agent SDK and Claude Code

## How to Use

### Python API

```python
import anthropic

client = anthropic.Anthropic()

message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    messages=[
        {"role": "user", "content": "Explain the difference between TCP and UDP"}
    ]
)
print(message.content[0].text)
```

### TypeScript API

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

const message = await client.messages.create({
  model: "claude-sonnet-4-5-20250929",
  max_tokens: 4096,
  messages: [
    { role: "user", content: "Explain the difference between TCP and UDP" }
  ],
});
console.log(message.content[0].text);
```

### Claude Code CLI

```bash
claude --model claude-sonnet-4-5-20250929
```

Or set it in your CLAUDE.md:

```markdown
## Model
Use claude-sonnet-4-5-20250929 for all tasks in this project.
```

### With Extended Thinking

```python
message = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=16000,
    thinking={
        "type": "enabled",
        "budget_tokens": 10000,
    },
    messages=[
        {"role": "user", "content": "Solve this optimization problem: ..."}
    ]
)
```

## Pricing

Current per-token pricing for Claude Sonnet 4.5:

| Type | Cost per 1M Tokens |
|------|-------------------|
| Input tokens | $3.00 |
| Output tokens | $15.00 |
| Prompt caching (write) | $3.75 |
| Prompt caching (read) | $0.30 |

Prompt caching reduces input costs by 90% for repeated content. This is particularly valuable when using Sonnet 4.5 in agent loops where the system prompt and conversation history are resent with each turn.

## Comparison: Sonnet 4.5 vs Sonnet 4

Claude Sonnet 4 (`claude-sonnet-4-20250514`) was released after Sonnet 4.5 and is generally the recommended choice for new projects.

| Aspect | Sonnet 4.5 (20250929) | Sonnet 4 (20250514) |
|--------|----------------------|---------------------|
| Release date | September 29, 2025 | May 14, 2025 (but the newer model) |
| Instruction following | Good | Better |
| Coding accuracy | Strong | Stronger |
| Creative writing | Slightly better | Good |
| Analysis depth | Strong | Comparable |
| Pricing | Same | Same |
| Recommended | For specific use cases | General recommendation |

**When to use Sonnet 4.5 instead of Sonnet 4:**
- You have tested both on your specific workload and Sonnet 4.5 performs better
- Your task emphasizes creative or analytical writing over strict instruction following
- You need to reproduce results from a system built on Sonnet 4.5

**When to use Sonnet 4 instead:**
- Starting a new project (Sonnet 4 is the current default)
- Instruction following is critical (Sonnet 4 is measurably better)
- You want the model that Anthropic actively recommends

For a detailed guide on Sonnet 4, see our [Claude Sonnet 4 model guide](/claude-sonnet-4-20250514-model-guide/).

## Comparison: Sonnet 4.5 vs Opus 4

| Aspect | Sonnet 4.5 | Opus 4 |
|--------|-----------|--------|
| Complex reasoning | Good | Significantly better |
| Coding | Strong | Strongest |
| Cost (input) | $3.00/M | $15.00/M |
| Cost (output) | $15.00/M | $75.00/M |
| Speed | Faster | Slower |
| Best for | Daily development work | Architecture, security, hard problems |

Sonnet 4.5 costs one-fifth of Opus 4. For most coding tasks, Sonnet 4.5 produces good results. Reserve Opus for tasks where the quality difference justifies the 5x price increase.

For cost optimization strategies across models, see our [cost reduction guide](/claude-code-costs-too-much-reduce-spend-2026/).

## Model ID History and Versioning

Anthropic's Sonnet model history:

| Model ID | Release | Notes |
|----------|---------|-------|
| `claude-3-sonnet-20240229` | Feb 2024 | Claude 3 Sonnet (deprecated) |
| `claude-3-5-sonnet-20240620` | Jun 2024 | Claude 3.5 Sonnet (deprecated) |
| `claude-3-5-sonnet-20241022` | Oct 2024 | Updated 3.5 Sonnet (deprecated) |
| `claude-sonnet-4-5-20250929` | Sep 2025 | Claude Sonnet 4.5 |
| `claude-sonnet-4-20250514` | May 2025 | Claude Sonnet 4 (current recommended) |

Note that version numbers do not always increase sequentially within a tier. Sonnet 4 (released after 4.5) represents Anthropic's current recommended Sonnet model despite the lower version number. The naming reflects Anthropic's evolving approach to model versioning.

**Pinning vs latest**: Always use the full model ID with date suffix in production code. Using shorthand aliases may route to newer versions as Anthropic updates defaults.

## Frequently Asked Questions

**Is Sonnet 4.5 still available?**
Yes. Anthropic maintains older model versions for backward compatibility. You can continue using `claude-sonnet-4-5-20250929` in both the API and Claude Code.

**Should I migrate from Sonnet 4.5 to Sonnet 4?**
For most workloads, yes. Sonnet 4 offers better instruction following at the same price. Test both on your specific tasks before migrating production systems.

**Can I use Sonnet 4.5 with Claude Code?**
Yes. Pass `--model claude-sonnet-4-5-20250929` when launching Claude Code. See our [model routing guide](/claude-code-router-guide/) for multi-model strategies.

**What is the rate limit for Sonnet 4.5?**
Rate limits depend on your API tier, not the specific model. Check your account dashboard at console.anthropic.com for current limits.

**Does Sonnet 4.5 support tool use?**
Yes. Full tool use (function calling) support, compatible with the Claude Agent SDK and all Claude Code tools.

**Will Sonnet 4.5 be deprecated?**
Anthropic typically provides advance notice before deprecating models. Monitor the Anthropic changelog for deprecation announcements.

**How does Sonnet 4.5 handle long context workloads?**
With a 200,000-token context window, Sonnet 4.5 handles large codebases and extended conversations well. Performance remains consistent through the full window, though costs scale linearly with input size. Use prompt caching to reduce costs when repeatedly sending the same context.

## Related Guides

- [Claude Sonnet 4 model guide](/claude-sonnet-4-20250514-model-guide/) — the current recommended Sonnet model
- [Claude Code cost breakdown](/claude-code-cost-complete-guide/) — pricing across all models
- [Model routing strategies](/claude-code-router-guide/) — choosing the right model per task
- [Claude Agent SDK guide](/claude-agent-sdk-complete-guide/) — build agents with any model
- [Claude Code prompt engineering](/claude-code-prompt-engineering-tips-2026/) — optimize prompts for Sonnet models
- [Cost tracking with ccusage](/ccusage-claude-code-cost-tracking-guide-2026/) — monitor per-model spend
- [API mode vs interactive](/claude-code-api-mode-vs-interactive-2026/) — model selection in different modes
- [The Claude Code Playbook](/the-claude-code-playbook/) — comprehensive Claude Code reference
