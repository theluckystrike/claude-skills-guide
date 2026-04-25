---
title: "Tool Result Exceeds 100KB Truncating"
permalink: /claude-code-tool-result-too-large-fix-2026/
description: "Pipe command output through head or grep filters before execution in Claude Code. Prevents the 100KB tool result truncation that drops important data."
last_tested: "2026-04-21"
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

## See Also

- [Knowledge Base Exceeds 512KB Maximum — Fix (2026)](/claude-code-knowledge-base-too-large-fix-2026/)
- [Claude API 413 Request Payload Too Large — Fix (2026)](/claude-api-413-request-payload-too-large-fix/)
- [Claude Code Tool Calling and Parallel Execution 2026](/claude-code-tool-calling-parallel-execution-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `fatal: not a git repository`
- `error: failed to push some refs`
- `fatal: refusing to merge unrelated histories`
- `ContextWindowExceeded: input exceeds maximum context length`
- `Error: message content too large`

## Frequently Asked Questions

### Why does Claude Code require git?

Claude Code uses git for several core operations: tracking file changes, creating commits, reading blame information, searching history with `git log`, and managing branches. Without git, these operations fail and Claude Code falls back to less efficient alternatives.

### Can Claude Code work in a non-git directory?

Yes, but with reduced functionality. File search and editing work normally, but version control operations (commit, diff, blame) are unavailable. Claude Code displays a warning when opened in a directory without git initialization.

### How do I prevent Claude Code from making unwanted git operations?

Add rules to your CLAUDE.md: `Do not create commits automatically. Do not run git push. Always ask before any git operation that modifies history.` Claude Code respects these constraints and asks for confirmation before proceeding.

### What is the context window limit?

Claude's context window is 200,000 tokens. This includes system prompts, conversation history, file contents read during the session, and tool results. When the total exceeds this limit, Claude Code must compress or drop earlier context.


## Related Guides

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

## Implementation Details

When working with this in Claude Code, pay attention to these practical details:

**Project configuration.** Add specific instructions to your CLAUDE.md file describing how your project handles this area. Include file paths, naming conventions, and any patterns that differ from common defaults. Claude Code reads CLAUDE.md at the start of every session and uses it to guide all operations.

**Testing the setup.** After configuration, verify everything works by running a simple test task. Ask Claude Code to perform a read-only operation first (like listing files or reading a config) before moving to write operations. This confirms that permissions, paths, and tools are all correctly configured.

**Monitoring and iteration.** Track your results over several sessions. If Claude Code consistently makes the same mistake, the fix is usually a more specific CLAUDE.md instruction. If it makes different mistakes each time, the issue is likely in the project setup or toolchain configuration.

## Troubleshooting Checklist

When something does not work as expected, check these items in order:

1. **CLAUDE.md exists at the project root** — run `ls -la CLAUDE.md` to verify
2. **Node.js version is 18+** — run `node --version` to check
3. **API key is set** — run `echo $ANTHROPIC_API_KEY | head -c 10` to verify (shows first 10 characters only)
4. **Disk space is available** — run `df -h .` to check
5. **Network can reach the API** — run `curl -s -o /dev/null -w "%{http_code}" https://api.anthropic.com` (should return 401 without auth, meaning the server is reachable)
6. **No conflicting processes** — run `ps aux | grep claude | grep -v grep` to check for stale sessions
