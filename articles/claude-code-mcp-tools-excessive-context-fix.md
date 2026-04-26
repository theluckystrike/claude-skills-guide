---
layout: default
title: "Fix Claude Code MCP Tools Excessive (2026)"
description: "Reduce MCP server context overhead in Claude Code by deferring tool definitions, disabling unused servers, and preferring CLI tools."
date: 2026-04-15
permalink: /claude-code-mcp-tools-excessive-context-fix/
categories: [troubleshooting, claude-code]
tags: [mcp, context-window, tokens, optimization, tool-search]
last_modified_at: 2026-04-17
geo_optimized: true
---
# Fix MCP Tools Using Too Much Context

## The Error

Your Claude Code sessions consume unexpectedly high tokens. Running `/context` reveals that MCP tool definitions are taking a significant portion of the context window, even when you are not using those tools.

## Quick Fix

MCP tool definitions are deferred by default in recent versions of Claude Code. If you are seeing excessive MCP context usage, check that you have not overridden this behavior. Disable unused MCP servers:

```text
/mcp
```

Review the list and remove servers you are not actively using:

```bash
claude mcp remove unused-server
```

## What's Happening

Each MCP server registers tools with Claude Code. Every tool has a name, description, and input schema that Claude needs to understand. When many servers are configured, the combined tool definitions can consume thousands of tokens in the context window.

Claude Code mitigates this with MCP tool search, which defers full tool definitions. Only tool names enter context at startup. When Claude decides to use a specific tool, the full definition loads on demand. This keeps the baseline context overhead minimal regardless of how many MCP servers you have configured.

However, the overhead still scales with the number of configured servers and their tool counts. Even deferred tool names consume tokens. And once Claude uses a tool, its full definition stays in context for the remainder of the session.

The `MAX_MCP_OUTPUT_TOKENS` environment variable controls a different but related issue: Claude Code displays a warning when MCP tool output exceeds 10,000 tokens. Large tool responses (like database query results) inflate context rapidly.

## Step-by-Step Fix

### Step 1: Audit your MCP servers

Check what is configured:

```bash
claude mcp list
```

Inside Claude Code, use `/mcp` to see connection status and tool counts for each server.

### Step 2: Run /context to see the breakdown

```text
/context
```

This shows a live breakdown of context usage by category. Note how much space MCP tools are consuming versus your conversation and file reads.

### Step 3: Remove unused servers

Remove any MCP server you are not actively using:

```bash
claude mcp remove server-name
```

Every server you remove reduces baseline context overhead.

### Step 4: Prefer CLI tools over MCP servers

CLI tools like `gh`, `aws`, `gcloud`, and `sentry-cli` add zero per-tool context overhead. Claude can run them directly as Bash commands. If both a CLI tool and an MCP server provide the same functionality, the CLI tool is more context-efficient.

For example, instead of configuring a GitHub MCP server:

```bash
# Use the gh CLI instead
claude mcp remove github
```

Claude can use `gh pr list`, `gh issue view`, and other commands directly.

### Step 5: Limit MCP tool output size

If MCP tools return large responses, set the output token limit:

```bash
MAX_MCP_OUTPUT_TOKENS=50000 claude
```

Or add it to your settings:

```json
{
 "env": {
 "MAX_MCP_OUTPUT_TOKENS": "20000"
 }
}
```

This does not truncate output but warns when it is exceeded, helping you identify servers that produce oversized responses.

### Step 6: Use project-scoped servers

Instead of configuring MCP servers globally (user scope), configure them per-project so they only load when relevant:

```bash
claude mcp add --scope local my-server -- npx -y @some/package
```

Use `--scope local` for your personal per-project configuration, or `--scope project` for team-shared configuration stored in `.mcp.json`.

### Step 7: Disable auto-approval for project servers

If project `.mcp.json` files add many servers automatically, control which ones load:

```json
{
 "enabledMcpjsonServers": ["memory", "github"],
 "disabledMcpjsonServers": ["filesystem"]
}
```

Add this to your Claude Code settings to selectively enable only the servers you need.

## Prevention

Configure only the MCP servers you actively use for each project. Audit servers periodically with `claude mcp list` and remove stale configurations. For large teams, standardize MCP server configuration in project settings rather than leaving it to individual developers.

Prefer CLI tools when they provide equivalent functionality. Reserve MCP servers for tools that genuinely need the bidirectional communication that MCP provides, like databases, monitoring dashboards, and issue trackers with complex state.

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-mcp&utm_campaign=claude-code-mcp-tools-excessive-context-fix)**

47/500 founding spots. Price goes up when they're gone.

</div>

---



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Building Your First MCP Tool Integration Guide](/building-your-first-mcp-tool-integration-guide-2026/)
- [Claude Code Context Window Full in Large Codebase Fix](/claude-code-context-window-full-in-large-codebase-fix/)
- [Claude Code Cost Per Project Estimation Guide](/claude-code-cost-per-project-estimation-calculator-guide/)
- [Anthropic SDK MCP Empty Arguments Bug](/anthropic-sdk-mcp-empty-arguments-bug/)

## See Also

- [Claude Code MCP tools loading slowly — token cost impact](/claude-code-mcp-tools-loading-slowly-token-cost/)
