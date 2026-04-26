---
layout: post
title: "Claude Code + Linear MCP Integration (2026)"
description: "Connect Claude Code to Linear via MCP for automated issue management, sprint planning, and PR-to-issue linking with working config examples."
permalink: /claude-code-linear-mcp-integration-2026/
date: 2026-04-21
last_tested: "2026-04-21"
---

## The Workflow

Connect Claude Code to Linear's project management system through the Model Context Protocol (MCP). This enables Claude Code to read issues, create tasks, update statuses, and link PRs to issues directly from your terminal.

Expected time: 15 minutes
Prerequisites: Linear account with API key, Claude Code CLI installed, Node.js 18+

## Setup

### 1. Get Your Linear API Key

```bash
# Navigate to Linear → Settings → API → Personal API Keys
# Create a new key with these scopes:
# - issues:read, issues:write
# - projects:read
# - teams:read
# - comments:write

# Store it securely
export LINEAR_API_KEY="lin_api_xxxxxxxxxxxxxxxxxxxxx"
```

### 2. Install the Linear MCP Server

```bash
npm install -g @anthropic-ai/mcp-server-linear
```

This installs the official MCP server that bridges Claude Code and Linear's API.

### 3. Configure Claude Code MCP Settings

```json
// ~/.claude/settings.json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["@anthropic-ai/mcp-server-linear"],
      "env": {
        "LINEAR_API_KEY": "lin_api_xxxxxxxxxxxxxxxxxxxxx"
      }
    }
  }
}
```

### 4. Create a Project CLAUDE.md with Linear Context

```markdown
# Project: MyApp Backend

## Linear Integration
- Team: Backend (key: BACK)
- Current sprint: Sprint 24
- Label conventions: bug, feature, tech-debt, dx
- Estimate scale: 1=trivial, 2=small, 3=medium, 5=large, 8=epic

## Workflow
- When fixing a bug, reference the Linear issue ID in commits
- Format: "fix(BACK-123): description"
- Move issues to "In Progress" when starting work
- Move to "In Review" when PR is opened
```

### 5. Verify

```bash
claude

> List my assigned Linear issues for this sprint
# Expected output:
# BACK-142: Fix authentication timeout (In Progress, estimate: 3)
# BACK-145: Add rate limiting to /api/v2 (Todo, estimate: 5)
# BACK-147: Update error response format (Todo, estimate: 2)
```

## Usage Example

Complete workflow from issue to implementation using Claude Code with Linear:

```bash
# Start Claude Code
claude

# Check what to work on
> What's the highest priority unassigned issue in the Backend team?
```

Claude Code queries Linear via MCP:

```
Found: BACK-156 "Database connection pool exhaustion under load"
Priority: Urgent | Estimate: 5 | Labels: bug, production
Description: Under sustained load (>500 req/s), the connection pool
exhausts all connections and requests start failing with timeout errors.
```

Start working on it:

```bash
> Assign BACK-156 to me and move it to "In Progress"
```

Claude Code updates Linear:

```
Done. BACK-156 assigned to you and moved to "In Progress".
```

Now implement the fix with full context:

```bash
> Based on BACK-156, analyze our database connection configuration
> and implement a fix for pool exhaustion. Check src/db/ for the
> current setup.
```

Claude Code reads your code and generates:

```typescript
// src/db/pool-config.ts
import { Pool, PoolConfig } from "pg";

interface HealthyPoolConfig extends PoolConfig {
  maxConnections: number;
  minConnections: number;
  acquireTimeoutMs: number;
  idleTimeoutMs: number;
  reapIntervalMs: number;
}

const DEFAULT_CONFIG: HealthyPoolConfig = {
  maxConnections: 20,
  minConnections: 5,
  acquireTimeoutMs: 10000,
  idleTimeoutMs: 30000,
  reapIntervalMs: 1000,
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || "5432"),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
};

export function createPool(overrides?: Partial<HealthyPoolConfig>): Pool {
  const config = { ...DEFAULT_CONFIG, ...overrides };

  const pool = new Pool({
    max: config.maxConnections,
    min: config.minConnections,
    idleTimeoutMillis: config.idleTimeoutMs,
    connectionTimeoutMillis: config.acquireTimeoutMs,
    host: config.host,
    port: config.port,
    database: config.database,
    user: config.user,
    password: config.password,
  });

  pool.on("error", (err) => {
    console.error("Unexpected pool error:", err.message);
  });

  pool.on("connect", () => {
    pool.query("SET statement_timeout = '30s'");
  });

  return pool;
}
```

After implementing and testing:

```bash
> Add a comment to BACK-156 with the fix summary and move it to "In Review"

# Claude Code posts to Linear:
# "Fixed by adjusting pool config: max=20, min=5, added connection timeout
#  of 10s, idle timeout 30s, and statement timeout 30s per connection.
#  PR: #234"
```

## Common Issues

- **MCP server fails to start:** Ensure `LINEAR_API_KEY` is valid and has correct scopes. Regenerate the key if you see 401 errors.
- **"Team not found" errors:** Verify the team key in your CLAUDE.md matches your Linear workspace exactly (case-sensitive).
- **Rate limiting from Linear API:** The MCP server handles rate limits automatically, but if you see 429 errors, reduce batch operations to 5 issues at a time.

## Why This Matters

Developers using Linear + Claude Code MCP integration report closing issues 25% faster by eliminating manual status updates and context switching between browser and terminal.



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [MCP Integration Guide for Claude Code Beginners](/mcp-integration-guide-for-claude-code-beginners/)
- [GitHub MCP Server Advanced Workflow Automation](/github-mcp-server-advanced-workflow-automation/)
- [How to Write Effective CLAUDE.md for Your Project](/how-to-write-effective-claude-md-for-your-project/)

## See Also

- [Claude Code vs Zed AI (2026): Editor Integration](/claude-code-vs-zed-ai-editor-integration-2026/)
- [Claude Code for DeFi Protocol Integration (2026)](/claude-code-defi-protocol-integration-2026/)
- [Claude Code + Neovim Terminal Integration 2026](/claude-code-neovim-terminal-integration-2026/)
- [How to Use Claude Code in IntelliJ IDEA 2026](/claude-code-intellij-idea-integration-2026/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), .claude/settings.json (permissions), and .claude/skills/ (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code..."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in git diff. If a change is wrong, revert it with git checkout -- <file> for a single file or git stash for all changes."
      }
    }
  ]
}
</script>
