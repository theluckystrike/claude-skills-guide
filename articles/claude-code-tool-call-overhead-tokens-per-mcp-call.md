---
title: "Claude Code tool call overhead --"
description: "Every Claude Code tool call costs 150-2,000+ tokens in overhead before any work happens -- understand the per-tool breakdown to minimize wasted tokens."
permalink: /claude-code-tool-call-overhead-tokens-per-mcp-call/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code tool call overhead -- how many tokens per MCP call

## The Problem

Every tool call in Claude Code carries a fixed token overhead beyond the actual work performed. Bash calls cost approximately 245 tokens of overhead. Read calls cost approximately 150 tokens. MCP tool calls cost 500-2,000+ tokens for the tool definition alone, re-sent on every turn. A session making 30 tool calls spends 4,500-15,000 tokens purely on overhead -- tokens that produce no useful output. At Opus 4.6 rates, 15,000 tokens of overhead costs $0.23 per session in pure waste.

## Quick Fix (2 Minutes)

1. **Combine operations** -- run multiple grep patterns in one Bash call instead of separate calls.
2. **Use Read instead of Bash(cat)** -- Read overhead is 150 tokens versus Bash's 245 tokens.
3. **Remove unused MCP servers** -- each unused MCP tool definition wastes 500-2,000 tokens every turn.

```bash
# Instead of 3 separate searches (3 * 245 = 735 tokens overhead):
grep -r "TODO" src/
grep -r "FIXME" src/
grep -r "HACK" src/

# Combine into 1 search (245 tokens overhead):
grep -rE "TODO|FIXME|HACK" src/
```

## Why This Happens

Tool call overhead exists because Claude Code must format each tool invocation as structured data in the API request. This formatting includes the tool name, parameters, and schema validation -- all of which consume tokens. Additionally, MCP tool definitions are included in the system prompt on every API call, regardless of whether those tools are used in that particular turn.

The overhead breaks down into three categories:

1. **Invocation overhead** -- the tokens to express "call this tool with these parameters"
2. **Response framing** -- the tokens to frame the tool's output in the conversation
3. **Definition overhead** -- for MCP tools, the schema sent with every message (most expensive)

## The Full Fix

### Step 1: Diagnose

Identify the tools consuming the most overhead:

```bash
# Check MCP tool count
# In a Claude Code session:
> "List all loaded MCP tools and count them"

# Calculate definition overhead:
# tools * avg_definition_size = overhead per turn
# Example: 15 tools * 1,000 tokens = 15,000 tokens/turn

# Check /cost for total overhead impact
/cost
# If input tokens are high relative to useful work done, overhead is the cause
```

### Step 2: Fix

Reference table of per-tool overhead:

| Tool | Invocation Overhead | Response Framing | Definition (per turn) | Total per Use |
|------|--------------------|--------------------|----------------------|---------------|
| Bash | ~245 tokens | ~50 tokens | 0 (built-in) | ~295 tokens |
| Read | ~150 tokens | ~30 tokens | 0 (built-in) | ~180 tokens |
| Write | ~200 tokens | ~30 tokens | 0 (built-in) | ~230 tokens |
| Edit | ~180 tokens | ~30 tokens | 0 (built-in) | ~210 tokens |
| Glob | ~120 tokens | ~30 tokens | 0 (built-in) | ~150 tokens |
| Grep | ~130 tokens | ~30 tokens | 0 (built-in) | ~160 tokens |
| MCP tool (simple) | ~300 tokens | ~50 tokens | ~500 tokens/turn | ~850 tokens |
| MCP tool (complex) | ~500 tokens | ~100 tokens | ~2,000 tokens/turn | ~2,600 tokens |
| Subagent (Task) | ~500 tokens | ~200 tokens | 5,000 base | ~5,700 tokens |

```yaml
# CLAUDE.md -- tool call efficiency rules
## Tool Call Optimization
- Prefer built-in tools (Read, Grep, Glob) over MCP equivalents
- Combine multiple grep patterns into one call using -E "pattern1|pattern2"
- Use Glob for file discovery instead of Bash(find) -- 120 vs 245 tokens overhead
- Use Read instead of Bash(cat) -- 150 vs 245 tokens overhead
- Maximum 15 tool calls per task (forces efficient tool use)
- For MCP tools: only load tools that will be used in the current session
```

### Step 3: Prevent

Minimize MCP definition overhead through filtering:

```json
// .claude/settings.json -- only load necessary MCP tools
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "allowedTools": ["get_pull_request", "create_pull_request_review"]
    }
  }
}
```

```text
Impact of MCP filtering:

Before: 12 GitHub tools * 1,200 tokens/tool = 14,400 tokens/turn
After: 2 GitHub tools * 1,200 tokens/tool = 2,400 tokens/turn
Savings: 12,000 tokens/turn

Over 20 turns: 240,000 tokens saved = $3.60 at Opus rates
```

## Cost Recovery

```text
If MCP overhead is already inflating the session:

Option 1: Cannot remove MCP definitions mid-session
  Action: /compact to reduce other context, minimizing total size
  Savings: reduces non-MCP context by 60-80%

Option 2: Start fresh session with filtered MCP settings
  Action: update settings.json with allowedTools, start new session
  Savings: immediate reduction from next turn onward

Prevention ROI:
  10 minutes to configure MCP filtering
  Saves 12,000 tokens/turn * 20 turns = 240,000 tokens/session
  At Opus, 20 sessions/month: $72/month saved
  ROI: 10 minutes setup saves $72/month = 432x return
```

## Prevention Rules for CLAUDE.md

```yaml
# CLAUDE.md -- copy-paste this section

## Tool Call Efficiency
- Prefer built-in tools: Read (150 tokens) over Bash cat (245 tokens)
- Prefer Glob (120 tokens) over Bash find (245 tokens)
- Combine grep patterns: `grep -rE "pat1|pat2|pat3"` (1 call vs 3)
- Maximum 15 tool calls per task
- Avoid Bash for operations that built-in tools handle (file reading, searching)
- For file content: always use Read tool with offset/limit, not cat/head/tail via Bash
```

## Related Guides

- [MCP Tool Filtering: Only Load What You Need](/mcp-tool-filtering-only-load-what-you-need/) -- reducing MCP definition overhead
- [Supabase MCP Server Token Usage](/supabase-mcp-server-token-usage-what-gets-sent/) -- specific MCP overhead analysis
- [How to Reduce Claude Code Token Usage by 3x](/reduce-claude-code-token-usage-3x-guide-2026/) -- comprehensive cost reduction strategies

## See Also

- [Anthropic Rate Limit Tokens Per Minute — Fix (2026)](/claude-code-anthropic-rate-limit-tokens-per-minute-fix-2026/)
- [Claude Bash Tool Costs 245 Tokens Per Call](/04-bash-tool-costs-245-tokens/)
- [Claude Code Tool Calling and Parallel Execution 2026](/claude-code-tool-calling-parallel-execution-2026/)
- [How Tool Definitions Add 346 Tokens Per Call](/02-tool-definitions-add-346-tokens/)
