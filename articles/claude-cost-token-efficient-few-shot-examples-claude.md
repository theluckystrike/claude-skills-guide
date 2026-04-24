---
layout: default
title: "Token-Efficient Few-Shot Examples"
description: "Compress Claude few-shot examples from 2,000 to 400 tokens — save $80 per 10K Opus requests while maintaining 95%+ accuracy."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /token-efficient-few-shot-examples-claude/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction]
render_with_liquid: false
---

# Token-Efficient Few-Shot Examples for Claude

Few-shot examples in Claude prompts typically consume 1,500-3,000 tokens. Compressing them to input-output pairs cuts that to 300-500 tokens — an 80% reduction that saves $80 per 10,000 Opus 4.7 requests. At 30,000 requests/month, that is $240/month in savings from reformatting your examples alone.

## The Setup

Few-shot learning works by showing Claude examples of desired input-output behavior. The standard approach includes full input text, detailed analysis, and formatted output for each example. This is effective for accuracy but wasteful for tokens.

Claude does not need verbose explanations in examples. It extracts the pattern from minimal input-output pairs just as effectively. This guide shows five techniques to compress few-shot examples without losing the accuracy gains they provide.

## The Math

**Standard verbose few-shot (5 examples):**
- Average 400 tokens per example (input + analysis + output)
- Total: 2,000 tokens
- Cost per 10K requests on Opus 4.7: 2,000 * 10,000 * $5.00/MTok = $100.00

**Compressed few-shot (5 examples):**
- Average 80 tokens per example (input -> output only)
- Total: 400 tokens
- Cost per 10K requests: 400 * 10,000 * $5.00/MTok = $20.00

**Savings: $80 per 10K requests (80%)**

At 300,000 requests/month on Opus: $2,400/month saved.
At 300,000 requests/month on Sonnet 4.6: $1,440/month saved.

## The Technique

### Pattern 1: Strip Analysis, Keep Input-Output Pairs

```python
import anthropic

client = anthropic.Anthropic()

# VERBOSE few-shot (~2,000 tokens for 5 examples)
verbose_system = """Classify customer messages into categories.

Example 1:
Input: "I was charged twice on my credit card for the same order placed last Tuesday"
Analysis: The customer is reporting a duplicate charge on their credit card. This is clearly a billing-related issue as it involves incorrect charges. The customer may need a refund.
Category: BILLING
Confidence: 0.95

Example 2:
Input: "The app crashes every time I try to upload a photo larger than 5MB"
Analysis: The customer is experiencing a technical problem with the application. The crash occurs during a specific action (photo upload) with a specific condition (file size > 5MB). This is a reproducible bug.
Category: TECHNICAL
Confidence: 0.92

Example 3:
Input: "Can you add the ability to export reports as PDF files?"
Analysis: The customer is requesting a new feature. They want PDF export functionality for reports. This is not a bug or complaint but a product enhancement suggestion.
Category: FEATURE_REQUEST
Confidence: 0.98

Example 4:
Input: "What are your business hours on weekends?"
Analysis: This is a general inquiry about the company's operating schedule. Not a complaint, bug, or feature request.
Category: GENERAL
Confidence: 0.99

Example 5:
Input: "I can't access my account after you changed the login page yesterday"
Analysis: The customer lost access to their account following a recent update. This is a technical issue related to the login system change.
Category: TECHNICAL
Confidence: 0.90"""

# COMPRESSED few-shot (~400 tokens for 5 examples)
compact_system = """Classify messages: BILLING, TECHNICAL, FEATURE_REQUEST, GENERAL.
Output: {"category": "...", "confidence": 0.0-1.0}

"Charged twice on credit card" -> {"category": "BILLING", "confidence": 0.95}
"App crashes on photo upload >5MB" -> {"category": "TECHNICAL", "confidence": 0.92}
"Add PDF export for reports" -> {"category": "FEATURE_REQUEST", "confidence": 0.98}
"Business hours on weekends?" -> {"category": "GENERAL", "confidence": 0.99}
"Can't access account after login page change" -> {"category": "TECHNICAL", "confidence": 0.90}"""

response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=100,
    system=compact_system,
    messages=[{"role": "user", "content": "My invoice shows the wrong tax amount"}],
)
print(response.content[0].text)
```

### Pattern 2: Use Table Format for Multi-Feature Examples

