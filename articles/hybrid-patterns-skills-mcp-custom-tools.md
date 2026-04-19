---
title: "Hybrid Patterns: Claude Skills + MCP Servers + Custom Tools — When to Combine All Three — 2026"
description: "Design hybrid architectures combining Claude Code skills (instructions), MCP servers (external access), and custom tools (scripts). With 3 production patterns."
permalink: /hybrid-patterns-skills-mcp-custom-tools/
render_with_liquid: false
categories: [skills, 2026]
tags: [claude-code, claude-skills, mcp, custom-tools, hybrid]
last_updated: 2026-04-19
---

## The Specific Situation

Your project needs Claude to: (1) follow specific query patterns when accessing your PostgreSQL database, (2) pull data from your company's internal API, (3) generate reports using a custom Python visualization script, and (4) output results in a format your Slack webhook accepts. No single tool handles all of this. Skills handle the query patterns and report format. An MCP server handles the database and API access. A custom script handles the visualization. You need all three working together.

## Technical Foundation

Claude Code has three extension mechanisms, each serving a different role:

**Skills** (SKILL.md) provide procedural instructions -- the "how to do it" layer. They encode workflows, conventions, checklists, and decision logic. Skills influence Claude's behavior through natural language loaded into context.

**MCP Servers** (Model Context Protocol) provide capability access -- the "what Claude can reach" layer. MCP servers expose tools (functions), resources (data), and prompts (templates) from external systems. They run as separate processes communicating via JSON-RPC.

**Custom tools** (scripts, CLI wrappers) provide execution -- the "what Claude can run" layer. These are bash scripts, Python programs, or CLI tools that Claude executes via the `Bash` tool. Skills pre-approve them with `allowed-tools`.

The hybrid pattern: **Skills orchestrate, MCP servers provide access, scripts execute**.

## The Working SKILL.md

Hybrid reporting skill:

```yaml
---
name: weekly-report
description: >
  Generate the weekly engineering report. Pulls data from PostgreSQL
  (via MCP), runs visualization script, and posts summary to Slack.
  Invoke with: /weekly-report [week-number]
disable-model-invocation: true
allowed-tools: mcp__postgres__query mcp__internal_api__get_metrics Bash(python3 *) Bash(curl *)
---

# Weekly Engineering Report Generator

## Data Collection Phase

### Step 1: Pull deployment metrics from PostgreSQL
Use the postgres MCP server to query:
```sql
SELECT
  date_trunc('day', deployed_at) as deploy_date,
  COUNT(*) as deploy_count,
  AVG(EXTRACT(EPOCH FROM (completed_at - started_at))) as avg_duration_sec,
  COUNT(CASE WHEN status = 'failed' THEN 1 END) as failure_count
FROM deployments
WHERE deployed_at >= NOW() - INTERVAL '$ARGUMENTS[0] weeks'
GROUP BY 1
ORDER BY 1;
```
Save result to `.claude/staging/deploy-metrics.json`.

### Step 2: Pull velocity metrics from internal API
Use the internal_api MCP server:
- Endpoint: `get_metrics(team="engineering", period="week", week=$ARGUMENTS[0])`
- Fields needed: story_points_completed, bugs_closed, pr_merge_time_avg
Save result to `.claude/staging/velocity-metrics.json`.

### Step 3: Pull incident data
Use postgres MCP server:
```sql
SELECT severity, title, mttr_minutes, root_cause_category
FROM incidents
WHERE created_at >= NOW() - INTERVAL '7 days'
ORDER BY severity, created_at;
```
Save to `.claude/staging/incidents.json`.

## Visualization Phase

### Step 4: Generate charts
Run the visualization script:
```bash
python3 scripts/generate-report-charts.py \
  --deploys .claude/staging/deploy-metrics.json \
  --velocity .claude/staging/velocity-metrics.json \
  --incidents .claude/staging/incidents.json \
  --output reports/week-$ARGUMENTS[0]-charts.html
