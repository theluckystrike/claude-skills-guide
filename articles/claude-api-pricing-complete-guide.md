---
title: "Claude API Pricing (2026)"
description: "Complete Claude API pricing for all models and plans. Per-token costs, rate limits, batch discounts, prompt caching savings, and plan comparisons."
permalink: /claude-api-pricing-complete-guide/
last_tested: "2026-04-24"
---

# Claude API Pricing: Every Plan and Model (2026)

Anthropic offers Claude through consumer subscriptions (Free, Pro, Max) and developer API access with per-token billing. The pricing structure has evolved significantly through 2025 and 2026, with the introduction of new model tiers, batch processing discounts, and prompt caching.

This guide breaks down every pricing dimension so you can calculate your actual costs before committing to a plan or API integration.

## Consumer Plans Overview

These plans give you access to Claude through claude.ai and mobile apps. They do not provide API access.

### Free Tier
- **Cost**: $0/month
- **Model access**: Claude Sonnet 4 (limited)
- **Usage**: Limited messages per day (varies by demand)
- **Features**: Basic chat, file uploads, web search
- **Context window**: Standard
- **No API access**

### Pro Plan
- **Cost**: $20/month
- **Model access**: Claude Sonnet 4, Claude Opus 4, Claude Haiku
- **Usage**: 5x more than Free tier
- **Features**: Projects, extended thinking, priority access, Claude Code access
- **Context window**: 200K tokens
- **Rate limit**: Usage cap with 5-hour rolling window ([details](/claude-5-hour-usage-limit-guide/))

### Max Plan (5x)
- **Cost**: $100/month
- **Model access**: All models including Opus 4
- **Usage**: 5x more than Pro
- **Features**: Everything in Pro plus higher rate limits
- **Context window**: 200K tokens
- **Claude Code**: Included with higher limits

### Max Plan (20x)
- **Cost**: $200/month
- **Model access**: All models
- **Usage**: 20x more than Pro
- **Features**: Everything in Max 5x plus highest rate limits
- **Context window**: 200K tokens
- **Claude Code**: Included with highest limits

## API Pricing by Model

API pricing is per-token, measured separately for input and output tokens. All prices are per million tokens (MTok).

### Claude Opus 4 (claude-opus-4-0520)

Anthropic's most capable model. Best for complex reasoning, multi-step analysis, and agentic workflows.

| Metric | Price |
|--------|-------|
| Input tokens | $15.00 / MTok |
| Output tokens | $75.00 / MTok |
| Context window | 200K tokens |
| Max output | 32K tokens |
| Training data cutoff | Early 2025 |

**Cost example**: A 2,000-token prompt with a 1,000-token response costs:
- Input: 2,000 / 1,000,000 * $15.00 = $0.03
- Output: 1,000 / 1,000,000 * $75.00 = $0.075
- **Total: $0.105 per request**

### Claude Sonnet 4 (claude-sonnet-4-0514)

Balanced model for most production workloads. Strong coding, analysis, and writing capabilities at a lower price point than Opus.

| Metric | Price |
|--------|-------|
| Input tokens | $3.00 / MTok |
| Output tokens | $15.00 / MTok |
| Context window | 200K tokens |
| Max output | 16K tokens |
| Training data cutoff | Early 2025 |

**Cost example**: Same 2,000-token prompt with 1,000-token response:
- Input: 2,000 / 1,000,000 * $3.00 = $0.006
- Output: 1,000 / 1,000,000 * $15.00 = $0.015
- **Total: $0.021 per request** (5x cheaper than Opus 4)

### Claude Haiku 3.5 (claude-3-5-haiku-20241022)

Fastest model. Best for high-volume, latency-sensitive tasks like classification, extraction, and simple Q&A.

| Metric | Price |
|--------|-------|
| Input tokens | $0.80 / MTok |
| Output tokens | $4.00 / MTok |
| Context window | 200K tokens |
| Max output | 8K tokens |
| Training data cutoff | Early 2024 |

**Cost example**: Same prompt:
- Input: 2,000 / 1,000,000 * $0.80 = $0.0016
- Output: 1,000 / 1,000,000 * $4.00 = $0.004
- **Total: $0.0056 per request** (19x cheaper than Opus 4)

### Model Comparison Table

| Model | Input/MTok | Output/MTok | Speed | Best For |
|-------|-----------|-------------|-------|----------|
| Opus 4 | $15.00 | $75.00 | Slowest | Complex reasoning, agentic tasks |
| Sonnet 4 | $3.00 | $15.00 | Medium | General production, coding |
| Haiku 3.5 | $0.80 | $4.00 | Fastest | High volume, classification |

