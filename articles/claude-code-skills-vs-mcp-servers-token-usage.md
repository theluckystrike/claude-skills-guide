---
title: "Claude Code Skills vs MCP Servers: Which Uses Fewer Tokens?"
description: "Skills use 60-80% fewer tokens than MCP servers for common Claude Code tasks. Compare overhead, latency, and cost to pick the right tool."
permalink: /claude-code-skills-vs-mcp-servers-token-usage/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code Skills vs MCP Servers: Which Uses Fewer Tokens?

## The Problem

Claude Code offers two extension mechanisms -- skills and MCP servers -- and choosing the wrong one can cost 500-2,000 extra tokens per invocation. Over a full workday of 40-60 tool calls, that overhead adds up to 20K-120K wasted tokens, translating to $0.06-$1.80 per day on Sonnet 4.6 ($3/$15 per MTok). The difference compounds across teams: a 10-person engineering org making the wrong choice bleeds $12-$360 per month on pure overhead.

## Quick Wins (Under 5 Minutes)

1. **Audit your MCP server tool count** -- run `claude mcp list` and count definitions. Each tool definition costs 500-2,000 tokens in context overhead. Remove tools not used in the past week.
2. **Convert simple instructions to skills** -- any MCP server that just provides text guidance belongs in a `.claude/skills/` markdown file instead. Zero tool-definition overhead.
3. **Check for duplicate functionality** -- if both a skill and an MCP tool provide the same capability, delete the MCP tool.
4. **Set `--allowedTools` flags** -- restrict which MCP tools load per session to cut definition overhead.
5. **Move static data out of MCP responses** -- if an MCP tool returns the same data every time, put it in a skill file.

## Deep Optimization Strategies

### Strategy 1: Understand the Token Cost Structure

Skills are markdown files in `.claude/skills/` that Claude Code reads on demand. The token cost is straightforward:

```yaml
# .claude/skills/deploy.md -- approximately 200 tokens
# Loaded ONLY when Claude determines it's relevant

## Deploy Workflow
- Run `pnpm build` first
- Deploy with `vercel deploy --prod`
- Verify with `curl -s https://example.com/health`
- If health check fails, run `vercel rollback`
```

An equivalent MCP server carries structural overhead on every session:

```json
{
  "tools": [
    {
      "name": "deploy_project",
      "description": "Deploys the project to production...",
      "inputSchema": {
        "type": "object",
        "properties": {
          "environment": { "type": "string", "enum": ["staging", "production"] },
          "skip_tests": { "type": "boolean", "default": false }
        },
        "required": ["environment"]
      }
    }
  ]
}
```

The MCP tool definition alone costs ~800 tokens. Add the server handshake, response framing, and JSON parsing, and each invocation runs 1,200-1,800 tokens. The skill equivalent costs ~200 tokens when loaded and zero tokens when not referenced.

**Savings: 600-1,600 tokens per invocation (75-89% reduction)**

### Strategy 2: Use Skills for Knowledge, MCP for Actions

The decision framework is simple: if the extension provides *information*, use a skill. If it *performs an action* that requires runtime state or external API calls, use MCP.

```markdown
# .claude/skills/database-conventions.md -- ~400 tokens
# Knowledge that reduces discovery queries

## Database Conventions
- All tables use snake_case naming
- Primary keys: `id` (uuid, generated)
- Timestamps: `created_at`, `updated_at` (always present)
- Soft deletes: `deleted_at` column (nullable)
- Foreign keys: `{table_name}_id` format
- Indexes: `idx_{table}_{column}` naming

## Common Queries
- User lookup: `SELECT * FROM users WHERE email = $1`
- Active subscriptions: `SELECT * FROM subscriptions WHERE status = 'active' AND deleted_at IS NULL`
```

This skill eliminates 3-5 discovery queries per session (each costing 2,000-5,000 tokens in tool calls and responses), saving 6,000-25,000 tokens per session.

For runtime actions that *must* interact with live systems, MCP remains the correct choice:

```json
{
  "mcpServers": {
    "database": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://localhost/mydb"],
      "env": {}
    }
  }
}
```

**Savings: 6,000-25,000 tokens per session by moving knowledge to skills**

### Strategy 3: Slim Down MCP Tool Definitions

When MCP is necessary, minimize the token cost of tool definitions. Remove verbose descriptions, optional parameters with defaults, and example values:

```json
{
  "name": "query_db",
  "description": "Run read-only SQL query",
  "inputSchema": {
    "type": "object",
    "properties": {
      "sql": { "type": "string" }
    },
    "required": ["sql"]
  }
}
```

Compare this lean definition (~200 tokens) with a bloated version that includes 10 optional parameters, detailed enum values, and paragraph-length descriptions (~1,500 tokens). Across 8 tools in a server, the difference is 10,400 tokens of context overhead.

**Savings: ~1,300 tokens per tool definition (up to 10,000+ tokens per server)**

### Strategy 4: Implement Progressive Skill Loading

Structure skills so Claude Code loads only what it needs for the current task:

```text
.claude/skills/
  deploy.md          # 200 tokens -- loaded for deploy tasks
  testing.md         # 300 tokens -- loaded for test tasks
  db-migrations.md   # 250 tokens -- loaded for migration tasks
  api-patterns.md    # 350 tokens -- loaded for API work
