---
sitemap: false
layout: default
title: "Claude Code Model Selection for Cost (2026)"
description: "Choose the right Claude Code model for each task type using cost-per-token analysis showing Haiku at $0.48, Sonnet at $1.80, and Opus at $9.00 per 100K tokens."
permalink: /claude-code-model-selection-cost-sonnet-haiku-opus/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Claude Code Model Selection for Cost: Sonnet vs Haiku vs Opus

## The Problem

Using Opus 4.6 for every Claude Code task is like hiring a senior architect to change light bulbs. At $15/MTok input and $75/MTok output, Opus costs 5x more than Sonnet 4.6 ($3/$15) and 18.75x more than Haiku 4.5 ($0.80/$4). A developer spending $300/month on all-Opus usage could achieve the same results for $80-$120 by routing 70% of tasks to cheaper models. That is $180-$220 saved monthly with zero quality loss on the routed tasks.

## Quick Wins (Under 5 Minutes)

1. **Set Sonnet as default** -- add `"model": "sonnet"` to Claude Code settings or use `--model sonnet` flag.
2. **Use Haiku for search and file operations** -- `claude --model haiku "Find all files importing the auth module"`.
3. **Reserve Opus for architecture decisions and complex debugging** -- use it intentionally, not by default.
4. **Check model in /cost output** -- verify which model is actively billing.

## Deep Optimization Strategies

### Strategy 1: The Model Cost Matrix

Every task has a minimum model capability threshold. Anything above that threshold is wasted spend.

```text
Cost per 100K tokens (blended input + output at 3:1 ratio):

Haiku 4.5:   (75K * $0.80/M) + (25K * $4.00/M) = $0.06 + $0.10 = $0.16
Sonnet 4.6:  (75K * $3.00/M) + (25K * $15.0/M) = $0.225 + $0.375 = $0.60
Opus 4.6:    (75K * $15.0/M) + (25K * $75.0/M) = $1.125 + $1.875 = $3.00

Opus is 5x Sonnet and 18.75x Haiku per 100K tokens.
```

| Task Category | Minimum Model | Cost per Task (est. 50K tokens) |
|--------------|---------------|-------------------------------|
| File search, grep, glob | Haiku 4.5 | $0.08 |
| Simple edits, renames | Haiku 4.5 | $0.08 |
| Standard coding, refactoring | Sonnet 4.6 | $0.30 |
| Test writing, documentation | Sonnet 4.6 | $0.30 |
| PR review, code analysis | Sonnet 4.6 | $0.30 |
| Complex architecture design | Opus 4.6 | $1.50 |
| Multi-file refactoring with dependencies | Opus 4.6 | $1.50 |
| Debugging subtle race conditions | Opus 4.6 | $1.50 |

### Strategy 2: Task-Based Model Routing

Encode [Claude Code router guide](/claude-code-router-guide/) decisions in CLAUDE.md so the choice is made before work begins, not after tokens are spent.

```yaml
# CLAUDE.md -- model routing policy
## Model Selection
When starting a task, select the model based on complexity:

### Use Haiku 4.5 (cheapest) for:
- Finding files, searching code, listing dependencies
- Simple find-and-replace operations
- Reading file structure and reporting contents
- Running test suites and reporting results

### Use Sonnet 4.6 (default) for:
- Writing new functions or endpoints
- Refactoring existing code within a single module
- Writing or updating tests
- Code review and PR feedback
- Bug fixes with known location

### Use Opus 4.6 (premium) for:
- Designing new system architecture
- Debugging issues that span 3+ modules
- Performance optimization requiring algorithmic analysis
- Security audits and vulnerability assessment
- Migrating between frameworks or languages
```

```bash
# Model routing in practice:

# Discovery phase: use Haiku
claude --model haiku "List all API endpoints in src/routes/ and their HTTP methods"

# Implementation phase: use Sonnet
claude --model sonnet "Add rate limiting middleware to the /api/payments endpoint using express-rate-limit"

# Architecture phase: use Opus
claude --model opus "Design the migration from our monolithic auth to a microservice with shared session tokens"
```

### Strategy 3: Session Model Switching

Within a single session, switch models when transitioning between task phases. The discovery phase (cheap) should not subsidize the implementation phase (standard) at premium rates.

