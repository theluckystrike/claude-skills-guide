---
layout: default
title: "Scoping Skills Narrowly (2026)"
description: "A single broad Claude Code skill wastes 500-2,000 tokens per invocation loading irrelevant instructions -- narrow skills cut overhead by 60-80%."
permalink: /scoping-skills-narrowly-broad-skill-wastes-tokens/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Scoping Skills Narrowly: Why One Broad Skill Wastes Tokens

## What It Does

Claude Code skills load their full content into the context window when invoked. A broad skill covering multiple tasks loads 800-2,000 tokens of instructions, most of which are irrelevant to the current task. Narrow, single-purpose skills load 150-400 tokens of precisely relevant instructions. The difference compounds across a session: 10 skill invocations with a broad skill waste 4,000-16,000 tokens. The same work with narrow skills wastes near zero.

## Installation / Setup

```bash
# Instead of one broad skill:
# .claude/skills/development.md (800-2,000 tokens -- covers everything)

# Create narrow, focused skills:
mkdir -p .claude/skills

# Each skill: one task, one set of instructions, under 400 tokens
```

## Configuration for Cost Optimization

The cost optimization is in the skill design itself. Compare a broad skill versus its narrow replacements:

```yaml
# ANTI-PATTERN: Broad skill (~1,200 tokens)
# .claude/skills/development.md
# Development Skill
When doing development work:
## Code Style
- Use TypeScript strict mode
- Functions under 60 lines
- Use Result types for errors
## Testing
- Write tests with Vitest
- Minimum 80% coverage
- Use test factories for data
## Git
- Conventional commits
- Squash before merge
- No force push to main
## Code Review
- Check type safety
- Verify error handling
- Maximum 10 findings
## Deployment
- Build with pnpm build
- Deploy to staging first
- Run smoke tests after deploy
```

```yaml
# CORRECT: Narrow skills (~200 tokens each, loaded only when relevant)

# .claude/skills/test.md
# Test Skill
When writing tests:
1. Use Vitest with describe/it blocks
2. Use factory functions in tests/factories/ for test data
3. Assert both success and error paths
4. Run: `pnpm test <file> 2>&1 | head -30`

# .claude/skills/commit.md
# Commit Skill
When committing:
1. Stage specific files (not git add .)
2. Conventional commit format: type(scope): description
3. Keep under 72 characters
4. Do not push unless asked

# .claude/skills/review.md
# Review Skill
When reviewing:
1. Read only changed files via git diff
2. Check: types, errors, tests, naming
3. Format: file:line -- issue -- severity
4. Maximum 10 findings, severity-ordered
```

## Usage Examples

### Basic Usage

```bash
# Narrow skill invocation -- loads only ~200 tokens of relevant context
claude /commit
# Loads: commit.md (200 tokens)
# Does NOT load: test, review, deployment instructions

claude /review
# Loads: review.md (200 tokens)
# Does NOT load: commit, test, deployment instructions
```

### Advanced: Cost-Saving Pattern

When a task spans multiple concerns, invoke skills sequentially rather than loading everything at once:

```bash
# Phase 1: Implementation (no skill needed or use a specific feature skill)
claude "Add the rate limiter to /api/upload"

# Phase 2: Testing (load test skill only)
claude /test
# "Write tests for the rate limiter in src/middleware/rate-limit.ts"

# Phase 3: Commit (load commit skill only, test skill already compacted)
/compact
claude /commit
# "Commit the rate limiter and its tests"
```

Each phase loads only the relevant 200-token skill instead of a 1,200-token omnibus skill. Over 3 phases: 600 tokens loaded versus 3,600 tokens (if the broad skill were loaded in each phase). **Savings: 3,000 tokens per 3-phase workflow.**

## Token Usage Measurements

| Skill Approach | Tokens Loaded per Invocation | Relevant Tokens | Wasted Tokens |
|---------------|-----------------------------|--------------------|---------------|
| One broad skill | 1,200 | 200-400 | 800-1,000 |
| Narrow skills | 150-400 | 150-400 | 0-50 |
| No skill | 0 | 0 | 0 (but 2,000-5,000 in discovery) |

```text
Monthly impact (10 skill invocations/day, 20 workdays):

Broad skill: 200 invocations * 1,000 wasted tokens = 200,000 wasted tokens
  Cost at Opus: $3.00/month in pure waste

Narrow skills: 200 invocations * 25 wasted tokens = 5,000 wasted tokens
  Cost at Opus: $0.08/month in waste

Monthly savings: $2.92 from skill scoping alone
```

While $2.92 seems small in isolation, it combines with other optimizations and the wasted tokens also occupy context window space that could be used for productive work.

## Comparison with Alternatives

| Approach | Token Cost | Precision | Maintenance |
|----------|-----------|-----------|-------------|
| One broad skill | High (1,200/load) | Low (lots of irrelevant content) | Easy (one file) |
| Narrow skills | Low (200/load) | High (all content relevant) | Medium (multiple files) |
| CLAUDE.md rules only | Medium (always loaded) | Low (loaded every session) | Easy (one file) |

## Troubleshooting

**Too many narrow skills to manage** -- Group related skills by directory: `.claude/skills/git/commit.md`, `.claude/skills/git/review.md`. Keep each file focused on a single task.

**Skill overlap causing confusion** -- If two narrow skills give conflicting instructions, the later-loaded skill takes precedence. Avoid overlap by ensuring each skill addresses a distinct task with no shared rules.



**Estimate usage →** Calculate your token consumption with our [Token Estimator](/token-estimator/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Best Claude Code Skills for Token Reduction](/best-claude-code-skills-token-reduction-2026-ranked/) -- which skills save the most tokens
- [Claude Code Skills Guide](/skills/) -- complete skills authoring reference
- [CLAUDE.md as Cost Control](/claude-md-cost-control-rules-prevent-token-waste/) -- choosing between CLAUDE.md rules and skills
