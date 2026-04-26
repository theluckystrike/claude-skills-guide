---
layout: default
title: "MCPMark Benchmarks (2026)"
description: "Claude Code resource: mCPMark benchmark results show 3-8x token efficiency gaps between MCP server implementations -- learn which servers waste tokens..."
permalink: /mcpmark-benchmarks-token-efficiency-revealed/
date: 2026-04-22
last_tested: "2026-04-22"
---

# MCPMark Benchmarks: What They Reveal About Token Efficiency

## What It Does

MCPMark is a benchmarking framework for evaluating MCP server performance, including token efficiency per operation. The benchmarks reveal that MCP servers vary dramatically in token cost for equivalent operations -- some servers consume 3-8x more tokens than others for the same task. These measurements help developers choose the most token-efficient MCP servers and identify optimization targets in custom servers.

## Installation / Setup

```bash
# MCPMark is available as an open-source benchmarking tool
npm install -g mcpmark

# Run benchmarks against a specific MCP server
mcpmark run --server "npx @modelcontextprotocol/server-filesystem /tmp" --output results.json

# Compare multiple servers
mcpmark compare results-server-a.json results-server-b.json
```

## Configuration for Cost Optimization

The primary optimization insight from MCPMark is which MCP servers to use and how to configure them for minimal token overhead.

```yaml
# CLAUDE.md -- MCP selection based on benchmark data
## MCP Server Selection
- Use servers with tool definitions under 1,000 tokens each
- Prefer servers that return structured JSON over verbose text
- Avoid servers with more than 8 tool definitions (overhead exceeds 8,000 tokens)
- For database access: direct SQL via Bash often costs fewer tokens than MCP
```

## Usage Examples

### Basic Usage

```bash
# Benchmark a filesystem MCP server
mcpmark run \
  --server "npx @modelcontextprotocol/server-filesystem /tmp" \
  --tasks read,write,list \
  --output fs-benchmark.json

# Output includes:
# - Tokens per tool definition
# - Tokens per operation (read, write, list)
# - Response size distribution
# - Error rate and retry costs
```

### Advanced: Cost-Saving Pattern

Use benchmark data to choose between competing MCP servers for the same capability.

```text
# Example benchmark comparison: two database MCP servers

Server A (generic SQL MCP):
  Tool definitions: 6 tools, 7,200 tokens total
  Average query response: 1,800 tokens
  Schema introspection: 3,500 tokens
  Per-session overhead (20 turns): 144,000 tokens

Server B (optimized Postgres MCP):
  Tool definitions: 3 tools, 2,100 tokens total
  Average query response: 600 tokens (structured JSON)
  Schema introspection: 800 tokens
  Per-session overhead (20 turns): 42,000 tokens

  Server B saves 102,000 tokens per session
  At Opus rates: $1.53 saved per session
  Monthly (20 sessions): $30.60 saved
```

```json
// Choose Server B configuration
{
  "mcpServers": {
    "database": {
      "command": "npx",
      "args": ["-y", "optimized-postgres-mcp"],
      "allowedTools": ["query", "schema", "explain"]
    }
  }
}
```

## Token Usage Measurements

Key findings from MCPMark benchmarks across common MCP server categories:

| MCP Server Category | Avg Tool Definition Size | Avg Response Size | Tools Exposed | Session Overhead (20 turns) |
|--------------------|------------------------|-------------------|---------------|---------------------------|
| Filesystem (basic) | 800 tokens/tool | 500 tokens | 8 | 128,000 tokens |
| Filesystem (optimized) | 400 tokens/tool | 200 tokens | 4 | 32,000 tokens |
| Database (generic) | 1,200 tokens/tool | 1,800 tokens | 6 | 144,000 tokens |
| Database (optimized) | 700 tokens/tool | 600 tokens | 3 | 42,000 tokens |
| Git/GitHub | 1,500 tokens/tool | 1,200 tokens | 12 | 360,000 tokens |
| Git/GitHub (filtered) | 1,500 tokens/tool | 1,200 tokens | 3 | 90,000 tokens |

```text
The token efficiency gap across implementations:

Best case (optimized filesystem, 4 tools):
  Definition overhead: 1,600 tokens/turn
  20-turn session: 32,000 tokens
  Opus cost: $0.48

Worst case (unfiltered GitHub, 12 tools):
  Definition overhead: 18,000 tokens/turn
  20-turn session: 360,000 tokens
  Opus cost: $5.40

  Gap: 11.25x more expensive for MCP overhead alone
```

## Comparison with Alternatives

| Evaluation Method | Measures | Effort | Accuracy |
|------------------|----------|--------|----------|
| MCPMark benchmarks | Token count, latency, error rate | Low (automated) | High (real measurements) |
| Manual /cost tracking | Session-level totals | Medium (manual per session) | Medium (no per-tool breakdown) |
| Documentation review | Claimed tool count | Low | Low (claims vs reality) |
| Custom token logging | Per-call token counts | High (requires instrumentation) | High |

## Troubleshooting

**Benchmark results vary between runs** -- MCP server response sizes can vary based on data state. Run benchmarks 3 times and average the results. Use consistent test data for reproducible measurements.

**MCPMark not detecting all tools** -- Some MCP servers expose tools dynamically. Use `mcpmark run --discover` to enumerate all available tools before benchmarking.

**Results do not match real-world usage** -- Benchmarks measure isolated tool calls. Real-world sessions include context re-sending, which multiplies the tool definition overhead by the number of turns. Multiply benchmark definition sizes by expected session length for accurate projections.



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [MCP Tool Filtering: Only Load What You Need](/mcp-tool-filtering-only-load-what-you-need/) -- applying benchmark insights to filter tools
- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/) -- configuring MCP servers for optimal performance
- [Claude Code Tool Call Overhead](/claude-code-tool-call-overhead-tokens-per-mcp-call/) -- understanding the full cost of tool calls


## Common Questions

### How do I get started with mcpmark benchmarks?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Code for JMH Java Benchmarks](/claude-code-for-jmh-benchmark-workflow-tutorial-guide/)
- [Claude Code spending tokens on files I](/claude-code-spending-tokens-files-didnt-ask-about/)
- [Claude Code for Release Candidate](/claude-code-for-release-candidate-workflow-tutorial/)
