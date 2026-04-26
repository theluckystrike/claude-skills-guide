---
layout: default
title: "Claude Code /compact Saves Thousands (2026)"
description: "The /compact command reduces Claude Code context by 50-70%. At 180K tokens, that saves $1.80 per session on API equivalent costs."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-code-compact-saves-thousands-tokens/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, claude-code, compact]
---

# Claude Code /compact Saves Thousands of Tokens

The `/compact` command in Claude Code compresses your session context by an estimated 50-70%. A session sitting at 180,000 tokens drops to roughly 60,000 tokens after compaction. On API-equivalent pricing at Opus rates ($5.00/MTok input), each subsequent interaction saves $0.60 in context re-processing. Over 3 remaining interactions, that's $1.80 per session. A team running 50 sessions per day saves $2,700/month from this one command.

## The Setup

Claude Code sessions grow continuously. Every file read, command output, tool result, and conversation turn adds to the context window. After an hour of intensive coding, your context can balloon to 150,000-200,000 tokens. The problem compounds: every new message sends the entire context back to the model, so the cost of each interaction grows linearly with session length. The `/compact` command summarizes the conversation history, distilling key decisions and code changes while discarding verbose intermediate output (command results, file contents already incorporated into edits, exploration dead-ends). The model retains the essential state but in far fewer tokens.

## The Math

A typical 2-hour coding session without compaction:

**Session context growth:**
- Start: 5,000 tokens (system prompt + CLAUDE.md)
- After 30 min: 50,000 tokens (file reads, initial coding)
- After 60 min: 120,000 tokens (debugging, iterations)
- After 90 min: 180,000 tokens (multiple file changes)
- After 120 min: 250,000 tokens (final testing, review)

**Cost of last 3 interactions without /compact (API equivalent at $5.00/MTok):**
- Interaction at 180K: 180K x $5.00/MTok = $0.90
- Interaction at 210K: 210K x $5.00/MTok = $1.05
- Interaction at 250K: 250K x $5.00/MTok = $1.25
- **Total: $3.20 in context tokens alone**

**Cost with /compact at 90-minute mark (reduces 180K to 60K):**
- Interaction at 60K: 60K x $5.00/MTok = $0.30
- Interaction at 90K: 90K x $5.00/MTok = $0.45
- Interaction at 120K: 120K x $5.00/MTok = $0.60
- **Total: $1.35 in context tokens**

**Savings per session: $1.85 (58%)**
**At 50 sessions/day across a team: $2,775/month**

## The Technique

Use `/compact` strategically at key session milestones to maximize token savings.

```bash
# Claude Code session workflow with strategic compaction

# Phase 1: Investigation (context grows fast)
# Read files, run tests, understand the problem
# Context: 0 -> 80K tokens

# Phase 2: First implementation
# Write code, run tests
# Context: 80K -> 150K tokens

# >>> USE /compact HERE <<<
# Context drops: 150K -> ~50K tokens
# Key decisions and code changes preserved
# Verbose file contents and command outputs discarded

# Phase 3: Refinement
# Fix issues, add tests, polish
# Context: 50K -> 100K tokens (instead of 150K -> 220K)

# >>> USE /compact AGAIN if needed <<<
# Context drops: 100K -> ~35K tokens

# Phase 4: Final review and commit
# Context stays manageable: 35K -> 60K tokens
```

Optimize your CLAUDE.md to reduce the baseline context footprint:

```markdown
# CLAUDE.md - Optimized for token efficiency

## Project: MyApp
- Language: TypeScript, Node.js 20
- Framework: Next.js 14, App Router
- Test: Jest + React Testing Library
- Style: ESLint + Prettier, 2-space indent

## Key directories
- src/app/ - routes and pages
- src/components/ - React components
- src/lib/ - utilities and helpers
- src/api/ - API route handlers

## Conventions
- Functional components only
- Server Components by default, "use client" when needed
- Zod for validation
- Error boundaries in layout.tsx files

## Common commands
- `pnpm dev` - start dev server
- `pnpm test` - run tests
- `pnpm lint` - run linter
- `pnpm build` - production build
```

