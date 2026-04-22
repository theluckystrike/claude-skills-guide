---
title: "Context Engineering for Multi-Agent Orchestration"
description: "Engineer context across Claude Code multi-agent workflows to prevent the 5,000-token spawn overhead from compounding into 50K+ tokens of waste per task."
permalink: /context-engineering-multi-agent-orchestration/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Context Engineering for Multi-Agent Orchestration

## What This Means for Claude Code Users

Multi-agent workflows -- where a parent Claude Code agent spawns subagents for parallel work -- multiply context engineering mistakes. Each subagent carries approximately 5,000 tokens of base overhead. Poor context handoff between agents causes redundant file reads. Uncompressed result passing inflates the parent's context. A 5-subagent workflow with no context engineering easily consumes 150K-250K tokens. The same workflow with proper context engineering: 60K-90K tokens. At Opus 4.6 rates, that is the difference between $11-$19 and $4.50-$6.75 per orchestrated task.

## The Concept

Multi-agent orchestration in Claude Code uses the Task tool to spawn subagents that execute work in parallel. The parent agent plans, delegates, and synthesizes results. Context engineering for this pattern must address three unique challenges:

1. **Context duplication** -- each subagent starts fresh, potentially re-reading files the parent already read
2. **Handoff overhead** -- task descriptions and context summaries consume tokens in both parent and child
3. **Result aggregation** -- subagent results flow back to the parent, expanding its context window

The goal is to minimize total tokens across all agents while maintaining task quality. This requires treating the multi-agent system as a context budget to be allocated, not a collection of independent sessions.

## How It Works in Practice

### Example 1: Context-Lean Task Delegation

The most common mistake in multi-agent workflows is passing vague task descriptions that force subagents into discovery mode.

```yaml
# Anti-pattern: Vague delegation (subagent spends 15K tokens discovering context)
Task: "Review the auth module for security issues"

# Result: Subagent reads 8 files, runs grep searches, builds its own understanding
# Token cost: 5,000 (base) + 15,000 (discovery) = 20,000 tokens

# Optimized: Pre-digested context delegation
Task: "Review these 3 files for JWT token handling security issues:
  1. src/auth/middleware.ts (lines 30-80) -- JWT verification logic
  2. src/auth/token.ts (lines 1-45) -- token generation
  3. src/auth/refresh.ts (lines 20-60) -- refresh token rotation

  Known context: Using jsonwebtoken v9.0.2, tokens expire in 15 minutes,
  refresh tokens in 7 days. Check for: timing attacks, weak algorithms,
  missing expiration validation.

  Return format: { file, line, severity, issue, fix }"

# Result: Subagent reads 3 targeted sections, performs focused analysis
# Token cost: 5,000 (base) + 4,000 (targeted work) = 9,000 tokens
# Savings: 11,000 tokens (55%)
```

### Example 2: Result Compression Protocol

When subagents return results, unstructured verbose output pollutes the parent's context. Define a compression protocol in CLAUDE.md.

```yaml
# CLAUDE.md -- multi-agent result protocol
## Subagent Result Format
All subagent results must follow this schema:

status: PASS | FAIL | PARTIAL
files_modified: [list of paths]
summary: [1-2 sentences, max 50 words]
issues: [{ file, line, description }] or NONE
next_steps: [list] or NONE

Do not include: file contents, full diffs, reasoning chains, or alternative approaches.
Maximum result size: 300 tokens.
```

```text
# Uncompressed subagent result: ~2,000 tokens
"I reviewed the auth middleware and found several issues. The JWT verification
in middleware.ts uses the HS256 algorithm which is fine but the token expiration
check on line 47 compares token.exp directly with Date.now() without converting
from seconds to milliseconds. I also noticed that the refresh token endpoint
doesn't validate the token's audience claim. Here's what I changed..."
[continues for 1,500 more tokens]

# Compressed subagent result: ~150 tokens
status: FAIL
files_modified: []
summary: Two security issues found in JWT handling.
issues:
  - { file: "src/auth/middleware.ts", line: 47, description: "exp compared in seconds vs milliseconds" }
  - { file: "src/auth/refresh.ts", line: 35, description: "missing audience claim validation" }
next_steps: ["Fix time unit mismatch", "Add aud claim check"]
```