```

## Report Phase

### Step 5: Compose report
Using the collected data, write a report covering:
- Deployment frequency and failure rate (target: <5% failure)
- Velocity trend vs previous 4 weeks
- Incident summary with MTTR analysis
- Top 3 highlights and top 3 concerns

### Step 6: Post to Slack
```bash
curl -X POST "$SLACK_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d @.claude/staging/slack-payload.json
```

## Output Artifacts
- `.claude/staging/deploy-metrics.json` (raw data)
- `.claude/staging/velocity-metrics.json` (raw data)
- `.claude/staging/incidents.json` (raw data)
- `reports/week-$ARGUMENTS[0]-charts.html` (visualization)
- `reports/week-$ARGUMENTS[0]-summary.md` (narrative report)
```

## Three Production Patterns

### Pattern 1: Skill + MCP (Guided Data Access)
Skill provides query patterns and output format. MCP server provides database access. No custom scripts.

Use when: You need controlled access to external data with consistent querying conventions.

```yaml
allowed-tools: mcp__postgres__query
```

The skill prevents Claude from writing dangerous queries (no DELETE, no SELECT *, mandatory WHERE clause). The MCP server provides the connection. Neither works well alone -- MCP without a skill means unguided queries; a skill without MCP means no database access.

### Pattern 2: Skill + Scripts (Local Processing Pipeline)
Skill provides workflow instructions. Scripts handle data transformation, visualization, or validation. No MCP servers.

Use when: All data is local and processing needs custom code.

```yaml
allowed-tools: Bash(python3 scripts/*) Bash(node scripts/*)
```

The skill orchestrates which scripts run in what order. Scripts handle the computation. This pattern is common for CI/CD skills, code generation skills, and report generation skills.

### Pattern 3: Skill + MCP + Scripts (Full Hybrid)
All three layers. Skill orchestrates the workflow. MCP servers provide external data. Scripts process and visualize.

Use when: The workflow spans external systems, local processing, and structured output.

```yaml
allowed-tools: mcp__postgres__query mcp__slack__post_message Bash(python3 *)
```

This is the most powerful pattern but also the most complex. Each layer must be independently testable.

## Common Problems and Fixes

**MCP tool not found at runtime.** The skill references `mcp__postgres__query` but the MCP server is not configured. Add a prerequisite check to the skill: "Before starting, verify the postgres MCP server is available by listing available tools."

**Script fails but skill continues.** Claude may not detect a script's non-zero exit code. Add explicit error checking: "After running the script, check if the output file exists and is non-empty. If the file is missing or empty, the script failed -- report the error and stop."

**MCP server returns unexpected format.** The skill expects JSON from an MCP query, but the server returns a table string. Test MCP tool outputs manually before encoding expectations in the skill. Different MCP server implementations may return data in different formats.

**Token overload from three layers.** A skill with 3,000 tokens of instructions plus 40 MCP tool descriptions plus detailed script documentation can exhaust the context budget. Keep the skill focused on orchestration. Move detailed MCP tool usage examples and script documentation to `references/` files.

## Production Gotchas

MCP server permissions are separate from skill `allowed-tools`. The skill pre-approves `mcp__postgres__query`, but the MCP server's database connection uses its own credentials. If the database user has write access, Claude can execute INSERT/UPDATE through the MCP tool even if the skill only instructs SELECT queries. Use read-only database credentials for reporting MCP servers.

Custom scripts bundled with skills should use only standard-library dependencies. If a Python script requires `pandas` and `matplotlib`, every developer must have those installed. Either document requirements in a `requirements.txt` or use Docker for reproducible script execution.

## Checklist

- [ ] Each layer serves a distinct purpose (instructions, access, execution)
- [ ] MCP servers configured with appropriate credential scope
- [ ] Scripts tested independently before skill integration
- [ ] Skill verifies MCP availability before starting workflow
- [ ] Error handling at each phase boundary (data collection, processing, output)

## Related Guides

- [Claude Skills vs MCP Servers](/claude-skills-vs-mcp-servers-comparison/) -- understanding the boundary
- [Claude Skills Data Flow Patterns](/claude-skills-data-flow-patterns/) -- file-based interfaces between phases
- [Claude Skill Composition Patterns](/claude-skill-composition-patterns/) -- orchestration architectures