This CLAUDE.md runs about 150 tokens -- far less than a 500+ token version with lengthy explanations and examples. Every token saved in CLAUDE.md saves that token on every single interaction in every session.

```python
# Calculate CLAUDE.md token impact
def claude_md_impact(
    claude_md_tokens: int,
    interactions_per_session: int = 20,
    sessions_per_day: int = 10,
    days_per_month: int = 22,
    input_price_per_mtok: float = 5.00  # Opus rate
) -> dict:
    """Calculate monthly cost of CLAUDE.md tokens."""
    total_appearances = (
        interactions_per_session * sessions_per_day * days_per_month
    )
    total_tokens = claude_md_tokens * total_appearances
    monthly_cost = total_tokens * input_price_per_mtok / 1_000_000

    return {
        "claude_md_tokens": claude_md_tokens,
        "monthly_appearances": total_appearances,
        "monthly_tokens": total_tokens,
        "monthly_cost": f"${monthly_cost:.2f}",
    }

# Compare verbose vs optimized CLAUDE.md
verbose = claude_md_impact(500)  # 500-token CLAUDE.md
optimized = claude_md_impact(150)  # 150-token CLAUDE.md

print(f"Verbose CLAUDE.md: {verbose['monthly_cost']}/month")
print(f"Optimized CLAUDE.md: {optimized['monthly_cost']}/month")
# Verbose: $11.00/month
# Optimized: $3.30/month
# Savings: $7.70/month per developer
```

## The Tradeoffs

Compaction is lossy. The model summarizes rather than preserves exact conversation history, which means specific details about why you rejected an approach, exact error messages, or nuanced discussion about edge cases may be lost. If you need to reference something from earlier in the session after compaction, the model might not remember it accurately. Best practice: compact after major milestones (completed a feature, fixed a bug) rather than mid-investigation. Also, compaction itself consumes tokens -- the model reads the full context to produce the summary, so there's a one-time cost before the ongoing savings.

## Implementation Checklist

- Add `/compact` to your session workflow at natural breakpoints (after each completed task)
- Trim your CLAUDE.md to under 200 tokens while keeping essential project context
- Remove verbose explanations from CLAUDE.md -- Claude understands terse conventions
- Avoid reading entire large files when you only need specific sections
- Use file-specific instructions (e.g., "read lines 50-100 of auth.ts") instead of full file reads
- Monitor your session token counts before and after each `/compact` to measure effectiveness
- Set a personal rule: compact when context exceeds 100K tokens

## Measuring Impact

On subscription plans (Pro $20, Max $100-$200), cost savings from `/compact` don't directly reduce your bill -- they extend your rate limits, letting you do more within the same subscription. On API usage, savings are direct: the token reduction translates to proportional cost reduction. Track session duration (in interactions, not minutes) before and after adopting `/compact`. Teams typically find sessions last 30-50% more interactions after compaction, meaning more productive coding per session without hitting context limits.



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Why Is Claude Code Expensive Large Context Tokens](/why-is-claude-code-expensive-large-context-tokens/)
- [Claude Code Monthly Cost Breakdown Realistic Usage](/claude-code-monthly-cost-breakdown-realistic-usage-estimates/)
- [Is Claude Code Worth the Cost for Small Startups](/is-claude-code-worth-the-cost-for-small-startups-2026/)

## See Also

- [Smart Model Selection Saves 80% on Claude API](/smart-model-selection-saves-80-percent-claude/)
- [Lean Prompting: Fewer Tokens, Same Quality](/lean-prompting-fewer-tokens-same-quality/)
- [Why Claude Code Uses So Many Tokens Explained](/why-claude-code-uses-so-many-tokens-explained/)
- [How Tool Definitions Add 346 Tokens Per Call](/claude-tool-definitions-346-tokens-per-call/)
