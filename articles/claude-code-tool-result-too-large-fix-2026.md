---
title: "Tool Result Exceeds 100KB Truncating — Fix (2026)"
permalink: /claude-code-tool-result-too-large-fix-2026/
description: "Pipe command output through head or grep filters before execution in Claude Code. Prevents the 100KB tool result truncation that drops important data."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Tool result exceeds maximum size (100KB). Truncating output.
```

## The Fix

```bash
# Instead of running commands that produce huge output, filter first
# Bad: git log (unbounded)
# Good: git log --oneline -50

# Bad: find . -name "*.ts"
# Good: find . -name "*.ts" | head -100

# Bad: cat large-output.log
# Good: tail -n 200 large-output.log
```

## Why This Works

Tool results are injected into the context window for Claude to process. A 100KB result would consume tens of thousands of tokens, crowding out space for reasoning and response. Truncation loses the tail of the output, which may contain the information you need. By pre-filtering at the command level, you ensure the most relevant data arrives intact within the 100KB boundary.

## If That Doesn't Work

```bash
# Redirect large output to a file, then read specific sections
your-command > /tmp/full-output.txt 2>&1
wc -l /tmp/full-output.txt
# Then ask Claude Code to read specific line ranges
# "Read lines 400-500 of /tmp/full-output.txt"
```

For commands that inherently produce large output (dependency trees, recursive directory listings), always write to a file first and inspect sections rather than streaming the full result through a tool call.

## Prevention

Add to your CLAUDE.md:
```
All shell commands must limit output: use head -100, tail -200, --oneline, or grep filters. Never run unbounded commands like find, cat, or git log without output limits. Write large results to /tmp/ and read sections.
```
