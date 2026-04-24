---
title: "Fix Skill Conflicts with MCP Servers"
description: "Resolve conflicts when SKILL.md instructions and MCP server tools overlap, producing duplicate actions, inconsistent behavior, or tool confusion."
permalink: /fix-skill-conflicts-with-mcp-server/
render_with_liquid: false
categories: [skills, 2026]
tags: [claude-code, claude-skills, mcp, conflicts, troubleshooting]
last_updated: 2026-04-19
---

## The Specific Situation

You have an MCP server that provides `jira_create_issue` as a tool. You also have a skill that tells Claude to create Jira issues using `curl` commands. When you say "create a Jira ticket," Claude sometimes uses the MCP tool and sometimes uses the skill's curl approach. The results are inconsistent -- the MCP tool authenticates correctly but the curl commands fail because the API token is expired. You need to resolve the overlap.

## Technical Foundation

Skills and MCP servers are separate systems in Claude Code:

- **Skills** are markdown instructions that tell Claude HOW to use its existing tools
- **MCP servers** are running processes that give Claude NEW tools

They coexist in Claude's available tool set. When a user request matches both a skill's description and an MCP tool's description, Claude chooses based on its assessment of which approach better fits the request. This choice is not deterministic.

Skills cannot create new tools. MCP servers cannot provide multi-step workflow instructions. The conflict arises when both try to achieve the same outcome through different mechanisms.

## The Working SKILL.md (MCP-Aware)

A skill that explicitly uses MCP tools instead of competing with them:

```yaml
---
name: jira-workflow
description: >
  Manage Jira tickets using the team workflow. Creates tickets with
  required fields, assigns them, and links to the current PR.
  Use when the user says "create a ticket", "Jira task", or "log issue".
disable-model-invocation: true
argument-hint: "[title] [description]"
---

# Jira Workflow

Create and manage Jira tickets using the Jira MCP server tools.

## Important

Use the Jira MCP tools (jira_create_issue, jira_update_issue,
jira_search) for ALL Jira operations. Do NOT use curl or the
REST API directly. The MCP server handles authentication.

## Create Ticket

1. Use `jira_create_issue` with these required fields:
   - project: PROJ
   - summary: from $ARGUMENTS
   - issuetype: Task
   - priority: Medium (default)
   - labels: ["from-claude"]

2. After creation, use `jira_update_issue` to set:
   - assignee: current user
   - sprint: current sprint

3. If on a git branch, add the ticket ID to the branch name:
   ```bash
   git branch -m "$(git branch --show-current)" "PROJ-XXX/$(git branch --show-current)"
   ```

## Search Tickets

Use `jira_search` with JQL:
- My open tickets: `assignee = currentUser() AND status != Done`
- Current sprint: `sprint in openSprints() AND project = PROJ`
```

## Conflict Pattern 1: Overlapping Functionality

**Problem**: MCP tool and skill both handle the same action.

```
MCP: jira_create_issue (authenticated, structured input)
Skill: curl -X POST .../rest/api/3/issue (manual auth, raw JSON)
```

Claude picks whichever seems more appropriate, inconsistently.

**Fix**: Remove the redundant approach. If you have an MCP server for Jira, update the skill to USE the MCP tools instead of reimplementing via curl. The skill adds workflow (what fields to set, what order), and the MCP server provides the tool (authenticated API access).

## Conflict Pattern 2: Description Overlap

**Problem**: The MCP tool's description and the skill's description both match the same user requests.

```
MCP tool description: "Create a Jira issue"
Skill description: "Create and manage Jira tickets"
```

When the user says "create a ticket," both match equally.

**Fix**: Make the skill description specific to the workflow, not the action:

```yaml
# CONFLICTING: matches the same thing as the MCP tool
description: Create Jira issues

# RESOLVED: describes the workflow, not the action
description: >
  Run the full Jira ticket creation workflow including required
  field validation, sprint assignment, and branch linking.
  Use /jira-workflow for the full process.
```

## Conflict Pattern 3: Permission Conflicts

