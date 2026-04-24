---
title: "Claude Code Cost Optimization"
description: "Cut Claude Code costs by 40-70% with 15 proven optimization techniques covering context management, model selection, and token-efficient workflows."
permalink: /claude-code-cost-optimization-15-techniques/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code Cost Optimization: 15 Techniques That Actually Work

## The Problem

Claude Code API costs can escalate from $5/day to $50/day when projects grow beyond a few dozen files. The root cause is almost always unnecessary token consumption -- reading files that are not relevant, spawning subagents without budgets, and letting context windows fill up with stale information. A typical developer running Opus 4.6 at $15/$75 per MTok (input/output) can burn through $300/month without realizing where the tokens go.

## Quick Wins (Under 5 Minutes)

1. **Run `/compact` after every major task** -- reclaims 60-80% of context window, saving 100K-400K tokens per session.
2. **Switch to Sonnet 4.6 for routine tasks** -- at $3/$15 per MTok, Sonnet costs 80% less than Opus for input tokens.
3. **Add a `.claudeignore` file** -- exclude `node_modules/`, `dist/`, `.git/`, and vendored files from context scanning.
4. **Set `CLAUDE_CODE_MAX_TURNS=25`** -- prevents runaway loops that can consume 500K+ tokens in a single session.
5. **Use specific file paths in prompts** -- "fix the bug in src/auth/login.ts" costs ~2K tokens to locate vs. ~50K tokens when Claude searches the entire codebase.

## Deep Optimization Strategies

### Strategy 1: Model Routing by Task Complexity

Not every task requires Opus 4.6. Routing tasks to the appropriate model saves 60-80% on routine work.

```bash
# Set default model to Sonnet for everyday tasks
export CLAUDE_MODEL="claude-sonnet-4-6"

# Switch to Opus only for architecture decisions
claude --model claude-opus-4-6 "Design the authentication module for our microservice"
```

**Expected savings:** A team spending $1,500/month on all-Opus usage can drop to $450/month by routing 70% of tasks to Sonnet. That is $1,050/month saved.

| Task Type | Recommended Model | Input Cost/MTok | Output Cost/MTok |
|-----------|------------------|-----------------|------------------|
| Code generation | Sonnet 4.6 | $3.00 | $15.00 |
| Bug fixes | Sonnet 4.6 | $3.00 | $15.00 |
| Architecture design | Opus 4.6 | $15.00 | $75.00 |
| Refactoring | Sonnet 4.6 | $3.00 | $15.00 |
| Complex debugging | Opus 4.6 | $15.00 | $75.00 |

### Strategy 2: Context Window Hygiene with /compact

Every token in the context window is re-read on every turn. A 200K-token context means 200K input tokens billed per message.

```bash
# Check current context usage
/cost

# Compact when context exceeds 50% capacity
/compact

# Verify savings
/cost
```

Running `/compact` after accumulating 150K tokens typically reduces context to 30K-60K tokens. Over a 20-turn session, that saves approximately 1.8M input tokens -- worth $5.40 on Sonnet or $27 on Opus.

### Strategy 3: Surgical File Reading with CLAUDE.md Directives

Pre-loading architecture knowledge in CLAUDE.md eliminates exploratory file reads.

```markdown
# CLAUDE.md

## Project Structure
- API routes: src/api/ (Express.js, 12 route files)
- Database: src/db/ (Prisma ORM, schema in prisma/schema.prisma)
- Auth: src/auth/ (JWT-based, middleware in src/auth/middleware.ts)
- Tests: __tests__/ (Jest, mirrors src/ structure)

## Key Files
- Entry point: src/index.ts
- Config: src/config.ts (all env vars documented inline)
- Types: src/types/ (shared TypeScript interfaces)
```

**Before:** Claude reads 15-20 files to understand project structure (~75K tokens).
**After:** Claude reads CLAUDE.md (~500 tokens) and goes directly to the relevant file (~3K tokens).
**Savings:** ~71K tokens per task, or $1.07/task on Opus input.

### Strategy 4: Subagent Budget Controls

Subagents spawn with ~5,000 tokens of overhead each. Without controls, Claude can spawn 10+ subagents for a single task.

```markdown
# CLAUDE.md

## Agent Rules
- Maximum 3 subagents per task
- Each subagent must target a single file or function
- Never spawn a subagent to read a file -- use the Read tool directly
- Subagent tasks must be scoped to complete within 10 tool calls
```

