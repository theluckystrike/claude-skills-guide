---
layout: default
title: "Why Claude Code 4.6 uses more tokens (2026)"
description: "Claude 4.6 models use 10-25% more tokens than 4.5 for the same tasks due to improved reasoning depth. Offset the increase with context engineering techniques."
permalink: /why-claude-code-46-uses-more-tokens-than-45/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Why Claude Code 4.6 uses more tokens than 4.5 (and what to do)

## The Problem

After upgrading from Claude 4.5 models to 4.6 (Sonnet 4.6, Opus 4.6), session token usage increased by 10-25% for similar tasks. A bug fix that consumed 40,000 tokens on Sonnet 4.5 now takes 45,000-50,000 tokens on Sonnet 4.6. At Sonnet 4.6 rates ($3/$15 per MTok), the extra 10,000 tokens per session adds ~$0.06, or $6/month for a developer running 100 sessions. The increase is real but offset by improved task completion quality (fewer retries, better first-attempt accuracy).

## Quick Fix (2 Minutes)

1. **Run `/compact` more aggressively**: After every 5-7 turns instead of waiting for context pressure.
   ```bash
   /compact
   ```

2. **Use Haiku 4.5 for simple tasks**: Haiku 4.5 at $0.80/$4 per MTok handles simple code generation at 73% less cost than Sonnet 4.6.
   ```bash
   claude --model haiku -p "Add JSDoc comments to src/utils/format.ts"
   ```

3. **Scope prompts more tightly**: Compensate for verbose output by reducing input exploration.
   ```bash
   # Instead of: "Fix the auth bug"
   claude -p "In src/auth/session.ts line 42, the timeout is 3600 (1 hour).
   Change it to 86400 (24 hours)."
   ```

## Why This Happens

Claude 4.6 models are more capable than 4.5 across several dimensions, and this capability comes with trade-offs in token usage:

**More thorough reasoning**: 4.6 models provide more detailed explanations of their actions, consider more edge cases, and generate more comprehensive code. A function that 4.5 implemented in 20 lines of output, 4.6 may implement in 25-30 lines with better error handling, type safety, and documentation.

**Improved tool use accuracy**: 4.6 models make fewer incorrect tool calls (reducing retry tokens) but generate more tokens per correct tool call (more detailed arguments, better-structured requests). Net effect: individual calls cost more, but total calls per task decrease.

**Extended thinking patterns**: 4.6 models spend more tokens on internal reasoning before acting, which shows up as longer output per turn. This reasoning produces better results but at higher per-turn token cost.

**Quantified impact across typical tasks**:

| Task Type | 4.5 Tokens | 4.6 Tokens | Increase | 4.6 Retries | Net Effect |
|-----------|-----------|-----------|----------|-------------|------------|
| Simple edit | 15K | 18K | +20% | 50% fewer | ~Same cost |
| Bug fix | 40K | 48K | +20% | 30% fewer | +5% cost |
| Feature implementation | 80K | 95K | +19% | 25% fewer | +8% cost |
| Complex refactor | 150K | 180K | +20% | 40% fewer | ~Same cost |
| Code review | 30K | 38K | +27% | N/A | +27% cost |

The retry reduction partially offsets the per-turn increase. For complex tasks where 4.5 needed 2-3 retries, 4.6 often succeeds on the first attempt, making the net cost similar despite higher per-turn token usage.

## The Full Fix

### Step 1: Diagnose

Compare token usage between recent 4.6 sessions and older 4.5 sessions:

```bash
# Review recent session costs
ccusage --sort date --limit 20

# Look for:
# - Average tokens per session (compare pre/post upgrade)
# - Retry count (should be lower on 4.6)
# - Task completion rate (should be higher on 4.6)
```

### Step 2: Fix

Apply context engineering techniques that offset the 10-25% token increase:

**Strategy 1: Aggressive /compact usage**

```bash
# Before (letting context accumulate):
# Turn 1: 5K tokens
# Turn 5: 25K tokens
# Turn 10: 50K tokens
# Turn 15: 80K tokens (4.6: 96K tokens, 20% more)

# After (compact every 5 turns):
# Turn 1-5: grows to 25K (4.6: 30K)
# /compact: drops to 8K
# Turn 6-10: grows to 33K (4.6: 40K)
# /compact: drops to 12K
# Turn 11-15: grows to 37K (4.6: 44K)

# Without compact: 80K (4.5) vs 96K (4.6) = $0.10 difference
# With compact: 37K (4.5) vs 44K (4.6) = $0.04 difference
# Compact reduces the absolute increase from 16K to 7K tokens
```

**Strategy 2: Model routing for simple tasks**

```bash
# Route simple tasks to Haiku 4.5 (cheaper than Sonnet 4.5 was)
alias cq='claude --model haiku --max-turns 8'    # Quick tasks
alias cs='claude --model sonnet --max-turns 20'   # Standard tasks

# Simple generation on Haiku 4.5: 15K tokens x $1.60/MTok = $0.024
# Same on Sonnet 4.6: 18K tokens x $6.00/MTok = $0.108
# Savings: $0.084 per simple task (78%)
```

**Strategy 3: Pre-computed context to reduce exploration**

Since 4.6 models are more thorough in exploration (reading more files, checking more patterns), providing pre-computed context is even more valuable:

