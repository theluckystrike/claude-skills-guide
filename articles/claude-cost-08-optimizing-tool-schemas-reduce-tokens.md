---
layout: default
title: "Optimizing Tool Schemas to Cut Token (2026)"
description: "Claude Code cost insight: trim verbose tool schemas by 50% and save $50 per 10,000 Opus requests. Practical techniques for leaner JSON definitions."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /optimizing-tool-schemas-reduce-token-count/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, tool-schemas, optimization]
---

# Optimizing Tool Schemas to Cut Token Count

A verbose tool schema with detailed descriptions, examples, and optional parameters can run 800+ tokens. The same tool with minimal descriptions and only required parameters fits in 200 tokens. That 600-token difference, multiplied across 10,000 Opus 4.7 requests at $5.00/MTok, costs $30.00 per tool per batch. Most APIs send 3-5 tools, making schema bloat a $90-$150 problem per 10,000 requests.

## The Setup

Tool schemas get tokenized into the input context on every request. Every word in your `description` field, every `enum` value in your `properties`, and every nested object in your `input_schema` contributes tokens that get billed at the input rate. Developers tend to write thorough tool descriptions with usage examples, edge case documentation, and verbose parameter descriptions. While this can marginally improve the model's tool selection accuracy, Claude models are generally good at understanding tool purposes from concise descriptions. The cost of verbosity compounds because tool definitions don't benefit from prompt caching in most configurations -- they're re-tokenized fresh on every request.

## The Math

Three tools with verbose vs. minimal schemas:

**Verbose schemas (original):**

| Tool | Description | Schema | Total Tokens |
|------|-------------|--------|-------------|
| search_products | 120 tokens | 280 tokens | 400 |
| create_order | 150 tokens | 350 tokens | 500 |
| get_shipping | 100 tokens | 250 tokens | 350 |
| **Total** | | | **1,250** |

**Minimal schemas (optimized):**

| Tool | Description | Schema | Total Tokens |
|------|-------------|--------|-------------|
| search_products | 25 tokens | 120 tokens | 145 |
| create_order | 30 tokens | 150 tokens | 180 |
| get_shipping | 20 tokens | 100 tokens | 120 |
| **Total** | | | **445** |

**Token savings: 805 tokens per request (64% reduction)**

At Opus 4.7 ($5.00/MTok), 10,000 requests/day:
- Before: 1,250 x 10K x 30 x $5/MTok = **$1,875/month**
- After: 445 x 10K x 30 x $5/MTok = **$667.50/month**
- **Savings: $1,207.50/month**

## The Technique

Apply these four rules to shrink every tool definition:

```python
# BEFORE: Verbose tool definition (~500 tokens)
verbose_tool = {
    "name": "search_products",
    "description": (
        "Search the product catalog to find products matching "
        "the user's query. This tool searches across product names, "
        "descriptions, categories, and tags. Results are returned "
        "in order of relevance. Use this tool when the user asks "
        "about finding, browsing, or looking for products. Do not "
        "use this tool for order-related queries."
    ),
    "input_schema": {
        "type": "object",
        "properties": {
            "query": {
                "type": "string",
                "description": (
                    "The search query string. Can be a product name, "
                    "category, or description keywords. Examples: "
                    "'red running shoes', 'laptop under 1000', "
                    "'organic coffee beans'"
                )
            },
            "category": {
                "type": "string",
                "description": "Optional category filter",
                "enum": [
                    "electronics", "clothing", "food",
                    "home", "sports", "books", "toys",
                    "automotive", "garden", "health"
                ]
            },
            "max_results": {
                "type": "integer",
                "description": "Maximum number of results (1-50, default 10)",
                "minimum": 1,
                "maximum": 50,
                "default": 10
            },
            "sort_by": {
                "type": "string",
                "description": "Sort order for results",
                "enum": ["relevance", "price_asc", "price_desc", "newest"],
                "default": "relevance"
            },
            "in_stock_only": {
                "type": "boolean",
                "description": "Filter to only in-stock items",
                "default": True
            }
        },
        "required": ["query"]
    }
}

# AFTER: Minimal tool definition (~145 tokens)
minimal_tool = {
    "name": "search_products",
    "description": "Search product catalog by name or category",
    "input_schema": {
        "type": "object",
        "properties": {
            "query": {
                "type": "string"
            },
            "category": {
                "type": "string"
            },
            "max_results": {
                "type": "integer"
            }
        },
        "required": ["query"]
    }
}

# The four rules applied:
# 1. Description: one sentence, no usage instructions
# 2. Remove parameter descriptions (model infers from names)
# 3. Remove enums unless critical for correctness
# 4. Remove optional parameters the model rarely uses
```

For automated schema optimization:

```python
def minimize_tool_schema(tool: dict) -> dict:
    """Strip a tool definition to minimum viable tokens."""
    minimized = {
        "name": tool["name"],
        "description": tool["description"].split(".")[0] + ".",  # first sentence
        "input_schema": {
            "type": "object",
            "properties": {},
            "required": tool["input_schema"].get("required", [])
        }
    }

    for prop_name, prop_def in tool["input_schema"]["properties"].items():
        # Keep only type, drop description/enum/default/examples
        minimized["input_schema"]["properties"][prop_name] = {
            "type": prop_def["type"]
        }

    return minimized
```

## The Tradeoffs

Removing descriptions and enums can reduce the model's accuracy in choosing the right tool or providing valid parameter values. If your tool has strict enum requirements (e.g., only 3 valid status codes), keep those enums -- the cost of a failed API call from an invalid parameter exceeds the token savings. Test schema changes against a representative sample of queries and measure tool selection accuracy. Start by removing descriptions from self-explanatory parameters (like `query`, `name`, `email`) and keep descriptions only where the parameter name is ambiguous.

## Implementation Checklist

- Count tokens in each tool definition using `anthropic.count_tokens()`
- Apply the four minimization rules to each tool
- Run an A/B test comparing tool selection accuracy with verbose vs. minimal schemas
- Keep enums only for parameters where invalid values cause errors
- Remove parameters the model uses less than 5% of the time
- Set a per-tool token budget (e.g., 200 tokens max) and enforce it in CI

## Measuring Impact

Measure `usage.input_tokens` before and after schema optimization on identical request payloads. The difference equals your per-request token savings. Track tool selection accuracy (did the model pick the right tool?) and parameter validity (did the model provide valid parameter values?) alongside cost. A 50% schema reduction with less than 2% accuracy drop is the sweet spot. At Haiku 4.5 rates ($1.00/MTok), even modest savings compound: 500 tokens saved across 100,000 daily requests = $1,500/month.

## Related Guides

- [Claude API Tool Use Function Calling Deep Dive](/claude-api-tool-use-function-calling-deep-dive-guide/)
- [Advanced Claude Skills with Tool Use](/advanced-claude-skills-with-tool-use-and-function-calling/)
- [Claude Skills Token Optimization Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/)

## See Also

- [Claude Code /compact Saves Thousands of Tokens](/claude-code-compact-saves-thousands-tokens/)
- [Claude Bash Tool Costs 245 Tokens Per Call](/claude-bash-tool-costs-245-tokens-per-call/)
- [Real-Time Claude Token Monitoring Pipeline](/real-time-claude-token-monitoring-pipeline/)
- [Lean Prompting: Fewer Tokens, Same Quality](/lean-prompting-fewer-tokens-same-quality/)
- [Claude Code Expensive? Here Are 7 Fixes](/claude-code-expensive-7-fixes/)