With 5 subagents, the compressed protocol saves approximately 9,250 tokens in the parent's context (5 * 1,850 tokens saved). Those tokens compound as the parent processes results over subsequent turns.

### Example 3: Shared Context Cache via CLAUDE.md

Instead of each subagent independently discovering project conventions, create a shared context file that all subagents read.

```yaml
# .claude/shared-context.md -- loaded by all subagents (~400 tokens)
## Shared Context for Subagents
- TypeScript strict mode, no `any` types
- Prisma for database access (never raw SQL)
- Error handling: return Result<T> types, never throw
- Test with Vitest: `pnpm test <file>`
- Import convention: `@/` prefix maps to src/

## Code Style
- Functions under 60 lines
- Max 2 parameters (use options object for more)
- All async functions must have error handling
```

```yaml
# CLAUDE.md -- subagent context rule
## Multi-Agent Rules
- All subagents must receive the path to .claude/shared-context.md
- Subagent task descriptions must include: specific file paths, line ranges, and success criteria
- Maximum subagent result size: 300 tokens
- Maximum concurrent subagents: 3 (to bound total token spend)
```

This shared context file costs 400 tokens per subagent (loaded once) but saves each subagent 2,000-5,000 tokens of discovery. With 3 subagents: 1,200 tokens spent vs 6,000-15,000 tokens saved. **Net savings: 4,800-13,800 tokens per orchestrated task.**

## Token Cost Impact

Multi-agent context engineering targets all three cost multipliers simultaneously: spawn overhead, discovery duplication, and result aggregation.

```text
5-subagent workflow, unoptimized:
  Base overhead: 5 * 5,000 = 25,000 tokens
  Discovery per subagent: 5 * 12,000 = 60,000 tokens
  Results to parent: 5 * 2,000 = 10,000 tokens
  Parent processing: 30,000 tokens
  Total: 125,000 tokens = $9.38 at Opus

5-subagent workflow, context-engineered:
  Base overhead: 5 * 5,000 = 25,000 tokens (unavoidable)
  Scoped work per subagent: 5 * 5,000 = 25,000 tokens
  Compressed results: 5 * 150 = 750 tokens
  Parent processing: 15,000 tokens
  Total: 65,750 tokens = $4.93 at Opus

  Savings: 59,250 tokens (47%) = $4.45 per orchestrated task
```

## Implementation Checklist

- [ ] Create a .claude/shared-context.md with conventions shared across all subagents
- [ ] Define a result compression schema in CLAUDE.md (max 300 tokens per subagent result)
- [ ] Add pre-digested context to all subagent task descriptions (file paths, line ranges, known facts)
- [ ] Cap concurrent subagents at 3 in CLAUDE.md rules
- [ ] Measure total tokens per orchestrated task using `/cost` and flag any exceeding 100K tokens
- [ ] Establish a minimum task size for subagent delegation (20K+ tokens to justify the 5K overhead)

## The CCG Framework Connection

Multi-agent orchestration is where context engineering failures are most expensive because they multiply across agents. The CCG framework treats multi-agent context as a budget allocation problem: the parent agent is the "budget controller" that determines what context each subagent receives and how much result space each subagent is allowed. Teams that implement this framework report 40-60% cost reductions on multi-agent workflows.

## Further Reading

- [Claude Code Subagent Token Usage: How to Control Costs](/claude-code-subagent-token-usage-control-costs/) -- subagent-specific cost controls
- [Claude Code Subagent Management](/claude-code-subagent-management/) -- full subagent orchestration guide
- [Context Engineering for Claude Code: Complete Guide](/context-engineering-claude-code-complete-guide-2026/) -- the complete context engineering framework
