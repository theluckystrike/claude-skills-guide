---
layout: default
title: "Claude Skills Performance Optimization (2026)"
description: "Reduce skill token usage by 60% with progressive disclosure, front-loaded descriptions, compaction-aware design, and reference file offloading."
permalink: /claude-skills-performance-optimization/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, performance, token-optimization]
last_updated: 2026-04-19
---

## The Specific Situation

Your project has 10 skills. Claude's responses are getting slower, context compaction happens frequently, and older skill instructions are being forgotten mid-session. You check your skills: three are over 400 lines, five have descriptions over 1,000 characters, and two contain inline reference tables that could be separate files. Total description budget is consumed, and the 25,000-token compaction budget cannot hold all 10 skills simultaneously.

## Technical Foundation

Claude Code's skill system has three cost layers. First, **description cost**: the combined text of all auto-invocable skill descriptions (name + description + when_to_use) is truncated at 1,536 characters per skill and scaled to 1% of the context window (fallback: 8,000 characters total). This cost is always paid, every turn. Second, **invocation cost**: when a skill is invoked, the full SKILL.md body enters the conversation as a message. Third, **compaction cost**: after compaction, invoked skills are re-attached with a 5,000-token limit per skill and a 25,000-token combined budget, filled from most recently invoked first.

The official size recommendation is under 500 lines per SKILL.md. The plugin development guide targets 1,500-2,000 words for the body. Detailed reference material belongs in `references/` files (2,000-5,000+ words each), read on demand.

## The Working SKILL.md

Optimized skill structure at `.claude/skills/optimized-example/SKILL.md`:

```yaml
---
name: optimized-example
description: >
  [Front-load the trigger phrases in the first 100 chars]
  Generate API tests from OpenAPI specs. Use when creating
  integration tests, contract tests, or smoke tests for
  REST endpoints.
paths:
  - "src/api/**/*.ts"
  - "tests/api/**/*.ts"
allowed-tools: Read Bash(node *)
---

# API Test Generator

## Quick Reference (survives compaction — keep under 5,000 tokens)
- Test framework: vitest + supertest
- Auth: Bearer token from env.TEST_AUTH_TOKEN
- Base URL: env.API_BASE_URL
- Timeout: 30s for integration, 5s for unit

## Core Workflow
1. Read OpenAPI spec from `docs/openapi.yaml`
2. For each endpoint, generate: success case, auth failure, validation error
3. Write tests to `tests/api/{resource}.test.ts`
4. Run `pnpm test:api` to validate

## Detailed Reference (read on demand — not loaded until needed)
For full OpenAPI parsing rules, see `references/openapi-parsing.md`.
For authentication test patterns, see `references/auth-patterns.md`.
For database fixture setup, see `references/db-fixtures.md`.
```

Optimization strategies in a reference skill at `.claude/skills/token-guide/SKILL.md`:

```yaml
---
name: token-guide
description: >
  Skill token optimization reference. Consult when designing new
  skills or diagnosing context budget issues. Covers description
  budgets, compaction survival, and progressive disclosure.
user-invocable: false
---

# Token Optimization Strategies

## Strategy 1: Front-Load Descriptions
The description field is truncated at 1,536 chars (combined with when_to_use).
Put the most important trigger phrases in the first 100 characters.
BAD: "This skill provides a set of tools for..."
GOOD: "Generate API tests from OpenAPI specs."

## Strategy 2: Progressive Disclosure (3 Levels)
Level 1 — Metadata (always loaded): description only. Cost: ~100-200 tokens.
Level 2 — SKILL.md body (on invocation): core instructions. Target: 1,500-2,000 words.
Level 3 — References (on demand): detailed docs. Size: 2,000-5,000+ words each.

Move anything Claude does not need on every invocation to Level 3.

## Strategy 3: Compaction-Aware Ordering
After compaction, each skill gets up to 5,000 tokens, newest first.
Place the most critical instructions in the first 5,000 tokens of SKILL.md.
Detailed examples, edge cases, and reference tables can go after — they
will be available on fresh invocation but may be trimmed after compaction.

## Strategy 4: Invocation Control
- disable-model-invocation: true — removes description from context entirely.
  Use for manual-only skills (deploy, publish, release).
- user-invocable: false — description stays in context but hidden from / menu.
  Use for background reference skills Claude should auto-discover.

## Strategy 5: Context Fork for Heavy Skills
Skills over 5,000 tokens should use context: fork.
The forked subagent gets its own context, returns a summary.
Main context only pays for the summary (~500-1,000 tokens).

## Budget Calculations
- 10 auto-invocable skills x 1,000 char descriptions = ~2,500 tokens always in context
- 3 invoked skills x 4,000 tokens each = 12,000 tokens active
- After compaction: 3 x 5,000 = 15,000 tokens max (within 25,000 budget)
- Add 4th skill: oldest may be dropped if total exceeds 25,000
```

## Common Problems and Fixes

**All skill descriptions exceed the total budget.** With 15 skills and a total description budget of ~8,000 characters, each skill gets roughly 533 characters. Set `disable-model-invocation: true` on any skill that users invoke manually (deploy, release, maintenance tasks) to remove its description from the budget entirely.

**Skill content forgotten after compaction.** Only the first 5,000 tokens of each skill survive compaction. If your critical instructions are at the bottom of a 10,000-token SKILL.md, they get trimmed. Restructure: put the "Quick Reference" section (essential rules, commands, constraints) at the top, detailed examples at the bottom.

**Slow skill loading.** Dynamic context injection (`!`command``) runs shell commands before the skill loads. If the command is slow (API call, large file parse), it blocks skill loading. Keep `!`command`` output small -- pipe through `head`, `jq`, or `wc` rather than injecting full file contents.

**Reference files read multiple times.** Each time Claude encounters a "see references/X.md" instruction, it reads the file. The content does not persist between turns unless Claude is explicitly working with it. For frequently needed reference data, include a compact summary in the main SKILL.md and reference the full file only for edge cases.

## Production Gotchas

The `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable can raise the default description budget. Set it in your shell profile if the default budget is too restrictive for your skill count. But increasing the budget trades context space for skill discovery -- more description tokens means fewer tokens for the actual conversation.

The "ultrathink" keyword anywhere in skill content enables extended thinking for that skill's execution. This is powerful for complex analysis skills but adds latency. Use it selectively, not as a default in every skill.

## Checklist

- [ ] No SKILL.md exceeds 500 lines (move excess to `references/`)
- [ ] Critical instructions in the first 5,000 tokens of each skill
- [ ] Manual-only skills set `disable-model-invocation: true`
- [ ] Dynamic context injection commands complete in under 2 seconds
- [ ] Total description budget verified with current skill count

## Related Guides

- [Claude Skills vs Subagents: When to Use Each](/claude-skills-vs-subagents-when-to-use/) -- when to fork for context isolation
- [Claude Skill Composition Patterns](/claude-skill-composition-patterns/) -- managing multi-skill token budgets
- [Claude Skills Data Flow Patterns](/claude-skills-data-flow-patterns/) -- efficient data movement between skills

## Related Articles

- [Claude Code Skill Output Streaming Optimization](/claude-code-skill-output-streaming-optimization/)