**Expected savings:** Capping subagents from 10 to 3 saves ~35K tokens in spawn overhead alone, plus 100K-300K tokens in redundant work. Monthly impact for a heavy user: $50-$150.

### Strategy 5: Batch Operations Instead of Iterative Edits

Each tool call (Read, Edit, Bash) adds overhead tokens. A Bash call costs ~245 tokens in overhead. Batching reduces round-trips.

```markdown
# Instead of editing one file at a time, batch the instruction:
"Update all API route files in src/api/ to use the new auth middleware.
Files: users.ts, posts.ts, comments.ts, auth.ts.
Apply the same pattern: import authMiddleware from '../auth/middleware'
and add it as the second argument to each router.get/post/put/delete call."
```

**Before:** 12 individual Edit calls = 12 x 245 = 2,940 tokens in tool overhead, plus context growth per turn.
**After:** 1 comprehensive instruction = ~500 tokens, Claude batches the edits in ~4 tool calls = 980 tokens overhead.
**Savings:** ~60% reduction in tool overhead tokens.

### Strategy 6: .claudeignore for Large Repositories

```bash
# .claudeignore
node_modules/
dist/
build/
.git/
*.min.js
*.map
vendor/
coverage/
__snapshots__/
*.lock
```

In a typical Node.js project, `node_modules/` alone contains 50K+ files. Even indexing the file tree costs thousands of tokens. A well-configured `.claudeignore` reduces the searchable file tree by 80-95%.

### Strategy 7: Session Segmentation

Long sessions accumulate context. Breaking work into focused sessions keeps context lean.

```bash
# Session 1: Bug fix (target: 30K tokens)
claude "Fix the null pointer in src/auth/login.ts line 47"

# Session 2: Feature work (target: 80K tokens)
claude "Add rate limiting middleware to all API routes"

# Session 3: Tests (target: 50K tokens)
claude "Write unit tests for the rate limiting middleware"
```

**Expected savings:** Three 50K-token sessions cost 150K tokens total. One continuous session doing the same work typically costs 300K-500K tokens due to context accumulation. Savings: 50-70%.

### Strategy 8: Pre-computed Context in Skills

Skills load domain knowledge without consuming exploration tokens.

```markdown
# .claude/skills/database-schema.md

## Database Schema (as of 2026-04-22)
### Users table
- id: uuid (PK)
- email: varchar(255) UNIQUE
- created_at: timestamp

### Posts table
- id: uuid (PK)
- user_id: uuid (FK -> users.id)
- title: varchar(500)
- body: text
- published: boolean DEFAULT false
```

Loading a skill costs ~200-1,000 tokens. Having Claude query the database schema directly costs 5,000-15,000 tokens (Bash call + SQL execution + result parsing). For a team running 20 schema-related tasks per day, skills save 80K-280K tokens daily -- $0.24-$0.84/day on Sonnet.

### Strategy 9: Structured Error Returns in Scripts

When Claude runs a script that fails, unstructured error output wastes tokens on parsing.

```bash
#!/bin/bash
# deploy.sh -- structured error output for Claude Code
set -euo pipefail

if ! npm run build 2>/tmp/build-error.log; then
    echo "BUILD_FAILED"
    echo "FILE: $(grep -m1 'Error in' /tmp/build-error.log | head -c 200)"
    echo "LINE: $(grep -m1 'Line [0-9]' /tmp/build-error.log | head -c 100)"
    exit 1
fi
echo "BUILD_SUCCESS"
```

**Before:** Raw build error output = 2,000-10,000 tokens.
**After:** Structured 3-line output = ~50 tokens.
**Savings:** 97-99% reduction in error-related token consumption.

### Strategy 10: Environment Variable Cost Controls

```bash
# Set in .bashrc or .zshrc
export CLAUDE_CODE_MAX_TURNS=25          # Prevent runaway sessions
export CLAUDE_CODE_BUDGET_TOKENS=500000  # Hard token cap per session
export CLAUDE_MODEL="claude-sonnet-4-6"  # Default to cheaper model
```

These guardrails prevent the worst-case scenarios. A single runaway session on Opus can consume 2M+ tokens ($30+ in input alone). The `MAX_TURNS` setting alone prevents 90% of token spiral incidents.

### Strategy 11: Smart Prompt Structuring

Vague prompts cause exploratory behavior. Specific prompts save tokens.