```python
# Table format is more token-efficient than repeated key-value pairs
table_examples = """Extract entities from text.

| Input | Person | Org | Location | Date |
|-------|--------|-----|----------|------|
| "Tim Cook announced Apple's Q4 results in Cupertino on Oct 30" | Tim Cook | Apple | Cupertino | Oct 30 |
| "Satya Nadella spoke at Microsoft Build in Seattle" | Satya Nadella | Microsoft | Seattle | null |
| "The mayor of Austin signed the agreement last Friday" | null | null | Austin | last Friday |"""
```

### Pattern 3: Reduce Example Count with Strategic Selection

```python
def select_minimal_examples(all_examples: list, target_count: int = 3) -> list:
    """Select the most diverse subset of examples to cover all categories."""
    categories_covered = set()
    selected = []

    # Prioritize examples that cover new categories
    for example in all_examples:
        if example["category"] not in categories_covered:
            selected.append(example)
            categories_covered.add(example["category"])
            if len(selected) >= target_count:
                break

    # If we still need more, add edge cases
    while len(selected) < target_count and len(selected) < len(all_examples):
        for example in all_examples:
            if example not in selected:
                selected.append(example)
                break

    return selected

# Often 3 well-chosen examples work as well as 5-7 redundant ones
# Savings: 40-60% fewer example tokens
```

### Pattern 4: One-Line Examples with Separator

```python
# Ultra-compact format for simple classification
compact = """Sentiment: POS/NEG/NEU
Happy with purchase -> POS | Broken on arrival -> NEG | Package arrived -> NEU | Love this product -> POS | Worst experience ever -> NEG"""
```

### Pattern 5: Validate Compression Did Not Reduce Accuracy

```python
def validate_few_shot_accuracy(
    verbose_system: str,
    compact_system: str,
    test_cases: list,
    model: str = "claude-sonnet-4-6",
) -> dict:
    """Compare accuracy of verbose vs compact few-shot prompts."""
    verbose_correct = 0
    compact_correct = 0

    for case in test_cases:
        v_resp = client.messages.create(
            model=model, max_tokens=100, system=verbose_system,
            messages=[{"role": "user", "content": case["input"]}],
        )
        c_resp = client.messages.create(
            model=model, max_tokens=100, system=compact_system,
            messages=[{"role": "user", "content": case["input"]}],
        )

        if case["expected"] in v_resp.content[0].text:
            verbose_correct += 1
        if case["expected"] in c_resp.content[0].text:
            compact_correct += 1

    return {
        "verbose_accuracy": f"{verbose_correct/len(test_cases)*100:.1f}%",
        "compact_accuracy": f"{compact_correct/len(test_cases)*100:.1f}%",
        "test_cases": len(test_cases),
    }

test_data = [
    {"input": "Refund my last payment", "expected": "BILLING"},
    {"input": "Page loads very slowly", "expected": "TECHNICAL"},
    {"input": "Add two-factor auth option", "expected": "FEATURE_REQUEST"},
]
results = validate_few_shot_accuracy(verbose_system, compact_system, test_data)
print(f"Verbose: {results['verbose_accuracy']} | Compact: {results['compact_accuracy']}")
```

## The Tradeoffs

Compact examples work best for classification and extraction tasks with clear categories. For generation tasks (writing, coding), more detailed examples showing style and reasoning often produce better output. Test before committing.

Reducing from 5 examples to 3 saves 40% of example tokens but may reduce accuracy on edge cases. If your task has more than 5 categories, keep at least one example per category.

Table format breaks down for examples with long text fields. Use it for short, structured data only.

## Implementation Checklist

1. Count tokens in your current few-shot examples
2. Rewrite examples as input -> output pairs (strip analysis)
3. Reduce example count to the minimum that covers all categories
4. Run accuracy comparison on 100 test cases
5. Deploy compressed examples if accuracy holds within 2%
6. Monitor classification accuracy weekly

## Measuring Impact

Compare total example tokens before and after compression. Multiply savings by request volume and model rate. Track classification accuracy on a weekly test set of 50 labeled examples. If accuracy drops more than 3%, add back one carefully selected example at a time until accuracy recovers. The sweet spot is typically 3-5 compressed examples.

## Related Guides

- [Claude Code Token Usage Optimization](/claude-code-token-usage-optimization-best-practices-guide/) — optimize tokens across your entire prompt
- [Reduce Claude Code Hallucinations Save Tokens](/reduce-claude-code-hallucinations-save-tokens-accuracy-tips/) — better examples reduce hallucination-driven retries
- [Claude Skill Token Usage Profiling](/claude-skill-token-usage-profiling-and-optimization/) — measure per-skill token consumption
