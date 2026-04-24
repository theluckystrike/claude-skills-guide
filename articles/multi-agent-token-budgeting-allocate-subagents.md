---
title: "Multi-Agent Token Budgeting: Allocate Tokens Across Subagents"
description: "Allocate token budgets across Claude Code subagents to prevent runaway costs, with per-agent caps and delegation patterns saving $100-300/month."
permalink: /multi-agent-token-budgeting-allocate-subagents/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Multi-Agent Token Budgeting: Allocate Tokens Across Subagents

## The Pattern

Multi-agent token budgeting assigns explicit token limits to subagent operations through CLAUDE.md rules and task decomposition, preventing uncontrolled subagent spawning that can multiply session costs by 3-significantly.

## Why It Matters for Token Cost

Each Claude Code subagent spawns with approximately 5,000 tokens of base overhead (system prompt, tool definitions, CLAUDE.md loading). Beyond that, each subagent executes independently, consuming its own token budget without awareness of the parent's total spend.

A parent agent that spawns 5 subagents creates 6 independent token consumers. Without budgeting:
- Parent: 50K tokens
- 5 subagents x 40K each: 200K tokens
- Total: 250K tokens ($0.75 on Sonnet 4.6)

With budgeting (cap each subagent at 20K):
- Parent: 50K tokens
- 3 subagents x 20K each: 60K tokens (2 subagents avoided entirely)
- Total: 110K tokens ($0.33 on Sonnet 4.6)

**Savings: 56% per multi-agent task.** For teams running 5 multi-agent tasks per day, monthly savings reach $100-300 on Sonnet or $500-1,500 on Opus 4.6.

## The Anti-Pattern (What NOT to Do)

```markdown
# BAD CLAUDE.md -- no subagent controls
## Project Rules
- Feel free to use subagents for parallel work
- Break large tasks into smaller pieces
```

This gives Claude unlimited subagent spawning permission. A task like "refactor the API layer" can trigger 10+ subagents, each exploring the codebase independently and duplicating file reads.

**Observed cost:** A single "refactor the API" task with unconstrained subagents: 500K-1.5M tokens ($1.50-$4.50 Sonnet, $7.50-$22.50 Opus).

## The Pattern in Action

### Step 1: Define Subagent Limits

```markdown
# CLAUDE.md

## Subagent Rules
- Maximum 3 subagents per task
- Each subagent must have a SINGLE, specific file or function target
- Subagent scope: maximum 10 tool calls per subagent
- Never spawn a subagent just to read a file (use Read tool directly)
- Never spawn parallel subagents that might read the same files
```

### Step 2: Define Task-to-Agent Mapping

```markdown
# CLAUDE.md

## Task Delegation Guide
### Single-agent tasks (NO subagents needed):
- Bug fix in 1 file
- Add a test for existing function
- Update configuration
- Documentation changes

### Multi-agent tasks (up to 2 subagents):
- Feature spanning 2-3 files
- Refactoring a single module
- Adding a new API endpoint with test

### Complex tasks (up to 3 subagents, requires planning step):
- Cross-module refactoring
- New feature spanning 4+ files
- Migration with data transformation
```

### Step 3: Implement Budget-Aware Delegation

```markdown
# CLAUDE.md

## Agent Budget Protocol
Before spawning any subagent:
1. State the total remaining token budget for this task
2. Allocate a specific budget to the subagent (max 30% of remaining)
3. Define the subagent's deliverable in one sentence
4. Confirm the subagent will NOT need to spawn its own subagents

Example delegation:
"Subagent 1: Edit src/api/routes/users.ts to add the GET /users/:id/preferences
endpoint. Follow the pattern in GET /users/:id. Budget: 15K tokens. Deliverable:
the route handler function with validation."
```

## Before and After

| Metric | No Budget | With Budget | Savings |
|--------|-----------|-------------|---------|
| Subagents per task | 5-10 | 2-3 | 50-70% fewer |
| Spawn overhead | 25K-50K tokens | 10K-15K tokens | 60-70% |
| Duplicate file reads | 30K-100K tokens | 0-5K tokens | 95% |
| Total per complex task | 250K-500K tokens | 80K-150K tokens | 60-70% |
| Monthly cost (5 tasks/day, Sonnet) | $225-$450 | $72-$135 | $153-$315 |

## When to Use This Pattern

- Any project where Claude Code regularly spawns subagents
- Monorepos where file exploration can be expensive
- Tasks that involve more than 3 files
- Team environments where cost predictability matters

## When NOT to Use This Pattern

- Simple single-file tasks where subagents are never triggered
- Exploratory sessions where broad search is intentional
- One-off tasks where budget tracking overhead exceeds savings

## Implementation in CLAUDE.md

```markdown
# CLAUDE.md

## Multi-Agent Cost Controls

### Hard Rules
- Max 3 subagents per task (NEVER exceed)
- Each subagent: max 10 tool calls
- Never spawn subagent for: file reads, grep searches, git commands
- Never spawn nested subagents (subagents must not spawn their own)

### Budget Allocation
- Simple task (1 file): 0 subagents, 30K token budget
- Medium task (2-3 files): 1-2 subagents, 80K total budget
- Complex task (4+ files): 2-3 subagents, 150K total budget
- If budget is exceeded: stop and report progress, do not spawn more agents

### Delegation Template
When delegating to a subagent, specify:
1. Target file(s) -- max 2 per subagent
2. Specific change to make
3. Expected output (what the subagent should produce)
```