```markdown
# CLAUDE.md -- reduces exploration that 4.6 would otherwise do more of

## Architecture
- Express API in src/api/, Next.js frontend in src/web/
- Entry points: src/api/index.ts, src/web/app/layout.tsx
- Auth: JWT, middleware in src/api/middleware/auth.ts
- DB: Prisma, schema at prisma/schema.prisma

## Common Patterns
- Error handling: Result<T, Error> type, no throwing
- Validation: Zod schemas, colocated with route handlers
- Tests: colocated (foo.test.ts), Jest, mock database
```

This 200-token investment prevents 4.6's more thorough exploration from reading 10-15 files to build the same understanding (~5,000-10,000 tokens saved).

### Step 3: Prevent

```markdown
# CLAUDE.md -- 4.6 Token Optimization

## Session Rules
- Run /compact every 5-7 turns (do not wait for context pressure)
- Use Haiku 4.5 for: documentation, simple generation, formatting
- Use Sonnet 4.6 for: bug fixes, features, refactoring, reviews
- Scope prompts to specific files when location is known
- Max 3 retry cycles per failing operation
```

## Cost Recovery

The 4.6 token increase is a permanent model characteristic, not a bug. Recovery means optimization:

- **Offset with /compact**: Saves 20-40% of accumulated context, neutralizing the 10-25% per-turn increase.
- **Route simple tasks to Haiku**: Saves 73-78% on tasks that do not need Sonnet's reasoning.
- **Improved first-attempt success**: 4.6's fewer retries mean the net cost increase is often only 5-10% rather than the headline 20-25%.

Expected net impact after applying optimizations: 0-5% cost increase versus 4.5, with meaningfully better output quality.

### Quantifying the Net Cost-Quality Tradeoff

The token increase is not pure waste -- it comes with measurable quality improvements:

**Quality metrics (4.6 vs 4.5):**
- First-attempt success rate: 4.6 succeeds on 75-85% of tasks on the first attempt vs. 60-70% for 4.5
- Code quality: 4.6 produces more robust error handling, better type safety, and more comprehensive edge case coverage
- Security awareness: 4.6 more reliably catches potential security issues during code generation

**Cost-quality calculation for a typical month:**

```text
4.5 baseline:
  100 tasks x 40K avg tokens = 4M tokens
  Failed tasks requiring retry: ~30 (30% failure rate)
  Retry cost: 30 x 30K tokens = 900K tokens
  Total: 4.9M tokens x $6/MTok blended = $29.40

4.6 with optimization:
  100 tasks x 48K avg tokens = 4.8M tokens (20% more per task)
  Failed tasks requiring retry: ~18 (18% failure rate, improved)
  Retry cost: 18 x 30K tokens = 540K tokens
  Total: 5.34M tokens x $6/MTok blended = $32.04

Difference: $2.64/month (9% more)
Quality improvement: 40% fewer retries, better code output
```

The $2.64/month cost increase buys significantly better output quality. When factoring in the developer time saved by fewer retries (each retry requires review and potentially a new prompt), the 4.6 upgrade is cost-positive for most teams.

## Prevention Rules for CLAUDE.md

```markdown
## Token Efficiency (4.6 Models)
- Compact after every 5-7 turns (4.6 outputs are more verbose)
- Provide architecture context upfront (prevents 4.6's thorough exploration)
- Use Haiku 4.5 for simple tasks via --model haiku
- Set --max-turns to prevent 4.6's tendency toward completionism
- Track /cost at session end to catch regressions
```

### Comparing 4.5 and 4.6 Side by Side

For teams still deciding whether to upgrade, run the same task on both models and compare:

```bash
# Test task on Sonnet 4.5 (if available)
claude --model sonnet-4-5 --max-turns 10 \
  -p "Write a function that validates email addresses with comprehensive error handling" 2>&1 | tail -5

# Same task on Sonnet 4.6
claude --model sonnet --max-turns 10 \
  -p "Write a function that validates email addresses with comprehensive error handling" 2>&1 | tail -5

# Compare:
# - Token count (4.6 will be 10-25% higher)
# - Code quality (4.6 typically produces more robust error handling)
# - Retry rate (4.6 succeeds on first attempt more often)
```

The upgrade to 4.6 is a net positive for most teams. The 10-25% token increase is offset by fewer retries, better code quality, and more reliable tool usage. The optimization techniques in this guide (aggressive /compact, model routing to Haiku, scoped prompts) neutralize the token increase entirely.

### Budget Adjustment for 4.6

Teams upgrading from 4.5 to 4.6 should adjust token budgets proactively rather than reacting to overspend:

```markdown
# CLAUDE.md -- Budget Adjustment for 4.6 Models
## Updated Token Budgets (4.6 models)
- Quick fix: 50K tokens (was 40K on 4.5)
- Bug fix: 90K tokens (was 80K on 4.5)
- Feature: 135K tokens (was 120K on 4.5)
- Apply /compact at 60% of budget instead of 70%
```

The 12-15% budget increase accounts for 4.6's verbosity while maintaining cost control. Without this adjustment, sessions hit budget limits prematurely, causing incomplete work that requires expensive context rebuilding in follow-up sessions.



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code Compact Command Guide](/claude-code-conversation-too-long-fresh-vs-compact/) -- aggressive compacting strategies
- [Claude Code Sonnet vs Haiku: When Cheaper Is Actually Better](/claude-code-sonnet-vs-haiku-cheaper-actually-better/) -- model routing optimization
- [Cost Optimization Hub](/cost-optimization/) -- comprehensive cost management

## See Also

- [MCP vs CLI for Claude Code: When Each Saves More Tokens](/mcp-vs-cli-claude-code-saves-more-tokens/)