```bash
# Start with Haiku for exploration
claude --model haiku
> "Scan the project and summarize the directory structure"
> "Find all files that import from @/lib/database"
> "List the test coverage gaps in src/services/"

# Identified the work -- switch to Sonnet
# Start a new session with the gathered context
claude --model sonnet "Based on the coverage gaps in src/services/payment.ts (functions processRefund and validateCard have no tests), write unit tests using Vitest"

# Hit a complex issue -- escalate to Opus
claude --model opus "The processRefund function has a race condition when two refunds are issued simultaneously for the same order. Design a locking mechanism."
```

The three-session approach costs approximately:
- Haiku exploration: 30K tokens = $0.05
- Sonnet implementation: 60K tokens = $0.36
- Opus architecture: 40K tokens = $1.20
- **Total: $1.61**

Using Opus for everything: 130K tokens = $3.90. **Savings: 59%.**

### Strategy 4: Batch Operations on Haiku

For repetitive operations across many files (formatting, linting fixes, boilerplate generation), Haiku provides massive cost savings.

```bash
# Batch rename operations -- Haiku handles these perfectly
claude --model haiku "Rename all instances of 'userId' to 'user_id' in the src/models/ directory to match our snake_case database columns"

# Batch documentation -- Haiku writes JSDoc comments efficiently
claude --model haiku "Add JSDoc comments to all exported functions in src/utils/ that are currently undocumented"

# Batch test stubs -- Haiku generates test scaffolding
claude --model haiku "Create empty test file stubs with describe blocks for every file in src/services/ that doesn't have a corresponding test file"
```

Each batch operation on Haiku costs approximately $0.05-$0.15 (30K-80K tokens). The same operations on Opus would cost $0.90-$2.40. Running 10 batch operations per week saves $8.50-$22.50 weekly.

### Strategy 5: Quality Checkpoints

The risk of routing to cheaper models is quality regression. Build quality checkpoints into the workflow to catch cases where a cheaper model was insufficient.

```yaml
# CLAUDE.md -- quality checkpoints
## Quality Verification After Model Routing
- After Haiku tasks: verify output with a quick manual review (2-second scan)
- After Sonnet tasks: run the test suite (`pnpm test`) before accepting
- Escalation rule: if Sonnet fails a task after 2 attempts, escalate to Opus
- Never downgrade to Haiku for tasks that involve business logic changes
```

```bash
# Automated quality check after Sonnet implementation
claude --model sonnet "Implement the validateCard function with Luhn algorithm"

# Run tests to verify quality
pnpm test src/services/payment.test.ts

# If tests fail, escalate:
claude --model opus "The Luhn algorithm in validateCard fails for Amex cards (15 digits). Fix the implementation."
```

The escalation adds one Opus call when needed (perhaps 10% of the time), but the 90% of tasks completed at Sonnet rates still deliver overall savings.

## Measuring Your Savings

```bash
# Track model usage distribution
ccusage --days 7 --format table

# Target distribution for maximum cost efficiency:
# Haiku: 20-30% of sessions (search, batch, simple tasks)
# Sonnet: 50-60% of sessions (standard development work)
# Opus: 10-20% of sessions (complex architecture only)

# Calculate actual savings:
# If Opus-only monthly cost would be $300
# With routing (20% Haiku, 60% Sonnet, 20% Opus):
# = ($300 * 0.20 * 1/18.75) + ($300 * 0.60 * 1/5) + ($300 * 0.20 * 1)
# = $3.20 + $36 + $60 = $99.20
# Savings: $200.80/month (67%)
```

## Cost Impact Summary

| Routing Strategy | Monthly Cost (Solo) | Savings vs All-Opus |
|-----------------|--------------------|--------------------|
| All Opus (baseline) | $300 | -- |
| All Sonnet | $60 | $240 (80%) |
| Smart routing (20/60/20) | $99 | $201 (67%) |
| Aggressive routing (30/60/10) | $73 | $227 (76%) |



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code Max Subscription vs API](/claude-code-max-vs-api-cheaper-2026-calculator/) -- fixed vs variable pricing comparison
- [Claude Code Extended Thinking: Cost Implications](/claude-code-extended-thinking-cost-when-disable/) -- when extended thinking justifies premium model costs
- [How to Reduce Claude Code Token Usage by 3x](/reduce-claude-code-token-usage-3x-guide-2026/) -- complementary reduction strategies

- [Claude temperature settings guide](/claude-temperature-settings-guide/) — How to configure temperature and sampling parameters in Claude

## See Also

- [Smart Model Selection Saves 80% on Claude API](/smart-model-selection-saves-80-percent-claude/)