## Subagent Cost Accounting

Understanding the full cost of a subagent helps justify budgeting:

### Per-Subagent Cost Breakdown

```
Base overhead:
  System prompt loading: ~2,000 tokens
  Tool definitions: ~1,500 tokens
  CLAUDE.md loading: ~500 tokens
  Task description from parent: ~500-1,000 tokens
  Total base: ~4,500-5,000 tokens

Per-turn cost (within subagent):
  Context re-read: all accumulated tokens
  Tool call overhead: ~245 tokens per Bash, ~150 per Read
  Response generation: varies

Typical subagent session (5-8 turns):
  Turn 1: 5K context, Turn 2: 8K, Turn 3: 12K, ...
  Total input: ~40K-60K tokens
  Total output: ~8K-15K tokens

Cost per subagent:
  Sonnet: (50K x $3 + 12K x $15) / 1M = $0.33
  Opus: (50K x $15 + 12K x $75) / 1M = $1.65
```

### When Subagents Provide Positive ROI

Subagents save tokens when they eliminate redundant work that would otherwise happen in the parent context:

```
Scenario: Edit 3 independent files

Sequential (parent only):
  Read file 1 + edit + verify: 20K tokens
  Read file 2 + edit + verify: 20K tokens (40K context from file 1 still loaded)
  Read file 3 + edit + verify: 20K tokens (60K context from files 1+2 loaded)
  Total: 20K + 40K + 60K = 120K tokens (context accumulation)

Parallel (3 subagents):
  Subagent 1: 30K tokens (fresh context)
  Subagent 2: 30K tokens (fresh context)
  Subagent 3: 30K tokens (fresh context)
  Parent overhead: 10K tokens (delegation)
  Total: 100K tokens

Savings: 20K tokens (17%) -- subagents win due to fresh context
```

Subagents provide positive ROI when:
1. Tasks are genuinely independent (no shared file dependencies)
2. Context accumulation in the parent would exceed subagent overhead
3. Three or fewer subagents are needed (diminishing returns beyond 3)

Subagents provide negative ROI when:
1. Tasks share files (subagents re-read the same files)
2. Tasks are small (base overhead exceeds task cost)
3. Many subagents are spawned (overhead dominates)

## Team Guidelines for Subagent Usage

Create a team reference for subagent decisions:

```markdown
# .claude/skills/subagent-guide.md

## Subagent Decision Matrix
| Task Description | Subagents | Reasoning |
|-----------------|-----------|-----------|
| Fix bug in 1 file | 0 | Too small for subagent overhead |
| Add feature (2 files) | 0-1 | Only if files are independent |
| Refactor (3+ independent files) | 2-3 | Fresh context per subagent saves tokens |
| Add test for each of 5 functions | 0 | Sequential is cheaper (shared test file) |
| Update 3 config files | 2-3 | Independent files, parallel is efficient |
| Cross-file refactoring | 0 | Shared dependencies = redundant reads |

## Red Flags (Too Many Subagents)
- More than 3 subagents in a single response
- Subagent reading same file as another subagent
- Subagent spawning its own subagent
- Subagent task description over 200 tokens (task is too complex)
```

## Monitoring Subagent Costs

Track subagent-related token consumption:

```bash
# In a session with subagents, check /cost before and after
/cost  # Before subagent delegation: 45K tokens

# After subagent execution
/cost  # After: 180K tokens

# Subagent cost: 180K - 45K = 135K tokens
# For 3 subagents: ~45K each
# Was it worth it? Check if the same work sequentially would have cost more
```

If subagent costs consistently exceed 50K tokens each, the tasks being delegated are too complex. Decompose further.

## Budget Enforcement Through CLAUDE.md Templates

Provide specific budget templates for common task patterns:

```markdown
# CLAUDE.md -- Subagent Budget Templates

## Template: Feature Addition (2-3 files)
Total budget: 80K tokens
- Parent coordination: 20K tokens
- Subagent 1 (implementation): 25K tokens, 1 file target
- Subagent 2 (tests): 25K tokens, 1 test file target
- Verification: 10K tokens
- If budget exceeded at any stage: stop and report progress

## Template: Refactoring (3-5 files)
Total budget: 120K tokens
- Parent planning: 15K tokens (identify files, plan changes)
- Subagent 1: 30K tokens, 2 file targets max
- Subagent 2: 30K tokens, 2 file targets max
- Subagent 3: 30K tokens, 1 file target max (if needed)
- Verification: 15K tokens
```

These templates give Claude concrete numbers to work with, reducing the likelihood of budget overruns. Review and adjust the token budgets in these templates monthly based on actual `/cost` data -- initial estimates are typically 20-30% off from real usage, and calibrated templates provide significantly tighter cost control.

## Related Guides

- [Claude Code Subagent Management](/claude-code-multi-agent-subagent-communication-guide/) -- subagent behavior reference
- [Claude Code Monorepos: Scoping Context](/claude-code-monorepos-scoping-context-reduce-costs/) -- scoping for large codebases
- [Cost Optimization Hub](/cost-optimization/) -- all cost optimization techniques