```markdown
# Bad (costs ~150K tokens -- triggers exploration)
"Fix the tests"

# Good (costs ~30K tokens -- goes directly to target)
"Fix the failing test in __tests__/auth/login.test.ts.
The test 'should reject expired tokens' fails because
the mock doesn't set the exp field. Add exp: Date.now()/1000 - 3600
to the mock token payload on line 23."
```

### Strategy 12: Hook-Based Automation

Use Claude Code hooks to automate repetitive checks without consuming agent tokens.

```json
{
  "hooks": {
    "pre-commit": {
      "command": "npm run lint -- --quiet",
      "timeout": 30000
    }
  }
}
```

Running lint as a hook costs 0 agent tokens. Having Claude run lint, read the output, and fix issues costs 5K-20K tokens per cycle. Over 10 commits per day, hooks save 50K-200K tokens daily.

### Strategy 13: Targeted grep Over Full Reads

```bash
# Expensive: reading entire files
# Read tool call on a 500-line file = ~4,000 tokens

# Cheap: targeted search
# Grep for specific pattern = ~500 tokens for matching lines only
```

Instruct Claude to use Grep before Read in CLAUDE.md:

```markdown
# CLAUDE.md
## Search Strategy
- Always grep for the relevant function/class before reading a full file
- Only read full files when understanding the complete module is necessary
```

### Strategy 14: Caching Build Artifacts Locally

```bash
# Instead of rebuilding every time Claude makes a change:
npm run build -- --incremental

# Or use turbo for monorepos:
npx turbo build --cache-dir=.turbo
```

Full builds generate verbose output that fills the context window. Incremental builds produce minimal output, saving 2K-10K tokens per build cycle.

### Strategy 15: Token-Aware Session Planning

Start each session by stating the budget:

```markdown
"I have a budget of 100K tokens for this session.
Prioritize: 1) fix the auth bug, 2) add the test, 3) update docs.
Stop after priority 1 if context is above 60K tokens."
```

This explicit budgeting prevents scope creep, the leading cause of cost overruns in Claude Code sessions.

## Measuring Your Savings

Track token usage with the built-in `/cost` command:

```bash
# During a session
/cost
# Output: Session tokens: 45,231 input / 12,847 output
# Estimated cost: $0.33 (Sonnet 4.6)

# Historical tracking with ccusage
ccusage --period month --model all
```

Compare week-over-week to verify optimizations are working. A well-optimized workflow should show 40-70% reduction in per-task token usage within the first week.

## Cost Impact Summary

| Technique | Token Savings | Monthly Savings (Sonnet) | Monthly Savings (Opus) |
|-----------|--------------|--------------------------|------------------------|
| Model routing | 60-80% on routed tasks | $150-300 | $750-1,050 |
| /compact usage | 50-70% per session | $50-100 | $250-500 |
| CLAUDE.md structure | 70K/task | $30-60 | $150-300 |
| Subagent controls | 135K-335K/task | $20-50 | $100-250 |
| Batch operations | 60% tool overhead | $10-20 | $50-100 |
| .claudeignore | 80-95% scan reduction | $20-40 | $100-200 |
| Session segmentation | 50-70% per workflow | $40-80 | $200-400 |
| **Combined** | **40-70% overall** | **$200-500** | **$1,000-2,500** |

## Advanced: Combining Techniques for Maximum Impact

The 15 techniques above are most powerful when combined. Here is a production-ready CLAUDE.md that implements the top 8 techniques simultaneously:

```markdown
# CLAUDE.md -- Production Cost Optimization

## Project: my-app (TypeScript, Express, Prisma, Jest)

## Directory Map
- src/routes/ -- REST endpoints (15 files)
- src/services/ -- business logic (10 files)
- src/repositories/ -- DB queries (8 files)
- __tests__/ -- Jest tests (mirrors src/)

## Commands
- Build: ./scripts/build-structured.sh (NOT npm run build)
- Test: npm test -- --testPathPattern="<file>" (targeted, never full suite during fixes)
- Lint: npm run lint --fix

## Cost Rules (MANDATORY)
- Model default: Sonnet 4.6 (Opus only for architecture tasks)
- Max 5 files read before proposing a solution
- Max 3 subagents per task, no nested subagents
- Max 3 fix attempts per error, then report
- Run /compact when context > 100K tokens
- Use Grep before Read (search first, then read targeted files)
- One task per session -- start fresh for unrelated work

## Skills
- .claude/skills/database.md -- schema + query patterns
- .claude/skills/api-routes.md -- endpoint reference
- .claude/skills/deploy.md -- deployment process
```