## Prompt Caching

Prompt caching reduces costs when you send the same prompt prefix repeatedly. This is critical for applications that include large system prompts, [CLAUDE.md files](/claude-md-best-practices-definitive-guide/), or static context in every request.

### How Prompt Caching Works

1. First request: Full price for all tokens. Cached tokens incur a 25% write surcharge.
2. Subsequent requests: Cached portion is charged at a reduced read rate.
3. Cache lifetime: 5 minutes from last use (extends with each hit).

### Prompt Caching Prices

| Model | Cache Write (per MTok) | Cache Read (per MTok) | Savings vs Input |
|-------|----------------------|---------------------|-----------------|
| Opus 4 | $18.75 (+25%) | $1.50 | 90% on reads |
| Sonnet 4 | $3.75 (+25%) | $0.30 | 90% on reads |
| Haiku 3.5 | $1.00 (+25%) | $0.08 | 90% on reads |

### Cache Savings Example

Imagine a chatbot with a 4,000-token system prompt using Sonnet 4:

**Without caching** (100 requests):
- System prompt: 100 * 4,000 / 1M * $3.00 = $1.20

**With caching** (100 requests):
- First request (write): 4,000 / 1M * $3.75 = $0.015
- 99 subsequent (read): 99 * 4,000 / 1M * $0.30 = $0.119
- **Total: $0.134** (89% savings)

### Cache Requirements

- Minimum cacheable prefix: 1,024 tokens (Haiku), 2,048 tokens (Sonnet/Opus)
- Cache is per-organization, not per-API-key
- Cached content must be identical byte-for-byte
- Cache blocks use 128-token granularity

## Batch API

The Batch API processes requests asynchronously at a 50% discount. Results are returned within 24 hours.

### Batch API Prices

| Model | Input/MTok | Output/MTok | Discount |
|-------|-----------|-------------|----------|
| Opus 4 | $7.50 | $37.50 | 50% |
| Sonnet 4 | $1.50 | $7.50 | 50% |
| Haiku 3.5 | $0.40 | $2.00 | 50% |

### When to Use Batch API

- **Content generation**: Generating hundreds of product descriptions, articles, or summaries
- **Data processing**: Classifying, extracting, or transforming large datasets
- **Evaluation**: Running model evaluations across test suites
- **Migration**: Processing existing content through Claude for reformatting

### Batch API Limitations

- No streaming
- No real-time responses (up to 24-hour SLA)
- Maximum 100,000 requests per batch
- Each request limited to standard model context window
- No prompt caching within batches

## Extended Thinking Pricing

Extended thinking allows Claude to "think" before responding, improving performance on complex tasks. Thinking tokens are billed as output tokens.

| Model | Thinking Token Price | Same As |
|-------|---------------------|---------|
| Opus 4 | $75.00 / MTok | Output rate |
| Sonnet 4 | $15.00 / MTok | Output rate |

**Important**: Extended thinking can generate thousands of thinking tokens before the visible response. A request that appears to have a 500-token response may actually consume 5,000+ tokens when thinking tokens are included.

### Controlling Extended Thinking Costs

```python
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=16000,
    thinking={
        "type": "enabled",
        "budget_tokens": 5000  # Cap thinking tokens
    },
    messages=[{"role": "user", "content": "Your prompt"}]
)
```

Setting `budget_tokens` caps the thinking cost. Without it, Claude may use the full output token limit for thinking.

## Rate Limits

Rate limits vary by plan tier and are measured in requests per minute (RPM) and tokens per minute (TPM).

### API Rate Limits by Tier

| Tier | RPM | Input TPM | Output TPM | Spend Requirement |
|------|-----|-----------|------------|-------------------|
| Tier 1 (Free) | 50 | 40,000 | 8,000 | $0 |
| Tier 2 | 1,000 | 80,000 | 16,000 | $40 credit |
| Tier 3 | 2,000 | 160,000 | 32,000 | $200 credit |
| Tier 4 | 4,000 | 400,000 | 80,000 | $400+ spend |

Rate limit headers are included in every API response:

```
x-ratelimit-limit-requests: 1000
x-ratelimit-limit-tokens: 80000
x-ratelimit-remaining-requests: 999
x-ratelimit-remaining-tokens: 79000
x-ratelimit-reset-requests: 2026-04-24T12:00:01Z
x-ratelimit-reset-tokens: 2026-04-24T12:00:01Z
```

### Handling Rate Limits

When you hit a rate limit, the API returns a [429 error](/anthropic-api-error-429-rate-limit/). Best practices:

1. Implement exponential backoff with jitter
2. Track remaining tokens from response headers
3. Use request queuing for high-volume applications
4. Consider the Batch API for non-real-time workloads

```python
import time
import random

def call_with_backoff(func, max_retries=5):
    for attempt in range(max_retries):
        try:
            return func()
        except anthropic.RateLimitError:
            wait = (2 ** attempt) + random.uniform(0, 1)
            time.sleep(wait)
    raise Exception("Max retries exceeded")
```

## Claude Code Pricing

Claude Code uses the API under the hood. When you use Claude Code with your own API key, you pay standard API rates for whichever model you select.

### Claude Code with Subscription Plans

- **Pro ($20/mo)**: Claude Code access included. Uses Sonnet 4 by default. Subject to [5-hour usage limits](/claude-5-hour-usage-limit-guide/).
- **Max 5x ($100/mo)**: Higher Claude Code limits. Can use Opus 4.
- **Max 20x ($200/mo)**: Highest limits. Full Opus 4 access.

### Claude Code with API Key

When using `ANTHROPIC_API_KEY`, you pay per-token at standard API rates. A typical Claude Code session costs:

- **Light session** (simple edits): $0.05-0.50
- **Medium session** (feature implementation): $0.50-5.00
- **Heavy session** (large refactoring): $5.00-50.00+

Track your Claude Code costs with [token usage auditing](/audit-claude-code-token-usage-step-by-step/).

### Claude Code with OpenRouter

You can route Claude Code through [OpenRouter](/claude-code-openrouter-setup-guide/) for potentially different pricing and access to multiple model providers through a single API key.