**Problem**: A skill's `allowed-tools` grants Bash access to curl, but the MCP server should be the only way to access the API.

```yaml
# RISKY: skill pre-approves curl, bypassing MCP auth
allowed-tools: Bash(curl *)

# FIXED: remove curl, let the skill use MCP tools
allowed-tools: Read Grep
# MCP tools don't need to be in allowed-tools
```

MCP tools are separate from `allowed-tools`. You do not need to list MCP tool names in `allowed-tools` -- they are managed by the MCP server configuration. The `allowed-tools` field only affects Claude's built-in tools (Bash, Read, Grep, etc.).

## Conflict Pattern 4: Partial Overlap

**Problem**: MCP server handles creation but not the full workflow. The skill adds workflow steps but also reimplements creation.

**Fix**: Clean separation. The skill orchestrates, the MCP server executes:

```yaml
---
name: incident-response
description: >
  Run the incident response workflow. Creates ticket, notifies
  team, creates branch, and sets up monitoring.
disable-model-invocation: true
---

# Incident Response

## Step 1: Create Incident Ticket
Use `jira_create_issue` with issuetype: Bug, priority: Critical

## Step 2: Notify Team
Use `slack_send_message` to #incidents channel

## Step 3: Create Fix Branch
```bash
git checkout -b fix/INCIDENT-XXX
```

## Step 4: Set Up Monitoring
Use `datadog_create_monitor` for the affected service
```

The skill coordinates four different MCP tools without reimplementing any of them.

## Diagnostic Steps

```
1. Ask Claude: "What tools do you have available?"
   → Lists both built-in tools and MCP tools

2. Ask Claude: "What skills are available?"
   → Lists all skills with descriptions

3. Compare: Do any skills describe the same action as an MCP tool?
   → If yes, that's your conflict

4. Test: Ask Claude to perform the action
   → Which approach does it choose? Is it consistent?
```

## Common Problems and Fixes

**Claude uses curl instead of MCP tool**: The skill tells Claude to use curl. Update the skill to reference the MCP tool by name: "Use `jira_create_issue`, not curl."

**MCP tool fails but skill would work**: The MCP server may be down or misconfigured. Add fallback logic to the skill: "If `jira_create_issue` fails, report the error. Do not fall back to curl."

**Both approaches produce slightly different results**: MCP tools may add default fields that curl commands omit. Standardize on one approach and remove the other.

**Skill auto-triggers when MCP tool should handle it**: Set `disable-model-invocation: true` on the skill. Let users choose between the direct MCP tool (simple action) and the skill (full workflow).

## Production Gotchas

MCP servers and skills are configured in different places. MCP servers are in Claude Code settings (or `mcp.json`). Skills are in `.claude/skills/`. There is no unified view that shows potential conflicts between them. You must manually audit both systems.

When an MCP server is unavailable (not running, network error), its tools disappear from Claude's available tools. The skill remains available. This can cause inconsistent behavior: sometimes Claude uses the MCP tool, sometimes the skill, depending on whether the server is up.

MCP tool permissions and skill `allowed-tools` are independent systems. Denying an MCP tool in permissions does not affect skills, and vice versa. If you deny `Bash(curl *)` to prevent direct API access, the MCP tool still works because it does not use the Bash tool.

## Checklist

- [ ] Skills reference MCP tools by name instead of reimplementing via curl/API
- [ ] Skill descriptions describe workflows, not raw actions that overlap MCP tools
- [ ] `allowed-tools` does not include Bash patterns that bypass MCP authentication
- [ ] No overlapping descriptions between skills and MCP tool descriptions
- [ ] Fallback behavior defined for when MCP server is unavailable

## Related Guides

- [Claude Skills vs MCP Servers: When to Use Each](/claude-skills-vs-mcp-servers-differences/)
- [SKILL.md Frontmatter Fields Explained](/skill-md-file-frontmatter-fields-explained/)
- [Security Review Process for Claude Skills](/security-review-process-for-claude-skills/)
