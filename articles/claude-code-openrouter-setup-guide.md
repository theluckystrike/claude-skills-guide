---
layout: default
title: "Claude Code with OpenRouter (2026)"
description: "Set up Claude Code with OpenRouter for model routing, cost comparison, and multi-provider access. Step-by-step configuration with real examples."
permalink: /claude-code-openrouter-setup-guide/
date: 2026-04-20
last_tested: "2026-04-24"
---

# Claude Code with OpenRouter: Setup Guide (2026)

OpenRouter is an API gateway that gives you access to multiple AI model providers through a single API key. Instead of managing separate keys for Anthropic, OpenAI, Google, and others, you configure one OpenRouter key and route requests to any supported model.

This guide covers why you might use OpenRouter with Claude Code, how to set it up, model routing strategies, and a cost comparison against the direct Anthropic API.

## What Is OpenRouter?

OpenRouter acts as a proxy between your application and AI model providers. You send requests to OpenRouter's endpoint, and it forwards them to the appropriate provider.

Key features:
- **Single API key** for Anthropic, OpenAI, Google, Meta, Mistral, and 200+ models
- **Automatic fallback**: If one provider is down, OpenRouter can route to an alternative
- **Usage tracking**: Centralized dashboard for all model usage
- **Rate limit pooling**: Access to higher rate limits than individual free tiers
- **Pay-as-you-go**: No subscriptions. Pay only for tokens used.

## Why Use OpenRouter with Claude Code?

### Reason 1: Unified Billing

If you use Claude Code alongside other AI tools, OpenRouter consolidates everything into one bill. No need to manage credit balances across Anthropic, OpenAI, and other providers.

### Reason 2: Model Flexibility

OpenRouter lets you access non-Anthropic models through Claude Code's interface. While Claude Code is optimized for Claude models, routing through OpenRouter gives you the option to experiment with other providers.

### Reason 3: Fallback Routing

When Anthropic's API has outages or rate limit issues, OpenRouter can automatically retry through alternative endpoints. This reduces the "[not working](/claude-not-working-right-now-fix/)" downtime you experience.

### Reason 4: Budget Controls

OpenRouter provides spending limits, usage alerts, and per-key budgets that go beyond Anthropic's built-in controls. Useful for teams managing multiple developers.

### Reason 5: Free Tier Access

Some models on OpenRouter have free tiers. You can test smaller models at zero cost before committing to paid Claude usage.

## Setup Steps

### Step 1: Create an OpenRouter Account

1. Go to openrouter.ai
2. Create an account (GitHub or email)
3. Add credits ($5 minimum recommended for testing)

### Step 2: Generate an API Key

1. Navigate to openrouter.ai/keys
2. Click "Create Key"
3. Name it (e.g., "claude-code")
4. Optionally set a credit limit for this key
5. Copy the key (starts with `sk-or-v1-`)

### Step 3: Configure Claude Code

Set the environment variables that tell Claude Code to route through OpenRouter:

```bash
export ANTHROPIC_BASE_URL="https://openrouter.ai/api/v1"
export ANTHROPIC_API_KEY="sk-or-v1-your-key-here"
```

Add these to your shell profile for persistence:

```bash
echo 'export ANTHROPIC_BASE_URL="https://openrouter.ai/api/v1"' >> ~/.zshrc
echo 'export ANTHROPIC_API_KEY="sk-or-v1-your-key-here"' >> ~/.zshrc
source ~/.zshrc
```

### Step 4: Verify the Connection

Start Claude Code:

```bash
claude
```

Type a simple prompt:

```
What model are you running on?
```

Claude should respond normally. If you see errors, check the troubleshooting section below.

### Step 5: Select a Model (Optional)

By default, Claude Code requests `claude-sonnet-4-20250514` through OpenRouter. OpenRouter maps this to the actual Anthropic model.

To use a specific model through OpenRouter, you can set the model in your Claude Code session:

```
/model claude-opus-4-0520
```

OpenRouter recognizes Anthropic's model identifiers and routes accordingly.

## Model Routing Strategies

### Strategy 1: Direct Claude Models

The simplest approach. Use OpenRouter purely as a proxy to Anthropic:

```bash
# These model names are forwarded to Anthropic
claude-opus-4-0520
claude-sonnet-4-20250514
claude-3-5-haiku-20241022
```

This gives you OpenRouter's billing and monitoring while using the same models you would use directly.

### Strategy 2: Cost-Optimized Routing

OpenRouter sometimes offers slightly different pricing than direct API access. Check current rates on the OpenRouter pricing page and compare with [direct Anthropic pricing](/claude-api-pricing-complete-guide/).

### Strategy 3: Per-Key Routing

Create separate OpenRouter keys for different purposes:

```bash
# Development key with low limit
export ANTHROPIC_API_KEY="sk-or-v1-dev-key"  # $10 limit

# Production key with higher limit
export ANTHROPIC_API_KEY="sk-or-v1-prod-key"  # $500 limit
```

This prevents development experimentation from eating into your production budget.

## Cost Comparison: OpenRouter vs Direct API

OpenRouter adds a small markup to provider prices. Here are the current rates:

### Claude Sonnet 4

| Provider | Input/MTok | Output/MTok |
|----------|-----------|-------------|
| Direct Anthropic | $3.00 | $15.00 |
| OpenRouter | ~$3.00 | ~$15.00 |
| Difference | ~0% | ~0% |

### Claude Opus 4

| Provider | Input/MTok | Output/MTok |
|----------|-----------|-------------|
| Direct Anthropic | $15.00 | $75.00 |
| OpenRouter | ~$15.00 | ~$75.00 |
| Difference | ~0% | ~0% |

OpenRouter typically passes through provider pricing at or near 1:1 for major models. The markup, when present, is small. Check openrouter.ai/models for current exact pricing as rates change.

### When OpenRouter Saves Money

- **Free tier models**: Some smaller models on OpenRouter have free quotas
- **Consolidated billing**: Avoiding minimum credit purchases across multiple providers
- **Key-level budgets**: Preventing overspend more granularly than Anthropic's console allows

### When Direct API Is Cheaper

- **Prompt caching**: OpenRouter may not support Anthropic's prompt caching feature, which can save up to 90% on repeated prompts
- **Batch API**: Direct Anthropic batch processing at 50% discount may not be available through OpenRouter
- **Volume discounts**: Enterprise Anthropic agreements typically beat OpenRouter rates

## Configuration Options

### Request Headers

OpenRouter supports custom headers for request routing:

```bash
# Set HTTP referer for tracking in OpenRouter dashboard
export OPENROUTER_REFERRER="https://your-app.com"
```

### Timeout Configuration

If you experience timeouts through OpenRouter (extra network hop adds latency):

```bash
# Increase timeout for Opus 4 (which can be slow for complex tasks)
export ANTHROPIC_TIMEOUT=120000  # 120 seconds
```

### Switching Between OpenRouter and Direct

Create shell aliases for quick switching:

```bash
# In ~/.zshrc
alias claude-direct='unset ANTHROPIC_BASE_URL && claude'
alias claude-openrouter='export ANTHROPIC_BASE_URL="https://openrouter.ai/api/v1" && claude'
```

Then use `claude-direct` or `claude-openrouter` depending on your needs.