```

Versus a single MCP server with all tools registered at startup:

```text
MCP server with 12 tools:
  deploy_staging      ~800 tokens
  deploy_production   ~800 tokens
  run_tests           ~600 tokens
  run_migration       ~700 tokens
  ...8 more tools     ~5,600 tokens
  ─────────────────────────────
  Total: ~8,500 tokens loaded every session
```

Skills load selectively. MCP tool definitions load entirely. For a project with 12 capabilities, skills save 7,000-8,000 tokens on sessions where only 1-2 capabilities are needed.

**Savings: 7,000-8,000 tokens on focused sessions (82-94% reduction)**

### Strategy 5: Hybrid Approach for Complex Projects

Most real projects need both skills and MCP servers. The optimal configuration uses skills for static knowledge and MCP for dynamic operations, with clear boundaries:

```yaml
# .claude/skills/ (static knowledge, zero runtime overhead)
database-conventions.md    # ~400 tokens: schema, naming, migration rules
api-patterns.md            # ~350 tokens: route conventions, error formats
deploy-procedure.md        # ~300 tokens: step-by-step deployment
test-conventions.md        # ~250 tokens: test patterns, mocking rules

# MCP servers (dynamic operations, justified runtime cost)
postgres:                  # 1 tool: sql query (~500 tokens definition)
  - Used 15+ times per session in database-heavy work
  - Cannot be replaced by CLI (parameterized queries, connection pooling)
```

The hybrid configuration loads ~1,300 tokens of skills (on-demand) + ~500 tokens of MCP definitions = ~1,800 tokens maximum. Compare to an all-MCP approach with 5 servers and 20 tools: ~15,000 tokens of definitions.

Document the boundary in CLAUDE.md:

```markdown
## Tool Selection Rules
- For project conventions and procedures: check skills first
- For database queries (10+ per session): use mcp__postgres__sql
- For everything else (git, file ops, API calls): use Bash tool with CLI commands
- Do not add MCP servers for operations achievable with 2 CLI commands or fewer
```

**Savings from hybrid approach: 10,000-13,000 tokens per session versus all-MCP**

### Strategy 6: Measuring Skill vs MCP Effectiveness

Track which approach is used for each operation type to optimize the split:

```bash
#!/bin/bash
# scripts/audit-tool-choice.sh
# Analyze whether tools are using skills vs MCP vs CLI efficiently
set -uo pipefail

MCP_LOG="${HOME}/.claude/mcp-usage-log.jsonl"

if [ ! -f "$MCP_LOG" ]; then
  echo "No MCP usage log found. Enable logging hooks first."
  exit 0
fi

echo "=== MCP Usage Audit (Last 7 Days) ==="

# Count MCP calls per tool
echo "MCP tool call frequency:"
grep -o '"tool":"[^"]*"' "$MCP_LOG" | sort | uniq -c | sort -rn

echo ""
echo "Tools with <5 calls in 7 days should be migrated to CLI or skills."
echo "Tools with >50 calls in 7 days justify their MCP overhead."
```

Any MCP tool called fewer than 5 times per week does not justify its 500-2,000 token overhead. Replace it with a skill (for knowledge) or a CLI alias (for actions).

## Measuring Your Savings

Track token usage before and after migration with the built-in `/cost` command:

```bash
# Before: note the session cost at end of task
# Claude Code displays: "Total cost: $0.42 | Tokens: 128,450"

# After migrating 5 MCP tools to skills:
# Claude Code displays: "Total cost: $0.18 | Tokens: 54,200"
```

For detailed per-session tracking, use the `ccusage` utility:

```bash
# Install ccusage
npm install -g ccusage

# View costs broken down by session
ccusage --sort cost --limit 20
```

### Strategy 7: Migration Checklist -- MCP to Skills

For teams with existing MCP servers, a systematic migration process:

```markdown
## MCP-to-Skills Migration Checklist

