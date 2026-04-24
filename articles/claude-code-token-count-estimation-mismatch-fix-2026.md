---
title: "Token Count Estimation Mismatch Fix"
permalink: /claude-code-token-count-estimation-mismatch-fix-2026/
description: "Fix token count estimation mismatch in Claude Code. Actual usage exceeds displayed count due to hidden system prompt and tool definition overhead."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Warning: Estimated token usage (45,000) does not match actual API consumption (78,234).
Session cost may be higher than displayed.
```

This appears when the token counter shown in Claude Code's status bar diverges significantly from actual API usage reported on your Anthropic dashboard.

## The Fix

```bash
claude --token-count
```

1. Run Claude Code with `--token-count` to get accurate per-turn token reporting.
2. Check your actual usage on the Anthropic Console at `console.anthropic.com/usage`.
3. Compare the displayed estimate with the API-reported total to identify which turns caused the spike.

## Why This Happens

Claude Code's local token estimator uses an approximate tokenizer that does not account for system prompts, tool definitions, or thinking tokens. Each tool definition adds 200-400 tokens, and system prompts can add 2,000-4,000 tokens per turn. Extended thinking mode consumes additional tokens that are not always reflected in the local count.

## If That Doesn't Work

Reduce the number of active tools to lower hidden overhead:

```bash
claude --disallowedTools "Bash,Write" "Review this code"
```

Disable extended thinking for cost-sensitive tasks:

```bash
claude --no-thinking "Simple rename of variable x to userId"
```

Monitor API usage directly with curl:

```bash
curl -s https://api.anthropic.com/v1/usage \
  -H "x-api-key: $ANTHROPIC_API_KEY" | jq '.daily_usage'
```

## Prevention

```markdown
# CLAUDE.md rule
Keep tool definitions minimal. Disable unused MCP servers. Check console.anthropic.com/usage after large sessions to verify actual cost against estimates.
```

## See Also

- [Embedding Dimension Mismatch Error — Fix (2026)](/claude-code-embedding-dimension-mismatch-fix-2026/)
- [esbuild Target Mismatch Error — Fix (2026)](/claude-code-esbuild-target-mismatch-fix-2026/)
- [Keep-Alive Timeout Mismatch Error — Fix (2026)](/claude-code-keep-alive-timeout-mismatch-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `ETIMEDOUT: connection timed out`
- `RequestTimeout: request took longer than 120000ms`
- `ESOCKETTIMEDOUT`
- `MCP server connection refused`
- `MCP protocol version incompatible`

## Frequently Asked Questions

### What is the default timeout for Claude Code API requests?

The default timeout is 120 seconds (120000ms). For complex operations involving large codebases or multi-file edits, this may be insufficient. Increase it with `claude config set api_timeout 300000` for a 5-minute timeout.

### Can network latency cause timeouts?

Yes. Corporate proxies, VPNs, and DNS filtering services add round-trip latency. Measure your baseline latency with `curl -o /dev/null -s -w '%{time_total}' https://api.anthropic.com/v1/messages`. If it exceeds 5 seconds, route API traffic outside the proxy.

### Do timeouts consume API credits?

Partially. If the server began processing your request before the client timed out, the input tokens are consumed even though you never received a response. Long timeouts reduce wasted credits by allowing the response to complete.

### What is MCP in Claude Code?

MCP (Model Context Protocol) is a standard protocol that lets Claude Code communicate with external tool servers. MCP servers expose custom tools (databases, APIs, file systems) that Claude Code can invoke during a session. Configuration is stored in `.claude/mcp.json`.