*Need the complete toolkit? [The Claude Code Playbook](https://zovo.one/pricing) includes 200 production-ready templates.*

## Monitoring and Analytics

### OpenRouter Dashboard

OpenRouter provides a web dashboard at openrouter.ai/activity showing:

- **Request log**: Every API call with model, tokens, cost, and latency
- **Daily/weekly/monthly spending**: Charts showing cost trends
- **Model breakdown**: Which models you use most and their relative costs
- **Error rates**: Failed requests and their causes
- **Latency percentiles**: P50, P95, P99 response times

### Setting Up Spending Alerts

OpenRouter supports per-key credit limits:

1. Go to openrouter.ai/keys
2. Click on your key
3. Set a "Credit limit" (e.g., $50)
4. When the key hits the limit, requests are rejected

This prevents runaway costs from automated workflows or accidentally leaving Claude Code running.

### Comparing Usage Across Providers

If you use OpenRouter alongside direct Anthropic access, compare monthly costs:

```bash
# Check OpenRouter spending
# Visit openrouter.ai/activity

# Check Anthropic spending
# Visit console.anthropic.com/settings/usage
```

Track which approach gives you better cost-per-quality for your specific usage patterns. Some developers find that OpenRouter's monitoring alone is worth the marginal cost difference.

### Integration with Cost Tracking Tools

For teams that track AI spending across projects, OpenRouter's API provides usage data:

```bash
curl https://openrouter.ai/api/v1/auth/key \
  -H "Authorization: Bearer sk-or-v1-your-key"
```

This returns your current credit balance and usage statistics. Build dashboards or alerts on top of this endpoint for [team cost management](/claude-code-cost-alerts-notifications-budget/).

## Troubleshooting

### "Authentication failed" Error

1. Verify your OpenRouter API key is correct
2. Check that credits are available on your OpenRouter account
3. Ensure the key is not expired or revoked
4. Test the key with a direct curl:

```bash
curl https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer sk-or-v1-your-key" \
  -H "Content-Type: application/json" \
  -d '{"model":"claude-sonnet-4-20250514","messages":[{"role":"user","content":"Hello"}]}'
```

### "Model not found" Error

OpenRouter model names must match exactly. Use the model identifiers listed on openrouter.ai/models. Common mistakes:
- Using `claude-3-sonnet` instead of `claude-sonnet-4-20250514`
- Missing the date suffix

### Slow Responses

OpenRouter adds one network hop (your machine to OpenRouter to Anthropic). Expect 100-500ms additional latency on first-token timing. This is usually not noticeable for [Claude Code sessions](/best-claude-code-productivity-hacks-2026/) but may matter for latency-sensitive applications.

### Feature Incompatibilities

Some Anthropic-specific features may not work through OpenRouter:
- **Prompt caching**: May not be supported
- **Extended thinking**: Check OpenRouter docs for current support
- **Batch API**: Not available through OpenRouter
- **Beta headers**: May be stripped by the proxy

If you need these features, use the direct Anthropic API.

### Rate Limit Errors

OpenRouter has its own rate limits in addition to provider limits. If you hit 429 errors:

1. Check your OpenRouter dashboard for current limits
2. Upgrade your OpenRouter tier for higher limits
3. Implement backoff in your workflow
4. See our [rate limit troubleshooting guide](/anthropic-api-error-429-rate-limit/)

## Security Considerations

### API Key Exposure

Your OpenRouter key provides access to all models you have configured. Treat it with the same security as a direct [API key](/claude-api-pricing-complete-guide/):
- Never commit it to git
- Use environment variables, not hardcoded values
- Rotate keys periodically
- Set per-key spending limits

### Data Routing

When using OpenRouter, your prompts travel through OpenRouter's servers before reaching Anthropic. Review OpenRouter's privacy policy if you work with sensitive data. For projects with strict data residency requirements, the direct Anthropic API may be required.

### Key-Level Controls

OpenRouter lets you restrict keys to specific models:
- Create a key that only allows Claude Haiku (cheapest)
- Create another key for Opus (for when you need it)
- Prevent accidental use of expensive models

## Frequently Asked Questions

### Does OpenRouter change Claude's behavior?
No. OpenRouter is a passthrough proxy. Claude receives the same prompts and produces the same outputs. The model does not know or care whether the request came through OpenRouter or directly.

### Can I use my Anthropic subscription through OpenRouter?
No. OpenRouter uses its own billing. Your Pro/Max subscription only works with the direct Anthropic API. OpenRouter requires separate prepaid credits.

### Is OpenRouter reliable enough for production?
OpenRouter has been operating since 2023 and handles significant volume. However, it adds a point of failure. For production-critical applications, consider direct API access with OpenRouter as a fallback.

### Can I see which provider served my request?
Yes. OpenRouter's dashboard shows request logs including the provider used, tokens consumed, cost, and latency.

### Does OpenRouter support streaming?
Yes. Streaming works through OpenRouter the same as through the direct API. Claude Code uses streaming by default.

### Can I set up a team account?
Yes. OpenRouter supports team accounts with shared billing. Each team member gets their own API key under the same billing umbrella.

### What happens when OpenRouter is down?
Claude Code will fail with connection errors. Switch to direct API access: `unset ANTHROPIC_BASE_URL && claude`.

### Is there a free trial?
OpenRouter occasionally offers free credits for new accounts. Some models (particularly smaller open-source ones) have permanent free tiers.

### Can I use OpenRouter with MCP servers?
Yes. [MCP servers](/claude-code-mcp-server-setup/) work independently of the API provider. Whether you use direct Anthropic access or OpenRouter, MCP connections like [Supabase MCP](/claude-code-mcp-supabase-setup-guide/) function the same way.

### Should I use OpenRouter or direct API for Claude Code hooks?
[Claude Code hooks](/claude-code-hooks-complete-guide/) run locally and do not interact with the API provider. Hooks work identically regardless of whether you route through OpenRouter or the direct Anthropic API.


{% raw %}
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "### Does OpenRouter change Claude's behavior?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. OpenRouter is a passthrough proxy. Claude receives the same prompts and produces the same outputs. The model does not know or care whether the request came through OpenRouter or directly."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use my Anthropic subscription through OpenRouter?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. OpenRouter uses its own billing. Your Pro/Max subscription only works with the direct Anthropic API. OpenRouter requires separate prepaid credits."
      }
    },
    {
      "@type": "Question",
      "name": "Is OpenRouter reliable enough for production?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "OpenRouter has been operating since 2023 and handles significant volume. However, it adds a point of failure. For production-critical applications, consider direct API access with OpenRouter as a fallback."
      }
    },
    {
      "@type": "Question",
      "name": "Can I see which provider served my request?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. OpenRouter's dashboard shows request logs including the provider used, tokens consumed, cost, and latency."
      }
    },
    {
      "@type": "Question",
      "name": "Does OpenRouter support streaming?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Streaming works through OpenRouter the same as through the direct API. Claude Code uses streaming by default."
      }
    },
    {
      "@type": "Question",
      "name": "Can I set up a team account?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. OpenRouter supports team accounts with shared billing. Each team member gets their own API key under the same billing umbrella."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when OpenRouter is down?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code will fail with connection errors. Switch to direct API access: unset ANTHROPICBASEURL && claude."
      }
    },
    {
      "@type": "Question",
      "name": "Is there a free trial?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "OpenRouter occasionally offers free credits for new accounts. Some models (particularly smaller open-source ones) have permanent free tiers."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use OpenRouter with MCP servers?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. MCP servers work independently of the API provider. Whether you use direct Anthropic access or OpenRouter, MCP connections like Supabase MCP function the same way."
      }
    },
    {
      "@type": "Question",
      "name": "Should I use OpenRouter or direct API for Claude Code hooks?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code hooks run locally and do not interact with the API provider. Hooks work identically regardless of whether you route through OpenRouter or the direct Anthropic API."
      }
    }
  ]
}
</script>

## See Also

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code + OpenRouter: Alternative Pricing Strategies](/claude-code-openrouter-alternative-pricing/)

{% endraw %}