This single CLAUDE.md file (~250 tokens) encodes techniques 1, 2, 3, 4, 5, 7, 11, and 13. It costs approximately 7,500 tokens per 30-turn session to carry in context but prevents an estimated 200K-500K tokens of waste per session.

## Technique Priority Guide

Not all techniques deliver equal returns. Prioritize implementation in this order for maximum early impact:

| Priority | Technique | Implementation Time | Expected Monthly Savings |
|----------|-----------|-------------------|--------------------------|
| 1 | Model routing (#1) | 2 minutes | $150-1,050 |
| 2 | /compact usage (#2) | 0 minutes (habit) | $50-500 |
| 3 | .claudeignore (#6) | 5 minutes | $20-200 |
| 4 | CLAUDE.md structure (#3) | 30 minutes | $30-300 |
| 5 | Session segmentation (#7) | 0 minutes (habit) | $40-400 |
| 6 | Subagent controls (#4) | 5 minutes | $20-250 |
| 7 | Skills (#8) | 1 hour | $10-150 |
| 8 | Structured errors (#9) | 1 hour | $10-100 |

The first three techniques can be implemented in under 10 minutes and deliver 60-70% of the total possible savings. The remaining techniques provide incremental improvements that compound over time.

## Common Mistakes When Optimizing

**Mistake 1: Over-restricting file access.** Setting "never read more than 2 files" prevents Claude from doing effective work. The goal is 5-8 targeted reads, not zero reads.

**Mistake 2: Always using Haiku to save money.** Haiku 4.5 at $0.80/$4 per MTok is cheap, but it fails on tasks that Sonnet handles easily, leading to retries that cost more than using Sonnet from the start. Use Haiku only for truly simple tasks (rename variables, add imports, format code).

**Mistake 3: Compacting too aggressively.** Running `/compact` after every single tool call disrupts Claude's working memory. Compact when context exceeds 50% capacity or when switching between unrelated tasks.

**Mistake 4: Writing enormous CLAUDE.md files.** A 3,000-token CLAUDE.md costs 90,000 tokens per 30-turn session just to carry in context. Keep it under 400 tokens and move detailed information to skills.

**Mistake 5: Optimizing only one dimension.** Reducing file reads but ignoring retry loops captures only 20% of potential savings. The 15 techniques work as a system -- implement at least 5 from different categories (context management, error handling, model selection, session management) for comprehensive savings.

**Mistake 6: Not measuring before optimizing.** Without baseline measurements from `/cost` and ccusage, optimization is guesswork. Spend one week measuring before making changes, then measure again after to verify impact.

## Quick-Start Script

For developers who want to implement the top 5 techniques immediately, this script creates the essential files:

```bash
#!/bin/bash
# quick-optimize.sh -- implements techniques 1, 3, 5, 6, 8
set -euo pipefail

# Technique 6: .claudeignore
cat > .claudeignore << 'IGNORE'
node_modules/
dist/
build/
coverage/
.git/
*.lock
*.map
__snapshots__/
IGNORE

# Technique 3: Minimal CLAUDE.md
if [ ! -f CLAUDE.md ]; then
  cat > CLAUDE.md << 'MD'
## Project: $(basename $(pwd))
## Commands
- Test: npm test -- --testPathPattern="<file>"
- Build: npm run build
## Cost Rules
- Max 3 retries per error, then report
- Max 8 files before proposing solution
- Use /compact when context exceeds 100K
MD
fi

# Technique 8: Skills directory
mkdir -p .claude/skills
echo "Created .claudeignore, CLAUDE.md, and .claude/skills/"
echo "Next: set CLAUDE_MODEL=claude-sonnet-4-6 in your shell profile"
```

Running this script takes 30 seconds and captures the majority of savings available from the 15 techniques. Refine the CLAUDE.md and add skills iteratively as the project's cost patterns become clear.

## Related Guides

- [Claude Code Compact Command Guide](/claude-code-conversation-too-long-fresh-vs-compact/) -- deep dive on context compression
- [Claude Code Context Window Management](/claude-code-context-window-management-2026/) -- understanding the token lifecycle
- [Cost Optimization Hub](/cost-optimization/) -- all cost guides in one place

## See Also

- [Claude Code Cost Optimization Hub](/cost-optimization-hub/)
- [Firebase + Claude Code: Cost Optimization Guide](/firebase-claude-code-cost-optimization-guide/)