### Step 1: Audit current MCP servers
- [ ] Run `claude mcp list` to inventory all servers and tools
- [ ] For each tool: count calls in the past 7 days (from monitoring hooks)
- [ ] Classify each tool: action (must stay MCP) or knowledge (can migrate to skill)

### Step 2: Create skills for knowledge tools
- [ ] For each knowledge tool: create a .claude/skills/{topic}.md file
- [ ] Include all the information the MCP tool was providing
- [ ] Add the skill to CLAUDE.md as a reference

### Step 3: Remove migrated MCP tools
- [ ] Remove knowledge-only MCP servers: `claude mcp remove <name>`
- [ ] Verify sessions still work without the removed servers
- [ ] Monitor token usage for 1 week to confirm savings

### Step 4: Optimize remaining MCP servers
- [ ] Slim tool definitions (short names, minimal descriptions)
- [ ] Remove unused tools from remaining servers
- [ ] Set --allowedTools for sessions that don't need MCP
```

Expected timeline: 2-4 hours of migration work. Expected savings: 5,000-20,000 tokens per session, paying back the migration time within 1-2 days.

## Cost Impact Summary

| Technique | Token Savings | Monthly Savings (Sonnet 4.6) |
|-----------|--------------|------------------------------|
| Convert info MCP tools to skills | 6,000-25,000/session | $1.80-$7.50 |
| Slim tool definitions | 1,300/tool | $0.40-$2.00 |
| Progressive skill loading | 7,000-8,000/session | $2.10-$4.80 |
| Remove unused MCP tools | 500-2,000/tool | $0.15-$1.20 |
| **Combined** | **15,000-36,000/session** | **$4.45-$15.50** |

Monthly estimates assume 20 working days, 5 sessions per day, at Sonnet 4.6 blended rate of ~$0.006/1K tokens.

The combined savings make skills-vs-MCP optimization one of the highest-ROI activities for Claude Code cost reduction. The migration effort (2-4 hours for a typical project) pays back within the first week and continues saving tokens indefinitely.

For teams of 5 developers, multiply the individual savings by 5: $22.25-$77.50 per month. Over a year, this single optimization saves $267-$930 -- significant for budget-conscious teams and well worth the initial setup time. The savings also compound with other optimization techniques: a leaner context from fewer MCP tools means /compact is more effective, which means even more savings on long sessions.

### Decision Flowchart: Skill or MCP?

When adding a new capability to a Claude Code workflow, apply this decision process:

1. **Does it provide static information?** (conventions, schemas, procedures) -- Use a skill file. Zero runtime overhead, loads only when relevant.

2. **Does it require an external API call?** (database query, HTTP request, service interaction) -- Use MCP if called 9+ times per session. Otherwise, use a Bash CLI command.

3. **Does it depend on runtime state?** (environment variables, current deployment, live metrics) -- Use MCP for live data. Use a skill for the template/format of that data.

4. **Could two CLI commands replace it?** -- If yes, skip MCP entirely. Document the CLI commands in a skill file or CLAUDE.md.

5. **Is it used in more than 30% of sessions?** -- If yes, the per-session overhead of MCP is amortized. If no, the overhead is wasted on 70%+ of sessions.

This flowchart eliminates the most common mistake: using MCP for everything. Most teams find that 60-80% of their MCP tools should be skills or CLI commands, with only 2-3 tools genuinely requiring the MCP runtime overhead.

### Real-World Migration Example

A typical SaaS project before optimization:

```text
MCP servers: 3 (postgres, github, filesystem)
Tools: 18 total (~15,000 tokens overhead)
Skills: 0

After migration:
MCP servers: 1 (postgres -- 2 lean tools, ~400 tokens)
Skills: 6 files (~1,800 tokens total, loaded on-demand)
Typical session: ~600 tokens of context (1 skill + postgres)

Overhead reduction: 15,000 -> 600 = 96% reduction
Monthly savings at 100 sessions: ~$8.64 per developer
```

The migration took 3 hours. The savings recur every month indefinitely.

## Related Guides

- [Claude Code Skills Guide](/claude-code-skills-guide/) -- full reference for creating and managing skills
- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/) -- MCP installation and configuration
- [Claude Code Context Window Management](/claude-code-context-window-management/) -- broader context optimization strategies

- [Claude Code Skills Guide](/claude-code-skills-guide/) -- full reference for creating and managing skills
- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/) -- MCP installation and configuration
- [Claude Code Context Window Management](/claude-code-context-window-management/) -- broader context optimization strategies
