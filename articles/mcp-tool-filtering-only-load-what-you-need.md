---
title: "MCP Tool Filtering: Only Load What You Need"
description: "Filter MCP tool definitions in Claude Code to eliminate 2,000-10,000 tokens of overhead per turn by loading only the tools each session actually needs."
permalink: /mcp-tool-filtering-only-load-what-you-need/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# MCP Tool Filtering: Only Load What You Need

## What It Does

Every MCP tool definition loaded in Claude Code adds 500-2,000 tokens to the system prompt, and that overhead is sent with every API call. An MCP server exposing 10 tools adds 5,000-20,000 tokens of persistent overhead. Tool filtering restricts which tools are loaded, reducing overhead to only the tools needed for the current task.

## Installation / Setup

Tool filtering is [Claude Code MCP configuration guide](/claude-code-mcp-configuration-guide/) settings. No additional packages are required.

```json
// ~/.claude/settings.json or .claude/settings.json (project-level)
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_..."
      },
      "allowedTools": [
        "get_pull_request",
        "list_pull_requests",
        "create_pull_request_review"
      ]
    }
  }
}
```

## Configuration for Cost Optimization

### Strategy 1: Static Filtering with allowedTools

For MCP servers where the needed tools are predictable, use static `allowedTools` to whitelist specific tools.

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/project"],
      "allowedTools": [
        "read_file",
        "write_file",
        "list_directory"
      ]
    }
  }
}
```

A filesystem MCP server may expose 8-12 tools (read, write, move, delete, search, stat, etc.), totaling approximately 8,000-12,000 tokens in definitions. Filtering to 3 tools reduces this to approximately 1,500-3,000 tokens. **Savings: 5,000-9,000 tokens per turn.**

### Strategy 2: Task-Specific MCP Profiles

Create multiple MCP configuration files for different task types and switch between them.

```bash
# Profile: development (minimal tools)
# .claude/settings.dev.json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "allowedTools": ["get_pull_request", "list_pull_requests"]
    }
  }
}

# Profile: review (PR-focused tools)
# .claude/settings.review.json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "allowedTools": [
        "get_pull_request",
        "list_pull_request_files",
        "create_pull_request_review",
        "list_pull_request_reviews"
      ]
    }
  }
}
```

## Usage Examples

### Basic Usage

```bash
# Start Claude Code with default MCP settings (all tools loaded)
claude
# MCP overhead: ~15,000 tokens/turn across 3 servers

# Start with filtered settings
# Claude Code reads .claude/settings.json with allowedTools
claude
# MCP overhead: ~3,000 tokens/turn (filtered to essential tools)
```

### Advanced: Cost-Saving Pattern

Audit current MCP overhead and eliminate unused tools:

```bash
# Step 1: Check which MCP tools are currently loaded
# In a Claude Code session:
> "List all available MCP tools and their servers"

# Step 2: Review the last 20 sessions for tool usage
# Which MCP tools were actually called vs just loaded?

# Step 3: Add allowedTools for each server, including only tools used
# in the last 2 weeks

# Example audit result:
# GitHub server: 12 tools loaded, 3 used -> filter to 3
# Supabase server: 10 tools loaded, 2 used -> filter to 2
# Filesystem server: 8 tools loaded, 4 used -> filter to 4
# Total: 30 tools loaded -> 9 tools loaded
# Overhead reduction: ~25,000 tokens -> ~5,000 tokens per turn
```

## Token Usage Measurements

| MCP Server | Unfiltered Tools | Unfiltered Tokens/Turn | Filtered Tools | Filtered Tokens/Turn | Savings/Turn |
|------------|-----------------|----------------------|----------------|---------------------|-------------|
| GitHub | 12 | 12,000-15,000 | 3 | 1,500-3,000 | 9,000-12,000 |
| Supabase | 8-15 | 4,000-12,000 | 2 | 1,000-2,000 | 3,000-10,000 |
| Filesystem | 8-12 | 4,000-8,000 | 3 | 1,500-3,000 | 2,500-5,000 |
| Brave Search | 3-5 | 1,500-4,000 | 1 | 500-1,000 | 1,000-3,000 |

```text
20-turn session, 3 MCP servers:

Unfiltered: 3 servers * ~10,000 tokens/turn * 20 turns = 600,000 tokens
  Cost at Opus: $9.00 input overhead

Filtered: 3 servers * ~2,500 tokens/turn * 20 turns = 150,000 tokens
  Cost at Opus: $2.25 input overhead

  Savings: $6.75 per session (75% reduction in MCP overhead)
```

## Comparison with Alternatives

| Approach | Overhead per Turn | Setup Time | Flexibility |
|----------|------------------|------------|-------------|
| No filtering (default) | 5,000-30,000 tokens | 0 min | Maximum (all tools available) |
| allowedTools filtering | 1,500-5,000 tokens | 10-15 min | Reduced (must reconfigure for new tools) |
| Disable unused MCP servers entirely | 0 for disabled servers | 2 min | Minimal (tools not available at all) |
| Task-specific profiles | 1,000-3,000 tokens | 20-30 min | Optimal (right tools for each task type) |

## Troubleshooting

**"Tool not found" errors after filtering** -- The agent is trying to use a tool that was filtered out. Add it to the `allowedTools` list or reconsider whether the task requires a different MCP profile.

**Not sure which tools to keep** -- Start permissive (no filtering), track tool usage over a week, then filter to only the tools that were actually called.

**Filtering not reducing costs as expected** -- Verify that `allowedTools` is properly configured in settings.json. A syntax error in the JSON causes Claude Code to fall back to loading all tools.

## Related Guides

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/) -- complete MCP server configuration guide
- [Supabase MCP Server Token Usage](/supabase-mcp-server-token-usage-what-gets-sent/) -- Supabase-specific MCP optimization
- [Claude Code Tool Call Overhead](/claude-code-tool-call-overhead-tokens-per-mcp-call/) -- understanding per-call token costs

- [claude mcp list command guide](/claude-mcp-list-command-guide/) — How to use the claude mcp list command to manage MCP servers

