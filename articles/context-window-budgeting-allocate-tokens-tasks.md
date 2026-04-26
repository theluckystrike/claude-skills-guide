---
layout: default
title: "Context Window Budgeting (2026)"
description: "Allocate Claude Code's 200K context window across discovery, implementation, and verification phases to prevent costly mid-session context overflows."
permalink: /context-window-budgeting-allocate-tokens-tasks/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Context Window Budgeting: How to Allocate Tokens Across Tasks

## What This Means for Claude Code Users

Claude Code's context window holds approximately 200,000 tokens. Exceeding this triggers automatic summarization or forces a session restart -- both of which waste tokens already spent. A structured budget allocates tokens across task phases (discovery, implementation, verification), preventing the common pattern where discovery consumes 80% of the window and leaves no room for actual work. Budgeting can reduce total session costs by 30-50% by eliminating restarts and redundant discovery.

## The Concept

Context window budgeting treats tokens like a financial budget: finite resources allocated across categories with hard limits. The analogy is precise because tokens *are* money. At Sonnet 4.6 rates ($3/$15 per MTok), a 200K-token session costs approximately $0.60 in input tokens alone, plus output costs.

The three phases of a typical Claude Code session have different token profiles:

- **Discovery** (understanding the codebase): Read calls, Grep searches, Glob patterns. High input token cost. Should target 20-30% of the budget.
- **Implementation** (making changes): Edit calls, Write operations, Bash commands. Moderate token cost. Should target 40-50% of the budget.
- **Verification** (testing and confirming): Test runs, build checks, linting. Variable cost. Should target 20-30% of the budget.

When discovery exceeds its budget, implementation and verification get squeezed. The result: incomplete changes, untested code, or a session restart that re-pays the discovery cost.

## How It Works in Practice

### Example 1: Bug Fix Session Budget (Target: 60K tokens total)

```yaml
# Session budget for a focused bug fix
# Total budget: 60,000 tokens (~$0.18 at Sonnet 4.6)

discovery:
  budget: 15,000 tokens (25%)
  activities:
    - Read the failing test: ~1,500 tokens
    - Read the implementation file: ~2,000 tokens
    - Read related types/interfaces: ~1,000 tokens
    - Grep for usage patterns: ~500 tokens
    - CLAUDE.md context: ~300 tokens
  total_estimate: 5,300 tokens
  remaining_buffer: 9,700 tokens

implementation:
  budget: 30,000 tokens (50%)
  activities:
    - Analyze root cause (model reasoning): ~5,000 tokens
    - Edit implementation file: ~1,500 tokens
    - Update related files if needed: ~3,000 tokens
  total_estimate: 9,500 tokens

verification:
  budget: 15,000 tokens (25%)
  activities:
    - Run failing test: ~2,000 tokens
    - Run full test suite: ~3,000 tokens
    - Lint check: ~1,000 tokens
  total_estimate: 6,000 tokens
```

Encode this budget as a CLAUDE.md rule:

```markdown
# CLAUDE.md -- Session Budgeting

## Bug Fix Protocol
1. Discovery (max 5 tool calls): Read failing test, implementation, types
2. Fix: Make minimal changes to resolve the specific issue
3. Verify: Run the failing test, then full suite, then lint
4. Do NOT explore unrelated code paths
5. If the fix requires understanding more than 3 files, report complexity and ask for guidance
```

The "max 5 tool calls" constraint bounds discovery at approximately 5,000 tokens (5 calls x ~1,000 tokens average), keeping the session well within budget.

### Example 2: Feature Implementation Budget (Target: 120K tokens)

```markdown
# .claude/skills/feature-budget.md

## Feature Implementation Protocol

### Phase 1: Discovery (Budget: 30K tokens, ~10 tool calls)
- Read the feature spec or ticket description
- Identify files that need modification (Glob + Grep, max 3 searches)
- Read up to 5 relevant files
- Run /compact after discovery to reclaim context

### Phase 2: Implementation (Budget: 60K tokens)
- Create or modify files as needed
- Follow existing patterns (check one example file, not five)
- Write tests alongside implementation

### Phase 3: Verification (Budget: 30K tokens)
- Run type checker: `npx tsc --noEmit`
- Run tests: `npx jest --bail`
- Run linter: `npx eslint src/ --quiet`
- If all pass, commit. If any fail, fix (max 3 retry cycles).
```

The "max 3 retry cycles" in verification prevents the expensive failure loop where Claude Code spends 50K+ tokens trying to fix cascading test failures. Three retries is a bounded retry contract.

### Example 3: Post-Discovery Compact

The most critical budget enforcement tool is `/compact` at phase transitions:

```bash
# Discovery phase complete -- 40K tokens used
# Claude has read 8 files, searched 4 patterns, understands the code

> /compact
# Context compressed to ~12K tokens
# Key findings retained: file locations, function signatures, patterns

# Implementation starts from 12K instead of 40K
# Each subsequent turn costs 28K fewer input tokens
# Over 10 implementation turns: 280K tokens saved ($0.84 on Sonnet 4.6)
```

Without the compact, a 20-turn session starting from 40K discovery context:
- Turns 11-20 average input: ~100K tokens each
- Total input for turns 11-20: ~1,000K tokens ($3.00)

With compact after discovery:
- Turns 11-20 average input: ~60K tokens each
- Total input for turns 11-20: ~600K tokens ($1.80)