*Need the complete toolkit? [The Claude Code Playbook](https://zovo.one/pricing) includes 200 production-ready templates.*

## Cost Optimization Strategies

### 1. Choose the Right Model

Use Haiku 3.5 for simple tasks, Sonnet 4 for most work, and Opus 4 only when you need maximum quality. A common pattern:

```python
# Route by task complexity
def get_model(task_type):
    if task_type == "classification":
        return "claude-3-5-haiku-20241022"  # $0.80/MTok input
    elif task_type == "coding":
        return "claude-sonnet-4-20250514"   # $3.00/MTok input
    elif task_type == "architecture":
        return "claude-opus-4-0520"         # $15.00/MTok input
```

### 2. Maximize Prompt Caching

Structure your prompts with static content first:

```python
messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "text",
                "text": large_static_system_prompt,  # Cached
                "cache_control": {"type": "ephemeral"}
            },
            {
                "type": "text",
                "text": dynamic_user_query  # Not cached
            }
        ]
    }
]
```

### 3. Use Batch API for Non-Urgent Work

If your workload can tolerate 24-hour latency, the 50% batch discount is substantial:

| Monthly Volume | Real-time (Sonnet) | Batch (Sonnet) | Savings |
|---------------|-------------------|----------------|---------|
| 10M input tokens | $30.00 | $15.00 | $15.00 |
| 10M output tokens | $150.00 | $75.00 | $75.00 |
| **Total** | **$180.00** | **$90.00** | **$90.00** |

### 4. Optimize Token Usage

- Trim unnecessary context from prompts
- Use structured output to reduce verbose responses
- Set appropriate `max_tokens` limits
- [Prune unused tools](/pruning-unused-claude-tools-saves-money/) from tool definitions

### 5. Monitor and Alert

Set up [cost alerts](/claude-code-cost-alerts-notifications-budget/) to catch unexpected usage spikes before they become expensive.

## Comparing Claude API to Competitors

### Claude vs OpenAI GPT-4o

| Metric | Claude Sonnet 4 | GPT-4o |
|--------|----------------|--------|
| Input/MTok | $3.00 | $2.50 |
| Output/MTok | $15.00 | $10.00 |
| Context window | 200K | 128K |
| Batch discount | 50% | 50% |
| Caching discount | 90% on reads | 50% on reads |

### Claude vs Google Gemini 2.5

| Metric | Claude Sonnet 4 | Gemini 2.5 Pro |
|--------|----------------|----------------|
| Input/MTok | $3.00 | $1.25 |
| Output/MTok | $15.00 | $10.00 |
| Context window | 200K | 1M |
| Batch discount | 50% | None |
| Caching | 90% reads | Free after 128K |

### When Claude Is More Cost-Effective

- Applications with heavy prompt caching (90% read discount beats competitors)
- Batch processing workloads (consistent 50% discount)
- Complex coding tasks where fewer iterations save total token spend
- Applications requiring 200K context with strong instruction following

## Token Counting: What Costs Money

Understanding what counts as tokens is critical for cost prediction. Many developers are surprised by the actual token counts in their API calls.

### Text Tokens

English text averages 4 characters per token. Examples:
- "Hello" = 1 token
- "The quick brown fox jumps over the lazy dog" = 10 tokens
- A 500-word blog post = ~650 tokens
- A typical CLAUDE.md file = 500-2,000 tokens

Code is less token-efficient than prose because of syntax characters:
- A 100-line Python function = ~400-600 tokens
- A 100-line TypeScript function = ~500-800 tokens (types add tokens)
- A package.json with 30 dependencies = ~300 tokens

### System Prompt Tokens

Every API call includes a system prompt (even if you do not specify one, Anthropic adds a default). System prompts count as input tokens on every request.

For applications with a 2,000-token system prompt making 1,000 API calls per day using Sonnet 4:
- Daily system prompt cost: 1,000 * 2,000 / 1M * $3.00 = $6.00
- Monthly: $180 just for system prompts

This is why [prompt caching](/claude-api-pricing-complete-guide/) is critical for production applications.

### Conversation History Tokens

In multi-turn conversations, the entire history is sent with each new message. A conversation with 10 turns where each turn averages 500 tokens:

- Turn 1: 500 tokens input
- Turn 2: 1,000 tokens input (500 history + 500 new)
- Turn 3: 1,500 tokens input
- Turn 10: 5,000 tokens input

Total input tokens for 10 turns: 27,500 tokens (not 5,000)

This quadratic growth is why long conversations get expensive fast, and why [context management](/claude-5-hour-usage-limit-guide/) matters.

### Tool Use Tokens

When you define tools for Claude, the tool definitions are included as input tokens on every request. Each tool definition costs roughly 200-500 tokens. If you define 10 tools:

- Tool definitions: ~3,000 tokens per request
- At 100 requests/day with Sonnet 4: 100 * 3,000 / 1M * $3.00 = $0.90/day

When Claude calls a tool, the tool call JSON is output tokens and the tool result is input tokens.

### Image Tokens

Images are converted to tokens based on resolution:

| Image Size | Approximate Tokens |
|-----------|-------------------|
| 100x100 | ~100 tokens |
| 512x512 | ~800 tokens |
| 1024x1024 | ~1,600 tokens |
| 2048x2048 | ~3,200 tokens |
| Full screenshot (1920x1080) | ~2,400 tokens |

For image-heavy applications, these token costs add up quickly.

### PDF Tokens

PDF pages are converted to a combination of text and image tokens. A typical document page costs 1,000-3,000 tokens depending on content complexity.

## Cost Calculator Examples

### Example 1: Customer Support Chatbot

- 500 conversations per day
- Average 5 turns per conversation
- 200-token system prompt
- Using Sonnet 4 with prompt caching

**Without caching:**
- System prompt: 500 * 5 * 200 / 1M * $3.00 = $1.50/day
- User messages: 500 * 5 * 150 / 1M * $3.00 = $1.13/day
- History replay: ~500 * 10 * 150 / 1M * $3.00 = $2.25/day
- Responses: 500 * 5 * 300 / 1M * $15.00 = $11.25/day
- **Daily total: ~$16.13 ($484/month)**

**With prompt caching (system prompt cached):**
- System prompt (cached reads): 500 * 5 * 200 / 1M * $0.30 = $0.15/day (90% savings)
- Other costs remain similar
- **Daily total: ~$14.78 ($443/month)**

### Example 2: Code Review Automation

- 50 PRs per day
- Average diff: 2,000 tokens
- System prompt with review guidelines: 1,500 tokens
- Using Sonnet 4 with batch API

**Real-time:**
- Input: 50 * 3,500 / 1M * $3.00 = $0.53/day
- Output: 50 * 1,000 / 1M * $15.00 = $0.75/day
- **Daily total: $1.28 ($38/month)**

**Batch API (50% discount):**
- Input: 50 * 3,500 / 1M * $1.50 = $0.26/day
- Output: 50 * 1,000 / 1M * $7.50 = $0.38/day
- **Daily total: $0.64 ($19/month)**

### Example 3: Document Analysis Pipeline

- 100 documents per day
- Average document: 10,000 tokens
- Summary output: 500 tokens per document
- Using Haiku 3.5 (speed and cost priority)

- Input: 100 * 10,000 / 1M * $0.80 = $0.80/day
- Output: 100 * 500 / 1M * $4.00 = $0.20/day
- **Daily total: $1.00 ($30/month)**

Same pipeline with Sonnet 4 would cost $4.50/day ($135/month). Model choice matters.

## Billing and Payment

### API Billing

- Billed monthly in arrears
- Usage tracked in real-time on the Anthropic Console
- Prepaid credits available (required for tier upgrades)
- No minimum commitment

### Subscription Billing

- Billed monthly (no annual discount currently)
- Cancel anytime, access continues through billing period
- Downgrades take effect at next billing cycle
- [Extra usage charges](/claude-extra-usage-cost-guide/) billed separately

## Frequently Asked Questions

### How do I check my current API spending?
Visit the Anthropic Console at console.anthropic.com. The Usage page shows real-time token counts and costs broken down by model and day.

### Are there free API credits for new accounts?
Anthropic occasionally offers trial credits. Check the Console for current promotions. The free tier gives limited access without credit card.

### Can I set a spending limit?
Yes. In the Console, navigate to Settings and set a monthly spending limit. The API will return errors once the limit is reached.

### Do thinking tokens count against rate limits?
Yes. Extended thinking tokens count as output tokens for both billing and rate limit purposes.

### Is there a difference between MTok pricing and per-token pricing?
No. MTok (million tokens) is just the unit. $15.00/MTok equals $0.000015 per token. The per-million convention avoids tiny decimal numbers.

### How are images priced?
Images are converted to tokens based on their dimensions. A typical 1024x1024 image costs approximately 1,600 tokens at input rates.

### Can I negotiate volume discounts?
For large-scale enterprise usage, contact Anthropic's sales team. Volume commitments can lead to custom pricing.

### What happens if I exceed my rate limit?
You receive a 429 HTTP error. The response headers indicate when the limit resets. Implement [retry logic](/anthropic-api-error-429-rate-limit/) to handle this gracefully.

### How does Claude API pricing compare to running local models?
Local models (via Ollama, llama.cpp) have zero per-token cost but require GPU hardware ($2,000-$10,000+). For most developers, API access is cheaper unless you process millions of tokens daily. The breakeven point depends on your hardware cost, electricity, and usage volume.

### Can I use multiple API keys for higher rate limits?
Each API key shares the organization-level rate limit. Multiple keys do not increase your total throughput. To get higher limits, upgrade your API tier by adding prepaid credits.


{% raw %}
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "### How do I check my current API spending?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Visit the Anthropic Console at console.anthropic.com. The Usage page shows real-time token counts and costs broken down by model and day."
      }
    },
    {
      "@type": "Question",
      "name": "Are there free API credits for new accounts?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Anthropic occasionally offers trial credits. Check the Console for current promotions. The free tier gives limited access without credit card."
      }
    },
    {
      "@type": "Question",
      "name": "Can I set a spending limit?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. In the Console, navigate to Settings and set a monthly spending limit. The API will return errors once the limit is reached."
      }
    },
    {
      "@type": "Question",
      "name": "Do thinking tokens count against rate limits?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Extended thinking tokens count as output tokens for both billing and rate limit purposes."
      }
    },
    {
      "@type": "Question",
      "name": "Is there a difference between MTok pricing and per-token pricing?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. MTok (million tokens) is just the unit. $15.00/MTok equals $0.000015 per token. The per-million convention avoids tiny decimal numbers."
      }
    },
    {
      "@type": "Question",
      "name": "How are images priced?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Images are converted to tokens based on their dimensions. A typical 1024x1024 image costs approximately 1,600 tokens at input rates."
      }
    },
    {
      "@type": "Question",
      "name": "Can I negotiate volume discounts?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For large-scale enterprise usage, contact Anthropic's sales team. Volume commitments can lead to custom pricing."
      }
    },
    {
      "@type": "Question",
      "name": "What happens if I exceed my rate limit?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You receive a 429 HTTP error. The response headers indicate when the limit resets. Implement retry logic to handle this gracefully."
      }
    },
    {
      "@type": "Question",
      "name": "How does Claude API pricing compare to running local models?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Local models (via Ollama, llama.cpp) have zero per-token cost but require GPU hardware ($2,000-$10,000+). For most developers, API access is cheaper unless you process millions of tokens daily. The breakeven point depends on your hardware cost, electricity, and usage volume."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use multiple API keys for higher rate limits?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Each API key shares the organization-level rate limit. Multiple keys do not increase your total throughput. To get higher limits, upgrade your API tier by adding prepaid credits."
      }
    }
  ]
}
</script>

## See Also

- [Claude Extra Usage Cost Guide](/claude-extra-usage-cost-guide/)
- [Claude 5-Hour Usage Limit Guide](/claude-5-hour-usage-limit-guide/)
- [Claude Pro Subscription Price Guide](/claude-pro-subscription-price-guide/)


{% endraw %}