**Savings: $1.20 per long session (40% reduction on second-half costs)**

## Token Cost Impact

| Budget Strategy | Without Budgeting | With Budgeting | Savings |
|----------------|-------------------|----------------|---------|
| Bug fix session | 80,000 tokens ($0.24) | 50,000 tokens ($0.15) | $0.09 (37%) |
| Feature implementation | 180,000 tokens ($0.54) | 110,000 tokens ($0.33) | $0.21 (39%) |
| Code review | 60,000 tokens ($0.18) | 30,000 tokens ($0.09) | $0.09 (50%) |
| Multi-file refactor | 200,000+ tokens ($0.60+) | 120,000 tokens ($0.36) | $0.24+ (40%+) |

Monthly impact for a developer averaging 5 sessions/day: $9-$25 savings at Sonnet 4.6 rates.

## Implementation Checklist

- [ ] Add session budget rules to CLAUDE.md with tool-call limits per phase
- [ ] Create phase-specific skills: discovery.md, implementation.md, verification.md
- [ ] Run `/compact` at every phase transition in sessions exceeding 50K tokens
- [ ] Set `--max-turns` for automated/CI sessions based on expected phase lengths
- [ ] Track actual token usage per session phase using `/cost` to calibrate budgets
- [ ] Establish team-wide budgets: bug fix (60K), feature (120K), refactor (150K)
- [ ] Review and adjust budgets monthly based on `ccusage` data

### Example 4: Multi-File Refactoring Budget (Target: 150K tokens)

Multi-file refactoring is the most expensive common task. Without budgeting, it routinely exceeds 200K tokens:

```markdown
# .claude/skills/refactoring-budget.md

## Refactoring Protocol (Budget: 150K tokens)

### Phase 1: Map (Budget: 25K tokens, max 8 tool calls)
- Identify all files to change (Glob + Grep)
- Read ONE example file to understand the pattern
- Document: list of files, pattern to change, expected count

### Phase 2: Transform (Budget: 80K tokens)
- Edit files in order, one at a time
- After every 5 edits, run /compact to free context
- If more than 20 files need changes, use subagents (1 per 5 files)

### Phase 3: Validate (Budget: 45K tokens)
- Run type checker: `npx tsc --noEmit`
- Run tests: `npx jest --bail`
- Run linter: `npx eslint src/ --quiet`
- If more than 3 files fail validation, stop and report

### Budget Guard Rails
- Max 3 /compact cycles per session
- If any phase exceeds budget by 50%, stop and reassess
- Never edit more than 30 files in a single session
```

This budget prevents the common failure mode where a refactoring session hits 200K tokens at file 15 of 25, forcing a session restart that re-pays the discovery cost.

**Savings: 50K-100K tokens per refactoring session (avoiding restarts)**

## The CCG Framework Connection

Context window budgeting is the planning layer that makes all other context engineering techniques effective. Without budgets, developers apply /compact randomly, scope prompts inconsistently, and let sessions drift past 200K tokens. With budgets, each technique (scoped prompts for discovery, /compact at transitions, --max-turns for verification) has a clear trigger and purpose. The NASA Power of 10 principle of bounded loops applies directly: budget phases with token limits to prevent unbounded exploration.

### Team Budget Standards

Establish team-wide budget norms so developers have shared expectations:

```markdown
# Team Token Budget Standards

## Session Budgets (Sonnet 4.6)
| Task Type | Max Budget | Max Turns | Expected Cost |
|-----------|-----------|-----------|--------------|
| Quick fix | 40K tokens | 8 | $0.12-$0.24 |
| Bug fix | 80K tokens | 15 | $0.24-$0.48 |
| Feature | 120K tokens | 20 | $0.36-$0.72 |
| Refactor | 150K tokens | 25 | $0.45-$0.90 |
| Code review | 40K tokens | 10 | $0.12-$0.24 |

## Weekly Budget Per Developer
- Target: $15-$25/week ($60-$100/month)
- Alert threshold: $40/week
- Escalation: any single session over $2.00

## Budget Compliance
- Check /cost at end of each session
- Review ccusage weekly
- Share optimization tips in team standup if budget exceeded
```

These standards create accountability without micromanagement. Developers who consistently stay within budget are using context engineering effectively. Those who exceed budget get targeted optimization help.

### Adjusting Budgets Over Time

Review and adjust budgets monthly based on actual usage data:

```bash
# Monthly budget review process:
ccusage --sort cost --limit 50

# Calculate average cost per task type from the last 30 days
# If 90% of bug fixes complete under 60K tokens, lower the bug fix budget from 80K to 65K
# If features consistently need 140K tokens, raise the feature budget from 120K to 145K
# If any task type shows >20% variance, investigate root causes

# The goal is budgets that match reality within 15%
# Too tight: developers hit limits and restart sessions (waste)
# Too loose: no cost discipline (waste)
```

Well-calibrated budgets save 10-20% versus initial estimates because they eliminate both budget overruns (excess tokens) and premature restarts (repeated discovery costs).

## Further Reading

- [Claude Code Context Window Management](/claude-code-context-window-management-2026/) -- the full context management toolkit
- [Claude Code Compact Command Guide](/claude-code-conversation-too-long-fresh-vs-compact/) -- the primary tool for staying within budget
- [Cost Optimization Hub](/cost-optimization/) -- all cost reduction techniques in one place

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).
